package com.wms.service;

import com.wms.entity.Location;
import com.wms.mapper.LocationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class PickingPathService {

    @Autowired
    private LocationMapper locationMapper;

    /**
     * 智能拣货路径规划 - 使用最近邻算法
     * @param locationCodes 需要拣货的货位编码列表
     * @return 优化后的拣货顺序
     */
    public List<String> optimizePickingPath(List<String> locationCodes) {
        if (locationCodes == null || locationCodes.size() <= 1) {
            return locationCodes;
        }

        // 获取所有货位坐标
        Map<String, Location> locationMap = new HashMap<>();
        List<Location> locations = locationMapper.selectList(null);
        for (Location loc : locations) {
            locationMap.put(loc.getLocationCode(), loc);
        }

        // 转换为坐标点
        List<Point> points = new ArrayList<>();
        for (String code : locationCodes) {
            Location loc = locationMap.get(code);
            if (loc != null) {
                points.add(new Point(code, getX(loc), getY(loc)));
            }
        }

        // 最近邻算法优化路径
        List<Point> optimized = nearestNeighbor(points);

        // 转换回货位编码
        List<String> result = new ArrayList<>();
        for (Point p : optimized) {
            result.add(p.code);
        }
        return result;
    }

    /**
     * 最近邻算法
     */
    private List<Point> nearestNeighbor(List<Point> points) {
        if (points.isEmpty()) return new ArrayList<>();

        List<Point> result = new ArrayList<>();
        Set<Point> visited = new HashSet<>();

        // 从原点(0,0)开始
        Point current = new Point("origin", 0, 0);

        while (result.size() < points.size()) {
            Point nearest = null;
            double minDistance = Double.MAX_VALUE;

            for (Point p : points) {
                if (!visited.contains(p)) {
                    double dist = distance(current, p);
                    if (dist < minDistance) {
                        minDistance = dist;
                        nearest = p;
                    }
                }
            }

            if (nearest != null) {
                result.add(nearest);
                visited.add(nearest);
                current = nearest;
            }
        }

        return result;
    }

    /**
     * 计算两点间距离（曼哈顿距离，适合仓库货位）
     */
    private double distance(Point a, Point b) {
        return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
    }

    private int getX(Location loc) {
        // 根据货位编码解析X坐标（排）
        try {
            return Integer.parseInt(loc.getRowNo() != null ? loc.getRowNo() : "0");
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private int getY(Location loc) {
        // 根据货位编码解析Y坐标（列）
        try {
            return Integer.parseInt(loc.getColNo() != null ? loc.getColNo() : "0");
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private static class Point {
        String code;
        int x, y;
        Point(String code, int x, int y) {
            this.code = code;
            this.x = x;
            this.y = y;
        }
    }
}