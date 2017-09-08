/*
 Bluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth  
  
 
 @brief  bluetooth 的block定义和储存
 
 */

//  Created by 余洪江 on  17/07/17.
//  Copyright (c) 2015年 余洪江. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "Options.h"


//设备状态改变的委托
typedef void (^BBCentralManagerDidUpdateStateBlock)(CBCentralManager *central);
//找到设备的委托
typedef void (^BBDiscoverPeripheralsBlock)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI);
//连接设备成功的block
typedef void (^BBConnectedPeripheralBlock)(CBCentralManager *central,CBPeripheral *peripheral);
//连接设备失败的block
typedef void (^BBFailToConnectBlock)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error);
//断开设备连接的bock
typedef void (^BBDisconnectBlock)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error);
//找到服务的block
typedef void (^BBDiscoverServicesBlock)(CBPeripheral *peripheral,NSError *error);
//找到Characteristics的block
typedef void (^BBDiscoverCharacteristicsBlock)(CBPeripheral *peripheral,CBService *service,NSError *error);
//更新（获取）Characteristics的value的block
typedef void (^BBReadValueForCharacteristicBlock)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);
//获取Characteristics的名称
typedef void (^BBDiscoverDescriptorsForCharacteristicBlock)(CBPeripheral *peripheral,CBCharacteristic *service,NSError *error);
//获取Descriptors的值
typedef void (^BBReadValueForDescriptorsBlock)(CBPeripheral *peripheral,CBDescriptor *descriptor,NSError *error);

//Bluettooth cancelScanBlock方法调用后的回调
typedef void (^BBCancelScanBlock)(CBCentralManager *centralManager);
//Bluettooth cancelAllPeripheralsConnection 方法调用后的回调
typedef void (^BBCancelAllPeripheralsConnectionBlock)(CBCentralManager *centralManager);


typedef void (^BBDidWriteValueForCharacteristicBlock)(CBCharacteristic *characteristic,NSError *error);

typedef void (^BBDidWriteValueForDescriptorBlock)(CBDescriptor *descriptor,NSError *error);

typedef void (^BBDidUpdateNotificationStateForCharacteristicBlock)(CBCharacteristic *characteristic,NSError *error);

typedef void (^BBDidReadRSSIBlock)(NSNumber *RSSI,NSError *error);

typedef void (^BBDidDiscoverIncludedServicesForServiceBlock)(CBService *service,NSError *error);

typedef void (^BBDidUpdateNameBlock)(CBPeripheral *peripheral);

typedef void (^BBDidModifyServicesBlock)(CBPeripheral *peripheral,NSArray *invalidatedServices);


//peripheral model
typedef void (^BBPeripheralModelDidUpdateState)(CBPeripheralManager *peripheral);
typedef void (^BBPeripheralModelDidAddService)(CBPeripheralManager *peripheral,CBService *service,NSError *error);
typedef void (^BBPeripheralModelDidStartAdvertising)(CBPeripheralManager *peripheral,NSError *error);
typedef void (^BBPeripheralModelDidReceiveReadRequest)(CBPeripheralManager *peripheral,CBATTRequest *request);
typedef void (^BBPeripheralModelDidReceiveWriteRequests)(CBPeripheralManager *peripheral,NSArray *requests);
typedef void (^BBPeripheralModelIsReadyToUpdateSubscribers)(CBPeripheralManager *peripheral);
typedef void (^BBPeripheralModelDidSubscribeToCharacteristic)(CBPeripheralManager *peripheral,CBCentral *central,CBCharacteristic *characteristic);
typedef void (^BBPeripheralModelDidUnSubscribeToCharacteristic)(CBPeripheralManager *peripheral,CBCentral *central,CBCharacteristic *characteristic);



@interface Callback : NSObject

