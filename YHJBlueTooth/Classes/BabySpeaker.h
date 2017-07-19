/*
 BabyBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth  
  
 
 @brief  babybluetooth block查找和channel切换

 */

//  Created by 余洪江 on  17/07/17.
//  Copyright (c) 2015年 余洪江. All rights reserved.
//

#import "BabyCallback.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface BabySpeaker : NSObject

- (BabyCallback *)callback;
- (BabyCallback *)callbackOnCurrChannel;
- (BabyCallback *)callbackOnChnnel:(NSString *)channel;
- (BabyCallback *)callbackOnChnnel:(NSString *)channel
               createWhenNotExist:(BOOL)createWhenNotExist;

//切换频道
- (void)switchChannel:(NSString *)channel;

//添加到notify list
- (void)addNotifyCallback:(CBCharacteristic *)c
           withBlock:(void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))block;

//添加到notify list
- (void)removeNotifyCallback:(CBCharacteristic *)c;

//获取notify list
- (NSMutableDictionary *)notifyCallBackList;

//获取notityBlock
- (void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))notifyCallback:(CBCharacteristic *)c;

@end
