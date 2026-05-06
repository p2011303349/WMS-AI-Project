package com.wms.util;

import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

public class SimulateDevice {

    public static void main(String[] args) {
        String broker = "tcp://localhost:1883";
        String clientId = "simulate_device";
        String topic = "/warehouse/sensor_01/sensor";

        try {
            MqttClient client = new MqttClient(broker, clientId, new MemoryPersistence());
            MqttConnectOptions options = new MqttConnectOptions();
            options.setCleanSession(true);
            client.connect(options);

            // 模拟发送数据
            for (int i = 0; i < 1000; i++) {
                float temperature = 20 + (float) Math.random() * 20;
                float humidity = 40 + (float) Math.random() * 40;
                String payload = String.format(
                        "{\"temperature\":%.1f,\"humidity\":%.1f,\"battery\":%.1f}",
                        temperature, humidity, 95.0
                );

                MqttMessage message = new MqttMessage(payload.getBytes());
                message.setQos(1);
                client.publish(topic, message);
                System.out.println("发送数据: " + payload);

                Thread.sleep(3000);
            }

            client.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}