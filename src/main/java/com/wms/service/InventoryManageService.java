package com.wms.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.context.TenantContextHolder;
import com.wms.dto.InventoryFreezeRequest;
import com.wms.dto.InventoryMoveRequest;
import com.wms.entity.Inventory;
import com.wms.entity.InventoryFreezeLog;
import com.wms.entity.Location;
import com.wms.mapper.InventoryFreezeLogMapper;
import com.wms.mapper.InventoryMapper;
import com.wms.mapper.LocationMapper;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
public class InventoryManageService {

    @Autowired
    private InventoryMapper inventoryMapper;

    @Autowired
    private InventoryFreezeLogMapper freezeLogMapper;

    @Autowired
    private LocationMapper locationMapper;

    @Autowired
    private RedissonClient redissonClient;

    /**
     * 冻结库存（使用分布式锁）
     * @param request 冻结请求
     * @return 是否成功
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean freezeInventory(InventoryFreezeRequest request) {
        String lockKey = "inventory:lock:" + request.getInventoryId();
        RLock lock = redissonClient.getLock(lockKey);

        log.info("开始冻结库存，inventoryId={}, quantity={}, orderNo={}",
                request.getInventoryId(), request.getQuantity(), request.getOrderNo());

        try {
            // 尝试获取锁，最多等待5秒，锁有效期10秒
            boolean locked = lock.tryLock(5, 10, TimeUnit.SECONDS);
            if (!locked) {
                log.error("获取分布式锁失败，inventoryId={}", request.getInventoryId());
                throw new RuntimeException("系统繁忙，请稍后重试");
            }

            // 查询库存
            Inventory inventory = inventoryMapper.selectById(request.getInventoryId());
            if (inventory == null) {
                throw new RuntimeException("库存不存在");
            }

            // 计算可用库存
            int availableQuantity = inventory.getQuantity() - inventory.getLockedQuantity();
            if (availableQuantity < request.getQuantity()) {
                throw new RuntimeException("库存不足，可用库存：" + availableQuantity);
            }

            // 更新锁定数量
            inventory.setLockedQuantity(inventory.getLockedQuantity() + request.getQuantity());
            inventoryMapper.updateById(inventory);

            // 记录冻结日志
            InventoryFreezeLog freezeLog = new InventoryFreezeLog();
            freezeLog.setTenantId(TenantContextHolder.getTenantId());
            freezeLog.setInventoryId(request.getInventoryId());
            freezeLog.setSkuCode(inventory.getSkuCode());
            freezeLog.setQuantity(request.getQuantity());
            freezeLog.setOrderNo(request.getOrderNo());
            freezeLog.setReason(request.getReason());
            freezeLog.setStatus(0); // 冻结中
            freezeLogMapper.insert(freezeLog);

            log.info("库存冻结成功，inventoryId={}, 锁定后lockedQuantity={}",
                    request.getInventoryId(), inventory.getLockedQuantity());

            return true;

        } catch (InterruptedException e) {
            log.error("获取分布式锁被中断", e);
            Thread.currentThread().interrupt();
            throw new RuntimeException("操作被中断");
        } catch (Exception e) {
            log.error("冻结库存失败", e);
            throw new RuntimeException(e.getMessage());
        } finally {
            // 释放锁
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
                log.info("释放分布式锁，inventoryId={}", request.getInventoryId());
            }
        }
    }

    /**
     * 解冻库存（释放占用）
     * @param freezeLogId 冻结记录ID
     * @return 是否成功
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean unfreezeInventory(Long freezeLogId) {
        // 查询冻结记录
        InventoryFreezeLog freezeLog = freezeLogMapper.selectById(freezeLogId);
        if (freezeLog == null) {
            throw new RuntimeException("冻结记录不存在");
        }

        if (freezeLog.getStatus() != 0) {
            throw new RuntimeException("该记录已处理，无法重复解冻");
        }

        String lockKey = "inventory:lock:" + freezeLog.getInventoryId();
        RLock lock = redissonClient.getLock(lockKey);

        log.info("开始解冻库存，freezeLogId={}, inventoryId={}, quantity={}",
                freezeLogId, freezeLog.getInventoryId(), freezeLog.getQuantity());

        try {
            boolean locked = lock.tryLock(5, 10, TimeUnit.SECONDS);
            if (!locked) {
                throw new RuntimeException("系统繁忙，请稍后重试");
            }

            // 查询库存
            Inventory inventory = inventoryMapper.selectById(freezeLog.getInventoryId());
            if (inventory == null) {
                throw new RuntimeException("库存不存在");
            }

            // 减少锁定数量
            int newLockedQuantity = inventory.getLockedQuantity() - freezeLog.getQuantity();
            if (newLockedQuantity < 0) {
                throw new RuntimeException("锁定数量异常，无法解冻");
            }
            inventory.setLockedQuantity(newLockedQuantity);
            inventoryMapper.updateById(inventory);

            // 更新冻结记录状态
            freezeLog.setStatus(1); // 已解冻
            freezeLogMapper.updateById(freezeLog);

            log.info("库存解冻成功，inventoryId={}, 解锁后lockedQuantity={}",
                    freezeLog.getInventoryId(), inventory.getLockedQuantity());

            return true;

        } catch (InterruptedException e) {
            log.error("获取分布式锁被中断", e);
            Thread.currentThread().interrupt();
            throw new RuntimeException("操作被中断");
        } catch (Exception e) {
            log.error("解冻库存失败", e);
            throw new RuntimeException(e.getMessage());
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    /**
     * 扣减库存（发货时使用）
     * @param inventoryId 库存ID
     * @param quantity 扣减数量
     * @param orderNo 订单号
     * @return 是否成功
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean deductInventory(Long inventoryId, Integer quantity, String orderNo) {
        String lockKey = "inventory:lock:" + inventoryId;
        RLock lock = redissonClient.getLock(lockKey);

        log.info("开始扣减库存，inventoryId={}, quantity={}, orderNo={}", inventoryId, quantity, orderNo);

        try {
            boolean locked = lock.tryLock(5, 10, TimeUnit.SECONDS);
            if (!locked) {
                throw new RuntimeException("系统繁忙，请稍后重试");
            }

            Inventory inventory = inventoryMapper.selectById(inventoryId);
            if (inventory == null) {
                throw new RuntimeException("库存不存在");
            }

            // 计算可扣减数量（实际库存 - 锁定库存）
            int availableToDeduct = inventory.getQuantity() - inventory.getLockedQuantity();
            if (availableToDeduct < quantity) {
                throw new RuntimeException("可扣减库存不足，当前可扣减：" + availableToDeduct);
            }

            // 扣减实际库存（注意：锁定库存不变，发货时扣减实际库存）
            inventory.setQuantity(inventory.getQuantity() - quantity);
            inventoryMapper.updateById(inventory);

            // 更新冻结记录状态
            LambdaQueryWrapper<InventoryFreezeLog> wrapper = new LambdaQueryWrapper<InventoryFreezeLog>()
                    .eq(InventoryFreezeLog::getInventoryId, inventoryId)
                    .eq(InventoryFreezeLog::getOrderNo, orderNo)
                    .eq(InventoryFreezeLog::getStatus, 0);

            InventoryFreezeLog freezeLog = freezeLogMapper.selectOne(wrapper);
            if (freezeLog != null) {
                freezeLog.setStatus(2); // 已扣减
                freezeLogMapper.updateById(freezeLog);
            }

            log.info("库存扣减成功，inventoryId={}, 扣减后quantity={}", inventoryId, inventory.getQuantity());

            return true;

        } catch (InterruptedException e) {
            log.error("获取分布式锁被中断", e);
            Thread.currentThread().interrupt();
            throw new RuntimeException("操作被中断");
        } catch (Exception e) {
            log.error("扣减库存失败", e);
            throw new RuntimeException(e.getMessage());
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    /**
     * 库存移动（货位调拨）
     * @param request 移动请求
     * @return 是否成功
     */
    @Transactional(rollbackFor = Exception.class)
    public boolean moveInventory(InventoryMoveRequest request) {
        String lockKey = "inventory:move:" + request.getInventoryId();
        RLock lock = redissonClient.getLock(lockKey);

        log.info("开始库存移动，inventoryId={}, fromLocation={}, toLocation={}, quantity={}",
                request.getInventoryId(), request.getFromLocationId(), request.getToLocationId(), request.getQuantity());

        try {
            boolean locked = lock.tryLock(5, 10, TimeUnit.SECONDS);
            if (!locked) {
                throw new RuntimeException("系统繁忙，请稍后重试");
            }

            Inventory sourceInventory = inventoryMapper.selectById(request.getInventoryId());
            if (sourceInventory == null) {
                throw new RuntimeException("源库存不存在");
            }

            // 检查源库存数量
            int availableQuantity = sourceInventory.getQuantity() - sourceInventory.getLockedQuantity();
            if (availableQuantity < request.getQuantity()) {
                throw new RuntimeException("源库存不足，可用数量：" + availableQuantity);
            }

            // 检查目标货位是否存在
            Location targetLocation = locationMapper.selectById(request.getToLocationId());
            if (targetLocation == null) {
                throw new RuntimeException("目标货位不存在");
            }

            // 减少源库存
            sourceInventory.setQuantity(sourceInventory.getQuantity() - request.getQuantity());
            inventoryMapper.updateById(sourceInventory);

            // 查找目标货位是否有相同SKU的库存
            Inventory targetInventory = inventoryMapper.selectOne(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getTenantId, TenantContextHolder.getTenantId())
                            .eq(Inventory::getSkuCode, sourceInventory.getSkuCode())
                            .eq(Inventory::getLocationId, request.getToLocationId())
                            .eq(Inventory::getBatchNo, sourceInventory.getBatchNo())
            );

            if (targetInventory == null) {
                // 创建新库存记录
                targetInventory = new Inventory();
                targetInventory.setTenantId(TenantContextHolder.getTenantId());
                targetInventory.setSkuCode(sourceInventory.getSkuCode());
                targetInventory.setSkuName(sourceInventory.getSkuName());
                targetInventory.setLocationId(request.getToLocationId());
                targetInventory.setBatchNo(sourceInventory.getBatchNo());
                targetInventory.setQuantity(request.getQuantity());
                targetInventory.setLockedQuantity(0);
                targetInventory.setProductionDate(sourceInventory.getProductionDate());
                targetInventory.setExpiryDate(sourceInventory.getExpiryDate());
                inventoryMapper.insert(targetInventory);
            } else {
                // 增加目标库存
                targetInventory.setQuantity(targetInventory.getQuantity() + request.getQuantity());
                inventoryMapper.updateById(targetInventory);
            }

            log.info("库存移动成功，从货位{}移动到货位{}，数量{}",
                    request.getFromLocationId(), request.getToLocationId(), request.getQuantity());

            return true;

        } catch (InterruptedException e) {
            log.error("获取分布式锁被中断", e);
            Thread.currentThread().interrupt();
            throw new RuntimeException("操作被中断");
        } catch (Exception e) {
            log.error("库存移动失败", e);
            throw new RuntimeException(e.getMessage());
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    /**
     * 查询冻结记录
     * @param orderNo 订单号
     * @return 冻结记录列表
     */
    public List<InventoryFreezeLog> getFreezeLogs(String orderNo) {
        Long tenantId = TenantContextHolder.getTenantId();
        LambdaQueryWrapper<InventoryFreezeLog> wrapper = new LambdaQueryWrapper<InventoryFreezeLog>()
                .eq(InventoryFreezeLog::getTenantId, tenantId);
        if (orderNo != null && !orderNo.isEmpty()) {
            wrapper.eq(InventoryFreezeLog::getOrderNo, orderNo);
        }
        return freezeLogMapper.selectList(wrapper.orderByDesc(InventoryFreezeLog::getCreateTime));
    }
}