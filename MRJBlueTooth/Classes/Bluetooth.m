//  Created by 余洪江 on  17/07/17.
//  Copyright (c) 2015年 余洪江. All rights reserved.

#import "Bluetooth.h"

@implementation Bluetooth{
    CentralManager *centralManager;
    PeripheralManager *peripheralManager;
    Speaker *speaker;
    int CENTRAL_MANAGER_INIT_WAIT_TIMES;
    NSTimer *timerForStop;
}

//单例模式
+ (instancetype)shareBabyBluetooth {
    static Bluetooth *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[Bluetooth alloc]init];
    });
   return share;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //初始化对象
        centralManager = [[CentralManager alloc]init];
        speaker = [[Speaker alloc]init];
        centralManager->speaker = speaker;
        peripheralManager = [[PeripheralManager alloc]init];
        peripheralManager->speaker = speaker;
    }
    return self;
}

#pragma mark - bluetooth的委托

/*
 默认频道的委托
 */
//设备状态改变的委托
- (void)setBlockOnCentralManagerDidUpdateState:(void (^)(CBCentralManager *central))block {
    [[speaker callback]setBlockOnCentralManagerDidUpdateState:block];
}

//找到Peripherals的委托
- (void)setBlockOnDiscoverToPeripherals:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block{
    [[speaker callback]setBlockOnDiscoverPeripherals:block];
}

//连接Peripherals成功的委托
- (void)setBlockOnConnected:(void (^)(CBCentralManager *central,CBPeripheral *peripheral))block {
    [[speaker callback]setBlockOnConnectedPeripheral:block];
}

//连接Peripherals失败的委托
- (void)setBlockOnFailToConnect:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[speaker callback]setBlockOnFailToConnect:block];
}

//断开Peripherals的连接
- (void)setBlockOnDisconnect:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[speaker callback]setBlockOnDisconnect:block];
}

//设置查找服务回叫
- (void)setBlockOnDiscoverServices:(void (^)(CBPeripheral *peripheral,NSError *error))block {
    [[speaker callback]setBlockOnDiscoverServices:block];
}

//设置查找到Characteristics的block
- (void)setBlockOnDiscoverCharacteristics:(void (^)(CBPeripheral *peripheral,CBService *service,NSError *error))block {
    [[speaker callback]setBlockOnDiscoverCharacteristics:block];
}

//设置获取到最新Characteristics值的block
- (void)setBlockOnReadValueForCharacteristic:(void (^)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error))block {
    [[speaker callback]setBlockOnReadValueForCharacteristic:block];
}

//设置查找到Characteristics描述的block
- (void)setBlockOnDiscoverDescriptorsForCharacteristic:(void (^)(CBPeripheral *peripheral,CBCharacteristic *service,NSError *error))block {
    [[speaker callback]setBlockOnDiscoverDescriptorsForCharacteristic:block];
}

//设置读取到Characteristics描述的值的block
- (void)setBlockOnReadValueForDescriptors:(void (^)(CBPeripheral *peripheral,CBDescriptor *descriptor,NSError *error))block {
    [[speaker callback]setBlockOnReadValueForDescriptors:block];
}

//写Characteristic成功后的block
- (void)setBlockOnDidWriteValueForCharacteristic:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[speaker callback]setBlockOnDidWriteValueForCharacteristic:block];
}

//写descriptor成功后的block
- (void)setBlockOnDidWriteValueForDescriptor:(void (^)(CBDescriptor *descriptor,NSError *error))block {
    [[speaker callback]setBlockOnDidWriteValueForDescriptor:block];
}

//characteristic订阅状态改变的block
- (void)setBlockOnDidUpdateNotificationStateForCharacteristic:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[speaker callback]setBlockOnDidUpdateNotificationStateForCharacteristic:block];
}

//读取RSSI的委托
- (void)setBlockOnDidReadRSSI:(void (^)(NSNumber *RSSI,NSError *error))block {
    [[speaker callback]setBlockOnDidReadRSSI:block];
}

