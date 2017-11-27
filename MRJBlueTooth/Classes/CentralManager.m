/*
 Bluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth  
 */

//  Created by 余洪江 on  17/07/17.
//  Copyright (c) 2015年 余洪江. All rights reserved.
//

#import "CentralManager.h"
#import "Callback.h"

@implementation CentralManager

#define currChannel [speaker callbackOnCurrChannel]

- (instancetype)init {
    self = [super init];
    if (self) {
#if  __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_0
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 //蓝牙power没打开时alert提示框
                                 [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                                 //重设centralManager恢复的IdentifierKey
                                 @"BluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
                                 nil];
        
#else
        NSDictionary *options = nil;
#endif
        
        NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"bluetooth-central"]) {
            //后台模式
            centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
        }
        else {
            //非后台模式
            centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        }
        //pocket
        pocket = [[NSMutableDictionary alloc]init];
        connectedPeripherals = [[NSMutableArray alloc]init];
        discoverPeripherals = [[NSMutableArray alloc]init];
        reConnectPeripherals = [[NSMutableArray alloc]init];
    }
    return  self;
}

#pragma mark - 接收到通知

//扫描Peripherals
- (void)scanPeripherals {
    [centralManager scanForPeripheralsWithServices:[currChannel options].scanForPeripheralsWithServices options:[currChannel options].scanForPeripheralsWithOptions];
}

//连接Peripherals
- (void)connectToPeripheral:(CBPeripheral *)peripheral{
    [centralManager connectPeripheral:peripheral options:[currChannel options].connectPeripheralWithOptions];
}

//断开设备连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    [centralManager cancelPeripheralConnection:peripheral];
}

//断开所有已连接的设备
- (void)cancelAllPeripheralsConnection {
    for (int i=0;i<connectedPeripherals.count;i++) {
        [centralManager cancelPeripheralConnection:connectedPeripherals[i]];
    }
}

//停止扫描
- (void)cancelScan {
    [centralManager stopScan];
    //停止扫描callback
    if([currChannel blockOnCancelScan]) {
        [currChannel blockOnCancelScan](centralManager);
    }
}

#pragma mark - CBCentralManagerDelegate委托方法

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    //发送通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtCentralManagerDidUpdateState object:@{@"central":central}];
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            MRJLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            MRJLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            MRJLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            MRJLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            MRJLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            MRJLog(@">>>CBCentralManagerStatePoweredOn");
            [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtCentralManagerEnable object:@{@"central":central}];
            break;
        default:
            break;
    }
    //状态改变callback
    if ([currChannel blockOnCentralManagerDidUpdateState]) {
        [currChannel blockOnCentralManagerDidUpdateState](central);
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    
}

//扫描到Peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    //日志
    //Log(@"当扫描到设备:%@",peripheral.name);
    [self addDiscoverPeripheral:peripheral];
    
    //发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidDiscoverPeripheral
                                                       object:@{@"central":central,@"peripheral":peripheral,@"advertisementData":advertisementData,@"RSSI":RSSI}];
    //扫描到设备callback
    if ([currChannel filterOnDiscoverPeripherals]) {
        if ([currChannel filterOnDiscoverPeripherals](peripheral.name,advertisementData,RSSI)) {
            if ([currChannel blockOnDiscoverPeripherals]) {
                [[speaker callbackOnCurrChannel] blockOnDiscoverPeripherals](central,peripheral,advertisementData,RSSI);
            }
        }
    }
    
    //处理连接设备
    if (needConnectPeripheral) {
        if ([currChannel filterOnconnectToPeripherals](peripheral.name,advertisementData,RSSI)) {
            [centralManager connectPeripheral:peripheral options:[currChannel options].connectPeripheralWithOptions];
            //开一个定时器监控连接超时的情况
            connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(disconnect:) userInfo:peripheral repeats:NO];
        }
    }
}

//停止扫描
- (void)disconnect:(id)sender {
    [centralManager stopScan];
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidConnectPeripheral
                                                       object:@{@"central":central,@"peripheral":peripheral}];
    //设置委托
    [peripheral setDelegate:self];
    
    //Log(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    [connectTimer invalidate];//停止时钟
    [self addPeripheral:peripheral];
    
    //执行回叫
    //扫描到设备callback
    if ([currChannel blockOnConnectedPeripheral]) {
        [currChannel blockOnConnectedPeripheral](central,peripheral);
    }
    //扫描外设的服务
    if (needDiscoverServices) {
        [peripheral discoverServices:[currChannel options].discoverWithServices];
        //discoverIncludedServices
    }
}

