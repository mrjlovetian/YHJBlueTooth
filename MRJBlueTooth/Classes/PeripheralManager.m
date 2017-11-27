//
//  PeripheralManager.m
//  BluetoothStubOnIOS
//
//  Created by 余洪江 on  17/07/17.
//  Copyright © 2015年 余洪江. All rights reserved.
//

#import "PeripheralManager.h"
#import "Define.h"

#define callbackBlock(...) if ([[speaker callback] __VA_ARGS__])   [[speaker callback] __VA_ARGS__ ]

@implementation PeripheralManager {
    int PERIPHERAL_MANAGER_INIT_WAIT_TIMES;
    int didAddServices;
    NSTimer *addServiceTask;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _localName = @"-default-name";
        _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil options:nil];
    }
    return  self;    
}

- (PeripheralManager *(^)())startAdvertising {
    return ^PeripheralManager *() {
        
        if ([self canStartAdvertising]) {
            PERIPHERAL_MANAGER_INIT_WAIT_TIMES = 0;
            NSMutableArray *UUIDS = [NSMutableArray array];
            for (CBMutableService *s in _services) {
                [UUIDS addObject:s.UUID];
            }
            //启动广播
            if (_manufacturerData) {
                [_peripheralManager startAdvertising:
                 @{
                   CBAdvertisementDataServiceUUIDsKey :  UUIDS
                   ,CBAdvertisementDataLocalNameKey : _localName,
                   CBAdvertisementDataManufacturerDataKey:_manufacturerData
                }];
            } else {
                [_peripheralManager startAdvertising:
                 @{
                   CBAdvertisementDataServiceUUIDsKey :  UUIDS
                   ,CBAdvertisementDataLocalNameKey : _localName
                   }];
            }
          
        }
        else {
            PERIPHERAL_MANAGER_INIT_WAIT_TIMES++;
            if (PERIPHERAL_MANAGER_INIT_WAIT_TIMES > 5) {
                MRJLog(@">>>error： 第%d次等待peripheralManager打开任然失败，请检查蓝牙设备是否可用",PERIPHERAL_MANAGER_INIT_WAIT_TIMES);
            }
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.startAdvertising();
            });
            MRJLog(@">>> 第%d次等待peripheralManager打开",PERIPHERAL_MANAGER_INIT_WAIT_TIMES);
        }
        
        return self;
    };
}

- (PeripheralManager *(^)())stopAdvertising {
    return ^PeripheralManager*() {
        [_peripheralManager stopAdvertising];
        return self;
    };
}

- (BOOL)canStartAdvertising {
    if (_peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return NO;
    }
    if (didAddServices != _services.count) {
        return NO;
    }
    return YES;
}

- (BOOL)isPoweredOn {
    if (_peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return NO;
    }
    return YES;
}

- (PeripheralManager *(^)(NSArray *array))addServices {
    return ^PeripheralManager*(NSArray *array) {
        _services = [NSMutableArray arrayWithArray:array];
        [self addServicesToPeripheral];
        return self;
    };
}

- (PeripheralManager *(^)())removeAllServices {
    return ^PeripheralManager*() {
        didAddServices = 0;
        [_peripheralManager removeAllServices];
        return self;
    };
}

- (PeripheralManager *(^)(NSData *data))addManufacturerData {
    return ^PeripheralManager*(NSData *data) {
        _manufacturerData = data;
        return self;
    };
}

- (void)addServicesToPeripheral {
    if ([self isPoweredOn]) {
        for (CBMutableService *s in _services) {
            [_peripheralManager addService:s];
        }
    }
    else {
        [addServiceTask setFireDate:[NSDate distantPast]];
        addServiceTask = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(addServicesToPeripheral) userInfo:nil repeats:NO];
    }
}