//discoverIncludedServices的回调，暂时在bluetooth中无作用
- (void)setBlockOnDidDiscoverIncludedServicesForService:(void (^)(CBService *service,NSError *error))block {
    [[speaker callback]setBlockOnDidDiscoverIncludedServicesForService:block];
}

//外设更新名字后的block
- (void)setBlockOnDidUpdateName:(void (^)(CBPeripheral *peripheral))block {
    [[speaker callback]setBlockOnDidUpdateName:block];
}

//外设更新服务后的block
- (void)setBlockOnDidModifyServices:(void (^)(CBPeripheral *peripheral,NSArray *invalidatedServices))block {
    [[speaker callback]setBlockOnDidModifyServices:block];
}

//设置蓝牙使用的参数参数
- (void)setBabyOptionsWithScanForPeripheralsWithOptions:(NSDictionary *) scanForPeripheralsWithOptions
                          connectPeripheralWithOptions:(NSDictionary *) connectPeripheralWithOptions
                        scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
                                  discoverWithServices:(NSArray *)discoverWithServices
                           discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics {
    Options *option = [[Options alloc]initWithscanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectPeripheralWithOptions scanForPeripheralsWithServices:scanForPeripheralsWithServices discoverWithServices:discoverWithServices discoverWithCharacteristics:discoverWithCharacteristics];
    [[speaker callback]setOptions:option];
}

/*
 channel的委托
 */
/// 设备状态改变的委托
- (void)setBlockOnCentralManagerDidUpdateStateAtChannel:(NSString *)channel
                                                 block:(void (^)(CBCentralManager *central))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCentralManagerDidUpdateState:block];
}

/// 找到Peripherals的委托
- (void)setBlockOnDiscoverToPeripheralsAtChannel:(NSString *)channel
                                          block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverPeripherals:block];
}

/// 连接Peripherals成功的委托
- (void)setBlockOnConnectedAtChannel:(NSString *)channel
                              block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnConnectedPeripheral:block];
}

/// 连接Peripherals失败的委托
- (void)setBlockOnFailToConnectAtChannel:(NSString *)channel
                                  block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnFailToConnect:block];
}

/// 断开Peripherals的连接
- (void)setBlockOnDisconnectAtChannel:(NSString *)channel
                               block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDisconnect:block];
}

/// 设置查找服务回叫
- (void)setBlockOnDiscoverServicesAtChannel:(NSString *)channel
                                     block:(void (^)(CBPeripheral *peripheral,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverServices:block];
}

/// 设置查找到Characteristics的block
- (void)setBlockOnDiscoverCharacteristicsAtChannel:(NSString *)channel
                                            block:(void (^)(CBPeripheral *peripheral,CBService *service,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverCharacteristics:block];
}

/// 设置获取到最新Characteristics值的block
- (void)setBlockOnReadValueForCharacteristicAtChannel:(NSString *)channel
                                               block:(void (^)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnReadValueForCharacteristic:block];
}

/// 设置查找到Characteristics描述的block
- (void)setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:(NSString *)channel
                                                         block:(void (^)(CBPeripheral *peripheral,CBCharacteristic *service,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnDiscoverDescriptorsForCharacteristic:block];
}

/// 设置读取到Characteristics描述的值的block
- (void)setBlockOnReadValueForDescriptorsAtChannel:(NSString *)channel
                                            block:(void (^)(CBPeripheral *peripheral,CBDescriptor *descriptor,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnReadValueForDescriptors:block];
}

/// 写Characteristic成功后的block
- (void)setBlockOnDidWriteValueForCharacteristicAtChannel:(NSString *)channel
                                                        block:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidWriteValueForCharacteristic:block];
}

/// 写descriptor成功后的block
- (void)setBlockOnDidWriteValueForDescriptorAtChannel:(NSString *)channel
                                      block:(void (^)(CBDescriptor *descriptor,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidWriteValueForDescriptor:block];
}