//连接到Peripherals-失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidFailToConnectPeripheral
                                                       object:@{@"central":central,@"peripheral":peripheral,@"error":error?error:@""}];
 
    //    Log(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
    if ([currChannel blockOnFailToConnect]) {
        [currChannel blockOnFailToConnect](central,peripheral,error);
    }
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidDisconnectPeripheral
                                                       object:@{@"central":central,@"peripheral":peripheral,@"error":error?error:@""}];
    //    Log(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    if (error) {
        MRJLog(@">>> didDisconnectPeripheral for %@ with error: %@", peripheral.name, [error localizedDescription]);
    }
    
    [self deletePeripheral:peripheral];
    if ([currChannel blockOnDisconnect]) {
        [currChannel blockOnDisconnect](central,peripheral,error);
    }
    //判断是否全部链接都已经段开,调用blockOnCancelAllPeripheralsConnection委托
    if ([self findConnectedPeripherals].count == 0) {
        //停止扫描callback
        if ([currChannel blockOnCancelAllPeripheralsConnection]) {
            [currChannel blockOnCancelAllPeripheralsConnection](centralManager);
        }
        //    MRJLog(@">>> stopConnectAllPerihperals");
    }
    //检查并重新连接需要重连的设备
    if ([reConnectPeripherals containsObject:peripheral]) {
        [self connectToPeripheral:peripheral];
    }
}

//扫描到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    //发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidDiscoverServices
                                                       object:@{@"peripheral":peripheral,@"error":error?error:@""}];
    
    //  MRJLog(@">>>扫描到服务：%@",peripheral.services);
    if (error) {
        MRJLog(@">>>didDiscoverServices for %@ with error: %@", peripheral.name, [error localizedDescription]);
    }
    //回叫block
    if ([currChannel blockOnDiscoverServices]) {
        [currChannel blockOnDiscoverServices](peripheral,error);
    }
    //discover characteristics
    if (needDiscoverCharacteristics) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:[currChannel options].discoverWithCharacteristics forService:service];
        }
    }
}

//发现服务的Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    //发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidDiscoverCharacteristicsForService
                                                       object:@{@"peripheral":peripheral,@"service":service,@"error":error?error:@""}];
    if (error) {
        MRJLog(@"error didDiscoverCharacteristicsForService for %@ with error: %@", service.UUID, [error localizedDescription]);
        //        return;
    }
    //回叫block
    if ([currChannel blockOnDiscoverCharacteristics]) {
        [currChannel blockOnDiscoverCharacteristics](peripheral,service,error);
    }
    //如果需要更新Characteristic的值
    if (needReadValueForCharacteristic) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    //如果搜索Characteristic的Descriptors
    if (needDiscoverDescriptorsForCharacteristic) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
        }
    }
}

//读取Characteristics的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidUpdateValueForCharacteristic
                                                       object:@{@"peripheral":peripheral,@"characteristic":characteristic,@"error":error?error:@""}];
    
    if (error) {
        MRJLog(@"error didUpdateValueForCharacteristic %@ with error: %@", characteristic.UUID, [error localizedDescription]);
    }
    //查找字段订阅
    if ([speaker notifyCallback:characteristic]) {
        [speaker notifyCallback:characteristic](peripheral,characteristic,error);
        return;
    }
    //回叫block
    if ([currChannel blockOnReadValueForCharacteristic]) {
        [currChannel blockOnReadValueForCharacteristic](peripheral,characteristic,error);
    }
}

//发现Characteristics的Descriptors
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        MRJLog(@"error Discovered DescriptorsForCharacteristic for %@ with error: %@", characteristic.UUID, [error localizedDescription]);
        //        return;
    }
    //回叫block
    if ([currChannel blockOnDiscoverDescriptorsForCharacteristic]) {
        [currChannel blockOnDiscoverDescriptorsForCharacteristic](peripheral,characteristic,error);
    }
    //如果需要更新Characteristic的Descriptors
    if (needReadValueForDescriptors) {
        for (CBDescriptor *d in characteristic.descriptors) {
            [peripheral readValueForDescriptor:d];
        }
    }
    
    //执行一次的方法
    if (oneReadValueForDescriptors) {
        for (CBDescriptor *d in characteristic.descriptors) {
            [peripheral readValueForDescriptor:d];
        }
        oneReadValueForDescriptors = NO;
    }
}

