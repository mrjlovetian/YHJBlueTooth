/*
 Bluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth  
  
 
@brief  预定义一些库的执行行为和配置
 
 */

// Created by 余洪江 on  17/07/17.
//  Copyright © 2016年 liuyanwei. All rights reserved.
//  

#import <Foundation/Foundation.h>


# pragma mark -  行为定义

// if show log 是否打印日志，默认1：打印 ，0：不打印
#define K_IS_SHOW_LOG 1

//CBcentralManager等待设备打开次数
# define K_CENTRAL_MANAGER_INIT_WAIT_TIMES 5

//CBcentralManager等待设备打开间隔时间
# define K_CENTRAL_MANAGER_INIT_WAIT_SECOND 2.0

//Rhythm默认心跳时间间隔
#define KRHYTHM_BEATS_DEFAULT_INTERVAL 3;

//默认链式方法channel名称
#define K_DETAULT_CHANNEL @"Default"

# pragma mark - 通知

//蓝牙系统通知
//centralManager status did change notification
#define NotificationAtCentralManagerDidUpdateState @"NotificationAtCentralManagerDidUpdateState"
//did discover peripheral notification
#define NotificationAtDidDiscoverPeripheral @"NotificationAtDidDiscoverPeripheral"
//did connection peripheral notification
#define NotificationAtDidConnectPeripheral @"NotificationAtDidConnectPeripheral"
//did filed connect peripheral notification
#define NotificationAtDidFailToConnectPeripheral @"NotificationAtDidFailToConnectPeripheral"
//did disconnect peripheral notification
#define NotificationAtDidDisconnectPeripheral @"NotificationAtDidDisconnectPeripheral"
//did discover service notification
#define NotificationAtDidDiscoverServices @"NotificationAtDidDiscoverServices"
//did discover characteristics notification
#define NotificationAtDidDiscoverCharacteristicsForService @"NotificationAtDidDiscoverCharacteristicsForService"
//did read or notify characteristic when received value  notification
#define NotificationAtDidUpdateValueForCharacteristic @"NotificationAtDidUpdateValueForCharacteristic"
//did write characteristic and response value notification
#define NotificationAtDidWriteValueForCharacteristic @"NotificationAtDidWriteValueForCharacteristic"
//did change characteristis notify status notification
#define NotificationAtDidUpdateNotificationStateForCharacteristic @"NotificationAtDidUpdateNotificationStateForCharacteristic"
//did read rssi and receiced value notification
#define NotificationAtDidReadRSSI @"NotificationAtDidReadRSSI"

//蓝牙扩展通知
// did centralManager enable notification
#define NotificationAtCentralManagerEnable @"NotificationAtCentralManagerEnable"



# pragma mark -  定义的方法

// log
#define Log(fmt, ...) if(K_IS_SHOW_LOG) { NSLog(fmt,##__VA_ARGS__); }





@interface Define : NSObject

@end