/// characteristic订阅状态改变的block
- (void)setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:(NSString *)channel
                                                                     block:(void (^)(CBCharacteristic *characteristic,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidUpdateNotificationStateForCharacteristic:block];
}

/// 读取RSSI的委托
- (void)setBlockOnDidReadRSSIAtChannel:(NSString *)channel
                                block:(void (^)(NSNumber *RSSI,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidReadRSSI:block];
}

/// discoverIncludedServices的回调，暂时在bluetooth中无作用
- (void)setBlockOnDidDiscoverIncludedServicesForServiceAtChannel:(NSString *)channel
                                                          block:(void (^)(CBService *service,NSError *error))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidDiscoverIncludedServicesForService:block];
}

/// 外设更新名字后的block
- (void)setBlockOnDidUpdateNameAtChannel:(NSString *)channel
                                  block:(void (^)(CBPeripheral *peripheral))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidUpdateName:block];
}

/// 外设更新服务后的block
- (void)setBlockOnDidModifyServicesAtChannel:(NSString *)channel
                                      block:(void (^)(CBPeripheral *peripheral,NSArray *invalidatedServices))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES]setBlockOnDidModifyServices:block];
}

/// 设置蓝牙运行时的参数
- (void)setBabyOptionsAtChannel:(NSString *)channel
 scanForPeripheralsWithOptions:(NSDictionary *) scanForPeripheralsWithOptions
  connectPeripheralWithOptions:(NSDictionary *) connectPeripheralWithOptions
    scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
          discoverWithServices:(NSArray *)discoverWithServices
   discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics {
    
    Options *option = [[Options alloc]initWithscanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectPeripheralWithOptions scanForPeripheralsWithServices:scanForPeripheralsWithServices discoverWithServices:discoverWithServices discoverWithCharacteristics:discoverWithCharacteristics];
     [[speaker callbackOnChnnel:channel createWhenNotExist:YES]setOptions:option];
}

#pragma mark - bluetooth filter委托
/// 设置查找Peripherals的规则
- (void)setFilterOnDiscoverPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[speaker callback]setFilterOnDiscoverPeripherals:filter];
}

/// 设置连接Peripherals的规则
- (void)setFilterOnConnectToPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[speaker callback]setFilterOnconnectToPeripherals:filter];
}

/// 设置查找Peripherals的规则
- (void)setFilterOnDiscoverPeripheralsAtChannel:(NSString *)channel
                                      filter:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setFilterOnDiscoverPeripherals:filter];
}

/// 设置连接Peripherals的规则
- (void)setFilterOnConnectToPeripheralsAtChannel:(NSString *)channel
                                     filter:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setFilterOnconnectToPeripherals:filter];
}

#pragma mark - bluetooth Special
/// Bluettooth cancelScan方法调用后的回调
- (void)setBlockOnCancelScanBlock:(void(^)(CBCentralManager *centralManager))block {
    [[speaker callback]setBlockOnCancelScan:block];
}

/// Bluettooth cancelAllPeripheralsConnectionBlock 方法调用后的回调
- (void)setBlockOnCancelAllPeripheralsConnectionBlock:(void(^)(CBCentralManager *centralManager))block{
    [[speaker callback]setBlockOnCancelAllPeripheralsConnection:block];
}

/// Bluettooth cancelScan方法调用后的回调
- (void)setBlockOnCancelScanBlockAtChannel:(NSString *)channel
                                    block:(void(^)(CBCentralManager *centralManager))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCancelScan:block];
}

/// Bluettooth cancelAllPeripheralsConnectionBlock 方法调用后的回调
- (void)setBlockOnCancelAllPeripheralsConnectionBlockAtChannel:(NSString *)channel
                                                        block:(void(^)(CBCentralManager *centralManager))block {
    [[speaker callbackOnChnnel:channel createWhenNotExist:YES] setBlockOnCancelAllPeripheralsConnection:block];
}

