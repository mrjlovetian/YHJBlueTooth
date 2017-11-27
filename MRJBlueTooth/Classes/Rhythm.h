//  Created by ZTELiuyw on  17/07/17.
//  Copyright (c) 2015年 余洪江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

@interface Rhythm : NSObject

typedef void (^BBBeatsBreakBlock)(Rhythm *bry);
typedef void (^BBBeatsOverBlock)(Rhythm *bry);

//timer for beats
@property (nonatomic, strong) NSTimer *beatsTimer;
//beat interval
@property NSInteger beatsInterval;

#pragma mark beats
/// 心跳
- (void)beats;

/// 主动中断心跳
- (void)beatsBreak;

/// 结束心跳，结束后会进入BlockOnBeatOver，并且结束后再不会在触发BlockOnBeatBreak
- (void)beatsOver;

/// 恢复心跳，beatsOver操作后可以使用beatsRestart恢复心跳，恢复后又可以进入BlockOnBeatBreak方法
- (void)beatsRestart;

/// 心跳中断的委托
- (void)setBlockOnBeatsBreak:(void(^)(Rhythm *bry))block;

/// 心跳结束的委托
- (void)setBlockOnBeatsOver:(void(^)(Rhythm *bry))block;

@end
