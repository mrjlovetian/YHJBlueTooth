/*
 BabyBluetooth
 简单易用的蓝牙ble库，基于CoreBluetooth  
  
 */

//  Created by 余洪江 on  17/07/17.
//  Copyright (c) 2015年 余洪江. All rights reserved.
//

#import "BabyCallback.h"

@implementation BabyCallback


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
            if (![peripheralName isEqualToString:@""]) {
                return YES;
            }
            return NO;
        }];
        [self setFilterOnconnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
            if (![peripheralName isEqualToString:@""]) {
                return YES;
            }
            return NO;
        }];
    }
    return self;
}
@end