#pragma mark - 链式函数

/// 查找Peripherals
- (Bluetooth *(^)()) scanForPeripherals {
    return ^Bluetooth *() {
        [centralManager->pocket setObject:@"YES" forKey:@"needScanForPeripherals"];
        return self;
    };
}

/// 连接Peripherals
- (Bluetooth *(^)()) connectToPeripherals {
    return ^Bluetooth *() {
        [centralManager->pocket setObject:@"YES" forKey:@"needConnectPeripheral"];
        return self;
    };
}

/// 发现Services
- (Bluetooth *(^)()) discoverServices {
    return ^Bluetooth *() {
        [centralManager->pocket setObject:@"YES" forKey:@"needDiscoverServices"];
        return self;
    };
}

/// 获取Characteristics
- (Bluetooth *(^)()) discoverCharacteristics {
    return ^Bluetooth *() {
        [centralManager->pocket setObject:@"YES" forKey:@"needDiscoverCharacteristics"];
        return self;
    };
}

/// 更新Characteristics的值
- (Bluetooth *(^)()) readValueForCharacteristic {
    return ^Bluetooth *() {
        [centralManager->pocket setObject:@"YES" forKey:@"needReadValueForCharacteristic"];
        return self;
    };
}

/// 设置查找到Descriptors名称的block
- (Bluetooth *(^)()) discoverDescriptorsForCharacteristic {
    return ^Bluetooth *() {
        [centralManager->pocket setObject:@"YES" forKey:@"needDiscoverDescriptorsForCharacteristic"];
        return self;
    };
}

/// 设置读取到Descriptors值的block
- (Bluetooth *(^)()) readValueForDescriptors {
    return ^Bluetooth *() {
        [centralManager->pocket setObject:@"YES" forKey:@"needReadValueForDescriptors"];
        return self;
    };
}

/// 开始并执行
- (Bluetooth *(^)()) begin {
    return ^Bluetooth *() {
        //取消未执行的stop定时任务
        [timerForStop invalidate];
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self resetSeriseParmeter];
            //处理链式函数缓存的数据
            if ([[centralManager->pocket valueForKey:@"needScanForPeripherals"] isEqualToString:@"YES"]) {
                centralManager->needScanForPeripherals = YES;
            }
            if ([[centralManager->pocket valueForKey:@"needConnectPeripheral"] isEqualToString:@"YES"]) {
                centralManager->needConnectPeripheral = YES;
            }
            if ([[centralManager->pocket valueForKey:@"needDiscoverServices"] isEqualToString:@"YES"]) {
                centralManager->needDiscoverServices = YES;
            }
            if ([[centralManager->pocket valueForKey:@"needDiscoverCharacteristics"] isEqualToString:@"YES"]) {
                centralManager->needDiscoverCharacteristics = YES;
            }
            if ([[centralManager->pocket valueForKey:@"needReadValueForCharacteristic"] isEqualToString:@"YES"]) {
                centralManager->needReadValueForCharacteristic = YES;
            }
            if ([[centralManager->pocket valueForKey:@"needDiscoverDescriptorsForCharacteristic"] isEqualToString:@"YES"]) {
                centralManager->needDiscoverDescriptorsForCharacteristic = YES;
            }
            if ([[centralManager->pocket valueForKey:@"needReadValueForDescriptors"] isEqualToString:@"YES"]) {
                centralManager->needReadValueForDescriptors = YES;
            }
            //调整委托方法的channel，如果没设置默认为缺省频道
            NSString *channel = [centralManager->pocket valueForKey:@"channel"];
            [speaker switchChannel:channel];
            //缓存的peripheral
            CBPeripheral *cachedPeripheral = [centralManager->pocket valueForKey:NSStringFromClass([CBPeripheral class])];
            //校验series合法性
            [self validateProcess];
            //清空pocjet
            centralManager->pocket = [[NSMutableDictionary alloc]init];
            //开始扫描或连接设备
            [self start:cachedPeripheral];
        });
        return self;
    };
}

