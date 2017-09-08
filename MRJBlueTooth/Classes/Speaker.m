/*
 Bluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth  
  
 */

//  Created by 余洪江 on  17/07/17.
//  Copyright (c) 2015年 余洪江. All rights reserved.
//

#import "Speaker.h"
#import "Define.h"


typedef NS_ENUM(NSUInteger, SpeakerType) {
    SpeakerTypeDiscoverPeripherals,
    SpeakerTypeConnectedPeripheral,
    SpeakerTypeDiscoverPeripheralsFailToConnect,
    SpeakerTypeDiscoverPeripheralsDisconnect,
    SpeakerTypeDiscoverPeripheralsDiscoverServices,
    SpeakerTypeDiscoverPeripheralsDiscoverCharacteristics,
    SpeakerTypeDiscoverPeripheralsReadValueForCharacteristic,
    SpeakerTypeDiscoverPeripheralsDiscoverDescriptorsForCharacteristic,
    SpeakerTypeDiscoverPeripheralsReadValueForDescriptorsBlock
};


@implementation Speaker {
    //所有委托频道
    NSMutableDictionary *channels;
    //当前委托频道
    NSString *currChannel;
    //notifyList
    NSMutableDictionary *notifyList;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        Callback *defaultCallback = [[Callback alloc]init];
        notifyList = [[NSMutableDictionary alloc]init];
        channels = [[NSMutableDictionary alloc]init];
        currChannel = K_DETAULT_CHANNEL;
        [channels setObject:defaultCallback forKey:K_DETAULT_CHANNEL];
    }
    return self;
}

- (Callback *)callback {
    return [channels objectForKey:K_DETAULT_CHANNEL];
}

- (Callback *)callbackOnCurrChannel {
    return [self callbackOnChnnel:currChannel];
}

- (Callback *)callbackOnChnnel:(NSString *)channel {
    if (!channel) {
        [self callback];
    }
    return [channels objectForKey:channel];
}

- (Callback *)callbackOnChnnel:(NSString *)channel
               createWhenNotExist:(BOOL)createWhenNotExist {
    
    Callback *callback = [channels objectForKey:channel];
    if (!callback && createWhenNotExist) {
        callback = [[Callback alloc]init];
        [channels setObject:callback forKey:channel];
    }
    
    return callback;
}

- (void)switchChannel:(NSString *)channel {
    if (channel) {
        if ([self callbackOnChnnel:channel]) {
            currChannel = channel;
            Log(@">>>已切换到%@",channel);
        }
        else {
            Log(@">>>所要切换的channel不存在");
        }
    }
    else {
        currChannel = K_DETAULT_CHANNEL;
            Log(@">>>已切换到默认频道");
    }
}

//添加到notify list
- (void)addNotifyCallback:(CBCharacteristic *)c
           withBlock:(void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))block {
    [notifyList setObject:block forKey:c.UUID.description];
}

//添加到notify list
- (void)removeNotifyCallback:(CBCharacteristic *)c {
    [notifyList removeObjectForKey:c.UUID.description];
}

//获取notify list
- (NSMutableDictionary *)notifyCallBackList {
    return notifyList;
}

//获取notityBlock
- (void(^)(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error))notifyCallback:(CBCharacteristic *)c {
    return [notifyList objectForKey:c.UUID.description];
}
@end
