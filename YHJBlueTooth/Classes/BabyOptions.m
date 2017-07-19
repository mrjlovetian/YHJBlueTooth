//
//  BabyClothes.m
//  BabyBluetoothAppDemo
//
//  Created by 余洪江 on  17/07/177.
//  Copyright © 2015年 余洪江. All rights reserved.
//

#import "BabyOptions.h"

@implementation BabyOptions

- (instancetype)init {
    self = [super init];
    if (self) {
      _scanForPeripheralsWithOptions = nil;
      _connectPeripheralWithOptions = nil;
      _scanForPeripheralsWithServices = nil;
      _discoverWithServices = nil;
      _discoverWithCharacteristics = nil;
    }
    return self;
}

- (instancetype)initWithscanForPeripheralsWithOptions:(NSDictionary *)scanForPeripheralsWithOptions
        connectPeripheralWithOptions:(NSDictionary *)connectPeripheralWithOptions
{
    self = [super init];
    if (self) {
        [self setScanForPeripheralsWithOptions:scanForPeripheralsWithOptions];
        [self setConnectPeripheralWithOptions:connectPeripheralWithOptions];
    }
    return self;
}

- (instancetype)initWithscanForPeripheralsWithOptions:(NSDictionary *)scanForPeripheralsWithOptions
                        connectPeripheralWithOptions:(NSDictionary *)connectPeripheralWithOptions
                      scanForPeripheralsWithServices:(NSArray *)scanForPeripheralsWithServices
                      discoverWithServices:(NSArray *)discoverWithServices
                      discoverWithCharacteristics:(NSArray *)discoverWithCharacteristics
{
    self = [self initWithscanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectPeripheralWithOptions];
    if (self) {
        [self setScanForPeripheralsWithServices:scanForPeripheralsWithServices];
        [self setDiscoverWithServices:discoverWithServices];
        [self setDiscoverWithCharacteristics:discoverWithCharacteristics];
    }
    return self;
}

@end