/// 私有方法，扫描或连接设备
- (void)start:(CBPeripheral *)cachedPeripheral {
    if (centralManager->centralManager.state == CBCentralManagerStatePoweredOn) {
        CENTRAL_MANAGER_INIT_WAIT_TIMES = 0;
        //扫描后连接
        if (centralManager->needScanForPeripherals) {
            //开始扫描peripherals
            [centralManager scanPeripherals];
        }
        //直接连接
        else {
            if (cachedPeripheral) {
                [centralManager connectToPeripheral:cachedPeripheral];
            }
        }
        return;
    }
    //尝试重新等待CBCentralManager打开
    CENTRAL_MANAGER_INIT_WAIT_TIMES ++;
    if (CENTRAL_MANAGER_INIT_WAIT_TIMES >= K_CENTRAL_MANAGER_INIT_WAIT_TIMES ) {
        MRJLog(@">>> 第%d次等待CBCentralManager 打开任然失败，请检查你蓝牙使用权限或检查设备问题。",CENTRAL_MANAGER_INIT_WAIT_TIMES);
        return;
        //[NSException raise:@"CBCentralManager打开异常" format:@"尝试等待打开CBCentralManager5次，但任未能打开"];
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, K_CENTRAL_MANAGER_INIT_WAIT_SECOND * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self start:cachedPeripheral];
    });
    MRJLog(@">>> 第%d次等待CBCentralManager打开",CENTRAL_MANAGER_INIT_WAIT_TIMES);
}

/// sec秒后停止
- (Bluetooth *(^)(int sec)) stop {
    
    return ^Bluetooth *(int sec) {
        MRJLog(@">>> stop in %d sec",sec);
        
        //听见定时器执行Stop
        timerForStop = [NSTimer timerWithTimeInterval:sec target:self selector:@selector(Stop) userInfo:nil repeats:NO];
        [timerForStop setFireDate: [[NSDate date]dateByAddingTimeInterval:sec]];
        [[NSRunLoop currentRunLoop] addTimer:timerForStop forMode:NSRunLoopCommonModes];
        
        return self;
    };
}

/// 私有方法，停止扫描和断开连接，清空pocket
- (void)Stop {
    MRJLog(@">>>did stop");
    [timerForStop invalidate];
    [self resetSeriseParmeter];
    centralManager->pocket = [[NSMutableDictionary alloc]init];
    //停止扫描，断开连接
    [centralManager cancelScan];
    [centralManager cancelAllPeripheralsConnection];
}

/// 重置串行方法参数
- (void)resetSeriseParmeter {
    centralManager->needScanForPeripherals = NO;
    centralManager->needConnectPeripheral = NO;
    centralManager->needDiscoverServices = NO;
    centralManager->needDiscoverCharacteristics = NO;
    centralManager->needReadValueForCharacteristic = NO;
    centralManager->needDiscoverDescriptorsForCharacteristic = NO;
    centralManager->needReadValueForDescriptors = NO;
}

/// 持有对象
- (Bluetooth *(^)(id obj)) having {
    return ^(id obj) {
        [centralManager->pocket setObject:obj forKey:NSStringFromClass([obj class])];
        return self;
    };
}


/// 切换委托频道
- (Bluetooth *(^)(NSString *channel)) channel {
    return ^Bluetooth *(NSString *channel) {
        //先缓存数据，到begin方法统一处理
        [centralManager->pocket setValue:channel forKey:@"channel"];
        return self;
    };
}