#pragma mark - peripheralManager delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
            MRJLog(@">>>CBPeripheralManagerStateUnknown");
            break;
        case CBPeripheralManagerStateResetting:
            MRJLog(@">>>CBPeripheralManagerStateResetting");
            break;
        case CBPeripheralManagerStateUnsupported:
            MRJLog(@">>>CBPeripheralManagerStateUnsupported");
            break;
        case CBPeripheralManagerStateUnauthorized:
            MRJLog(@">>>CBPeripheralManagerStateUnauthorized");
            break;
        case CBPeripheralManagerStatePoweredOff:
            MRJLog(@">>>CBPeripheralManagerStatePoweredOff");
            break;
        case CBPeripheralManagerStatePoweredOn:
            MRJLog(@">>>CBPeripheralManagerStatePoweredOn");
            //发送centralManagerDidUpdateState通知
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CBPeripheralManagerStatePoweredOn" object:nil];
            break;
        default:
            break;
    }

//    if([Speaker callback] blockOnPeripheralModelDidUpdateState) {
//        [currChannel blockOnCancelScan](centralManager);
//    }
    callbackBlock(blockOnPeripheralModelDidUpdateState)(peripheral);
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    didAddServices++;
    callbackBlock(blockOnPeripheralModelDidAddService)(peripheral,service,error);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    callbackBlock(blockOnPeripheralModelDidStartAdvertising)(peripheral,error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    callbackBlock(blockOnPeripheralModelDidReceiveReadRequest)(peripheral, request);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    callbackBlock(blockOnPeripheralModelDidReceiveWriteRequests)(peripheral,requests);
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    callbackBlock(blockOnPeripheralModelIsReadyToUpdateSubscribers)(peripheral);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    callbackBlock(blockOnPeripheralModelDidSubscribeToCharacteristic)(peripheral,central,characteristic);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    callbackBlock(blockOnPeripheralModelDidUnSubscribeToCharacteristic)(peripheral,central,characteristic);
}

@end

void makeCharacteristicToService(CBMutableService *service,NSString *UUID,NSString *properties,NSString *descriptor) {

    //paramter for properties
    CBCharacteristicProperties prop = 0x00;
    if ([properties containsString:@"r"]) {
        prop =  prop | CBCharacteristicPropertyRead;
    }
    if ([properties containsString:@"w"]) {
        prop =  prop | CBCharacteristicPropertyWrite;
    }
    if ([properties containsString:@"n"]) {
        prop =  prop | CBCharacteristicPropertyNotify;
    }
    if (properties == nil || [properties isEqualToString:@""]) {
        prop = CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite;
    }

    CBMutableCharacteristic *c = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:UUID] properties:prop  value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    
    //paramter for descriptor
    if (!(descriptor == nil || [descriptor isEqualToString:@""])) {
        //c设置description对应的haracteristics字段描述
        CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
        CBMutableDescriptor *desc = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:descriptor];
        [c setDescriptors:@[desc]];
    }
    
    if (!service.characteristics) {
        service.characteristics = @[];
    }
    NSMutableArray *cs = [service.characteristics mutableCopy];
    [cs addObject:c];
    service.characteristics = [cs copy];
}
void makeStaticCharacteristicToService(CBMutableService *service,NSString *UUID,NSString *descriptor,NSData *data) {
    
    CBMutableCharacteristic *c = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:UUID] properties:CBCharacteristicPropertyRead  value:data permissions:CBAttributePermissionsReadable];
    
    //paramter for descriptor
    if (!(descriptor == nil || [descriptor isEqualToString:@""])) {
        //c设置description对应的haracteristics字段描述
        CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
        CBMutableDescriptor *desc = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:descriptor];
        [c setDescriptors:@[desc]];
    }
    
    if (!service.characteristics) {
        service.characteristics = @[];
    }
    NSMutableArray *cs = [service.characteristics mutableCopy];
    [cs addObject:c];
    service.characteristics = [cs copy];
}


CBMutableService* makeCBService(NSString *UUID) {
    CBMutableService *s = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:UUID] primary:YES];
    return s;
}

NSString * genUUID() {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

