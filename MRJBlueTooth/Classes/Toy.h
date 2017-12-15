//  Created by 余洪江 on  17/07/17.
//  Copyright (c) 2015年 余洪江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Toy : NSObject

/// 十六进制转换为普通字符串的。
+ (NSString *)ConvertHexStringToString:(NSString *)hexString;

/// 普通字符串转换为十六进制
+ (NSString *)ConvertStringToHexString:(NSString *)string;

/// int转data
+ (NSData *)ConvertIntToData:(int)i;

/// data转int
+ (int)ConvertDataToInt:(NSData *)data;

/// 十六进制转换为普通字符串的。
+ (NSData *)ConvertHexStringToData:(NSString *)hexString;

/// 根据UUIDString查找CBCharacteristic
+ (CBCharacteristic *)findCharacteristicFormServices:(NSMutableArray *)services
                                         UUIDString:(NSString *)UUIDString;
@end