- (void)validateProcess {
    NSMutableArray *faildReason = [[NSMutableArray alloc]init];
    //规则：不执行discoverDescriptorsForCharacteristic()时，不能执行readValueForDescriptors()
    if (!centralManager->needDiscoverDescriptorsForCharacteristic) {
        if (centralManager->needReadValueForDescriptors) {
            [faildReason addObject:@"未执行discoverDescriptorsForCharacteristic()不能执行readValueForDescriptors()"];
        }
    }
    
    //规则：不执行discoverCharacteristics()时，不能执行readValueForCharacteristic()或者是discoverDescriptorsForCharacteristic()
    if (!centralManager->needDiscoverCharacteristics) {
        if (centralManager->needReadValueForCharacteristic||centralManager->needDiscoverDescriptorsForCharacteristic) {
            [faildReason addObject:@"未执行discoverCharacteristics()不能执行readValueForCharacteristic()或discoverDescriptorsForCharacteristic()"];
        }
    }
    
    //规则： 不执行discoverServices()不能执行discoverCharacteristics()、readValueForCharacteristic()、discoverDescriptorsForCharacteristic()、readValueForDescriptors()
    if (!centralManager->needDiscoverServices) {
        if (centralManager->needDiscoverCharacteristics||centralManager->needDiscoverDescriptorsForCharacteristic ||centralManager->needReadValueForCharacteristic ||centralManager->needReadValueForDescriptors) {
             [faildReason addObject:@"未执行discoverServices()不能执行discoverCharacteristics()、readValueForCharacteristic()、discoverDescriptorsForCharacteristic()、readValueForDescriptors()"];
        }
        
    }

    //规则：不执行connectToPeripherals()时，不能执行discoverServices()
    if(!centralManager->needConnectPeripheral) {
        if (centralManager->needDiscoverServices) {
             [faildReason addObject:@"未执行connectToPeripherals()不能执行discoverServices()"];
        }
    }
    
    //规则：不执行needScanForPeripherals()，那么执行connectToPeripheral()方法时必须用having(peripheral)传入peripheral实例
    if (!centralManager->needScanForPeripherals) {
        CBPeripheral *peripheral = [centralManager->pocket valueForKey:NSStringFromClass([CBPeripheral class])];
        if (!peripheral) {
            [faildReason addObject:@"若不执行scanForPeripherals()方法，则必须执行connectToPeripheral方法并且需要传入参数(CBPeripheral *)peripheral"];
        }
    }
    
    //抛出异常
    if ([faildReason lastObject]) {
        NSException *e = [NSException exceptionWithName:@"BadyBluetooth usage exception" reason:[faildReason lastObject]  userInfo:nil];
        @throw e;
    }
  
}

- (Bluetooth *) and {
    return self;
}

- (Bluetooth *) then {
    return self;
}

- (Bluetooth *) with {
    return self;
}

- (Bluetooth *(^)()) enjoy {
    return ^Bluetooth *(int sec) {
        self.connectToPeripherals().discoverServices().discoverCharacteristics()
        .readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
        return self;
    };
}

#pragma mark - 工具方法

/// 断开连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    [centralManager cancelPeripheralConnection:peripheral];
}

//断开所有连接
- (void)cancelAllPeripheralsConnection {
    [centralManager cancelAllPeripheralsConnection];
}
//停止扫描
- (void)cancelScan{
    [centralManager cancelScan];
}
//读取Characteristic的详细信息
- (Bluetooth *(^)(CBPeripheral *peripheral,CBCharacteristic *characteristic)) characteristicDetails {
    //切换频道
    [speaker switchChannel:[centralManager->pocket valueForKey:@"channel"]];
    centralManager->pocket = [[NSMutableDictionary alloc]init];
    
    return ^(CBPeripheral *peripheral,CBCharacteristic *characteristic) {
        //判断连接状态
        if (peripheral.state == CBPeripheralStateConnected) {
            self->centralManager->oneReadValueForDescriptors = YES;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
        }
        else {
            MRJLog(@"!!!设备当前处于非连接状态");
        }
        
        return self;
    };
}

- (void)notify:(CBPeripheral *)peripheral
characteristic:(CBCharacteristic *)characteristic
        block:(void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))block {
    //设置通知
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    [speaker addNotifyCallback:characteristic withBlock:block];
}