#pragma mark - callback block
//设备状态改变的委托
@property (nonatomic, copy) BBCentralManagerDidUpdateStateBlock blockOnCentralManagerDidUpdateState;
//发现peripherals
@property (nonatomic, copy) BBDiscoverPeripheralsBlock blockOnDiscoverPeripherals;
//连接callback
@property (nonatomic, copy) BBConnectedPeripheralBlock blockOnConnectedPeripheral;
//连接设备失败的block
@property (nonatomic, copy) BBFailToConnectBlock blockOnFailToConnect;
//断开设备连接的bock
@property (nonatomic, copy) BBDisconnectBlock blockOnDisconnect;
 //发现services
@property (nonatomic, copy) BBDiscoverServicesBlock blockOnDiscoverServices;
//发现Characteristics
@property (nonatomic, copy) BBDiscoverCharacteristicsBlock blockOnDiscoverCharacteristics;
//发现更新Characteristics的
@property (nonatomic, copy) BBReadValueForCharacteristicBlock blockOnReadValueForCharacteristic;
//获取Characteristics的名称
@property (nonatomic, copy) BBDiscoverDescriptorsForCharacteristicBlock blockOnDiscoverDescriptorsForCharacteristic;
//获取Descriptors的值
@property (nonatomic,copy) BBReadValueForDescriptorsBlock blockOnReadValueForDescriptors;

@property (nonatomic, copy) BBDidWriteValueForCharacteristicBlock blockOnDidWriteValueForCharacteristic;

@property (nonatomic, copy) BBDidWriteValueForDescriptorBlock blockOnDidWriteValueForDescriptor;

@property (nonatomic, copy) BBDidUpdateNotificationStateForCharacteristicBlock blockOnDidUpdateNotificationStateForCharacteristic;

@property (nonatomic, copy) BBDidReadRSSIBlock blockOnDidReadRSSI;

@property (nonatomic, copy) BBDidDiscoverIncludedServicesForServiceBlock blockOnDidDiscoverIncludedServicesForService;

@property (nonatomic, copy) BBDidUpdateNameBlock blockOnDidUpdateName;

@property (nonatomic, copy) BBDidModifyServicesBlock blockOnDidModifyServices;


//Bluettooth stopScan方法调用后的回调
@property(nonatomic,copy) BBCancelScanBlock blockOnCancelScan;
//Bluettooth stopConnectAllPerihperals 方法调用后的回调
@property(nonatomic,copy) BBCancelAllPeripheralsConnectionBlock blockOnCancelAllPeripheralsConnection;
//Bluettooth 蓝牙使用的参数参数
@property(nonatomic,strong) Options *Options;


#pragma mark - 过滤器Filter
//发现peripherals规则
@property (nonatomic, copy) BOOL (^filterOnDiscoverPeripherals)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);
//连接peripherals规则
@property (nonatomic, copy) BOOL (^filterOnconnectToPeripherals)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);


#pragma mark - peripheral model

//peripheral model

@property (nonatomic, copy) BBPeripheralModelDidUpdateState blockOnPeripheralModelDidUpdateState;
@property (nonatomic, copy) BBPeripheralModelDidAddService blockOnPeripheralModelDidAddService;
@property (nonatomic, copy) BBPeripheralModelDidStartAdvertising blockOnPeripheralModelDidStartAdvertising;
@property (nonatomic, copy) BBPeripheralModelDidReceiveReadRequest blockOnPeripheralModelDidReceiveReadRequest;
@property (nonatomic, copy) BBPeripheralModelDidReceiveWriteRequests blockOnPeripheralModelDidReceiveWriteRequests;
@property (nonatomic, copy) BBPeripheralModelIsReadyToUpdateSubscribers blockOnPeripheralModelIsReadyToUpdateSubscribers;
@property (nonatomic, copy) BBPeripheralModelDidSubscribeToCharacteristic blockOnPeripheralModelDidSubscribeToCharacteristic;
@property (nonatomic, copy) BBPeripheralModelDidUnSubscribeToCharacteristic blockOnPeripheralModelDidUnSubscribeToCharacteristic;

@end
