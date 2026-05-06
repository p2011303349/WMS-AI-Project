package com.wms.controller;

import com.wms.dto.InventoryFreezeRequest;
import com.wms.dto.InventoryMoveRequest;
import com.wms.entity.Inventory;
import com.wms.entity.InventoryFreezeLog;
import com.wms.service.InventoryManageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/inventory/manage")
public class InventoryManageController {

    @Autowired
    private InventoryManageService inventoryManageService;

    /**
     * 冻结库存
     */
    @PostMapping("/freeze")
    public Map<String, Object> freeze(@RequestBody InventoryFreezeRequest request) {
        boolean success = inventoryManageService.freezeInventory(request);
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", success ? "冻结成功" : "冻结失败");
        return result;
    }

    /**
     * 解冻库存
     */
    @PostMapping("/unfreeze")
    public Map<String, Object> unfreeze(@RequestParam Long freezeLogId) {
        boolean success = inventoryManageService.unfreezeInventory(freezeLogId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", success ? "解冻成功" : "解冻失败");
        return result;
    }

    /**
     * 扣减库存
     */
    @PostMapping("/deduct")
    public Map<String, Object> deduct(@RequestParam Long inventoryId,
                                      @RequestParam Integer quantity,
                                      @RequestParam String orderNo) {
        boolean success = inventoryManageService.deductInventory(inventoryId, quantity, orderNo);
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", success ? "扣减成功" : "扣减失败");
        return result;
    }

    /**
     * 库存移动
     */
    @PostMapping("/move")
    public Map<String, Object> move(@RequestBody InventoryMoveRequest request) {
        boolean success = inventoryManageService.moveInventory(request);
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", success ? "移动成功" : "移动失败");
        return result;
    }

    /**
     * 查询冻结记录
     */
    @GetMapping("/freeze-logs")
    public List<InventoryFreezeLog> getFreezeLogs(@RequestParam(required = false) String orderNo) {
        return inventoryManageService.getFreezeLogs(orderNo);
    }
}