- (void)cancelNotify:(CBPeripheral *)peripheral
     characteristic:(CBCharacteristic *)characteristic {
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
    [speaker removeNotifyCallback:characteristic];
}

//获取当前连接的peripherals
- (NSArray *)findConnectedPeripherals {
     return [centralManager findConnectedPeripherals];
}

//获取当前连接的peripheral
- (CBPeripheral *)findConnectedPeripheral:(NSString *)peripheralName {
     return [centralManager findConnectedPeripheral:peripheralName];
}

//获取当前corebluetooth的centralManager对象
- (CBCentralManager *)centralManager {
    return centralManager->centralManager;
}

/**
 添加断开自动重连的外设
 */
- (void)AutoReconnect:(CBPeripheral *)peripheral{
    [centralManager sometimes_ever:peripheral];
}

/**
 删除断开自动重连的外设
 */
- (void)AutoReconnectCancel:(CBPeripheral *)peripheral{
    [centralManager sometimes_never:peripheral];
}
 
- (CBPeripheral *)retrievePeripheralWithUUIDString:(NSString *)UUIDString {
    CBPeripheral *p = nil;
    @try {
        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:UUIDString];
        p = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuid]][0];
    } @catch (NSException *exception) {
        MRJLog(@">>> retrievePeripheralWithUUIDString error:%@",exception)
    } @finally {
    }
    return p;
}

#pragma mark - peripheral model

//进入外设模式

- (CBPeripheralManager *)peripheralManager {
    return peripheralManager.peripheralManager;
}

- (PeripheralManager *(^)()) bePeripheral {
    return ^PeripheralManager* () {
        return peripheralManager;
    };
}
- (PeripheralManager *(^)(NSString *localName)) bePeripheralWithName {
    return ^PeripheralManager* (NSString *localName) {
        peripheralManager.localName = localName;
        return peripheralManager;
    };
}

- (void)peripheralModelBlockOnPeripheralManagerDidUpdateState:(void(^)(CBPeripheralManager *peripheral))block {
    [[speaker callback]setBlockOnPeripheralModelDidUpdateState:block];
}

- (void)peripheralModelBlockOnDidAddService:(void(^)(CBPeripheralManager *peripheral,CBService *service,NSError *error))block {
    [[speaker callback]setBlockOnPeripheralModelDidAddService:block];
}

- (void)peripheralModelBlockOnDidStartAdvertising:(void(^)(CBPeripheralManager *peripheral,NSError *error))block {
    [[speaker callback]setBlockOnPeripheralModelDidStartAdvertising:block];
}

- (void)peripheralModelBlockOnDidReceiveReadRequest:(void(^)(CBPeripheralManager *peripheral,CBATTRequest *request))block {
    [[speaker callback]setBlockOnPeripheralModelDidReceiveReadRequest:block];
}

- (void)peripheralModelBlockOnDidReceiveWriteRequests:(void(^)(CBPeripheralManager *peripheral,NSArray *requests))block {
    [[speaker callback]setBlockOnPeripheralModelDidReceiveWriteRequests:block];
}

- (void)peripheralModelBlockOnIsReadyToUpdateSubscribers:(void(^)(CBPeripheralManager *peripheral))block {
    [[speaker callback]setBlockOnPeripheralModelIsReadyToUpdateSubscribers:block];
}

- (void)peripheralModelBlockOnDidSubscribeToCharacteristic:(void(^)(CBPeripheralManager *peripheral,CBCentral *central,CBCharacteristic *characteristic))block {
    [[speaker callback]setBlockOnPeripheralModelDidSubscribeToCharacteristic:block];
}

- (void)peripheralModelBlockOnDidUnSubscribeToCharacteristic:(void(^)(CBPeripheralManager *peripheral,CBCentral *central,CBCharacteristic *characteristic))block {
    [[speaker callback]setBlockOnPeripheralModelDidUnSubscribeToCharacteristic:block];
}

@end