//读取Characteristics的Descriptors的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    if (error) {
        MRJLog(@"error didUpdateValueForDescriptor  for %@ with error: %@", descriptor.UUID, [error localizedDescription]);
    }
    //block
    if ([currChannel blockOnReadValueForDescriptors]) {
        [currChannel blockOnReadValueForDescriptors](peripheral,descriptor,error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidWriteValueForCharacteristic object:@{@"characteristic":characteristic,@"error":error?error:@""}];
    if ([currChannel blockOnDidWriteValueForCharacteristic]) {
        [currChannel blockOnDidWriteValueForCharacteristic](characteristic,error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    if ([currChannel blockOnDidWriteValueForDescriptor]) {
        [currChannel blockOnDidWriteValueForDescriptor](descriptor,error);
    }
}

//characteristic.isNotifying 状态改变
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidUpdateNotificationStateForCharacteristic object:@{@"characteristic":characteristic,@"error":error?error:@""}];
    MRJLog(@">>>didUpdateNotificationStateForCharacteristic");
    MRJLog(@">>>uuid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"isNotifying":@"Notifying");
    if ([currChannel blockOnDidUpdateNotificationStateForCharacteristic]) {
        [currChannel blockOnDidUpdateNotificationStateForCharacteristic](characteristic,error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    if ([currChannel blockOnDidDiscoverIncludedServicesForService]) {
        [currChannel blockOnDidDiscoverIncludedServicesForService](service,error);
    }
}

# if  __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidReadRSSI object:@{@"peripheral":peripheral,@"RSSI":peripheral.RSSI,@"error":error?error:@""}];
    MRJLog(@">>>peripheralDidUpdateRSSI -> RSSI:%@",peripheral.RSSI);
    if ([currChannel blockOnDidReadRSSI]) {
        [currChannel blockOnDidReadRSSI](peripheral.RSSI,error);
    }
}
#else
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationAtDidReadRSSI object:@{@"peripheral":peripheral,@"RSSI":RSSI?RSSI:@100,@"error":error?error:@""}];
    MRJLog(@">>>peripheralDidUpdateRSSI -> RSSI:%@",RSSI);
    if ([currChannel blockOnDidReadRSSI]) {
        [currChannel blockOnDidReadRSSI](RSSI,error);
    }
}
#endif

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    if ([currChannel blockOnDidUpdateName]) {
        [currChannel blockOnDidUpdateName](peripheral);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    if ([currChannel blockOnDidModifyServices]) {
        [currChannel blockOnDidModifyServices](peripheral,invalidatedServices);
    }
}

/**
 sometimes ever，sometimes never.  相聚有时，后会无期
 
 this is center with peripheral's story
 **/
//sometimes ever：添加断开重连接的设备
-  (void)sometimes_ever:(CBPeripheral *)peripheral {
    if (![reConnectPeripherals containsObject:peripheral]) {
        [reConnectPeripherals addObject:peripheral];
    }
}
//sometimes never：删除需要重连接的设备
-  (void)sometimes_never:(CBPeripheral *)peripheral {
    [reConnectPeripherals removeObject:peripheral];
}

#pragma mark - 私有方法
#pragma mark - 设备list管理

- (void)addDiscoverPeripheral:(CBPeripheral *)peripheral{
    if (![discoverPeripherals containsObject:peripheral]) {
        [discoverPeripherals addObject:peripheral];
    }
}

- (void)addPeripheral:(CBPeripheral *)peripheral {
    if (![connectedPeripherals containsObject:peripheral]) {
        [connectedPeripherals addObject:peripheral];
    }
}

- (void)deletePeripheral:(CBPeripheral *)peripheral{
    [connectedPeripherals removeObject:peripheral];
}

- (CBPeripheral *)findConnectedPeripheral:(NSString *)peripheralName {
    for (CBPeripheral *p in connectedPeripherals) {
        if ([p.name isEqualToString:peripheralName]) {
            return p;
        }
    }
    return nil;
}

- (NSArray *)findConnectedPeripherals{
    return connectedPeripherals;
}

@end
