//
//  PDTimer.m
//  PDTimer
//
//  Created by liang on 2018/5/28.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDTimer.h"

@interface PDTimer () {
    dispatch_source_t _source;
}

@end

@implementation PDTimer

- (void)dealloc {
    [self invalidate];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats
                               block:(dispatch_block_t)block {
    return [self initWithTimeInterval:interval repeats:repeats
                                block:block
                              inQueue:dispatch_get_main_queue()];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats
                               block:(dispatch_block_t)block
                             inQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_source, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0.f * NSEC_PER_SEC);
        
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_source, ^{
            if (!repeats) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) [strongSelf invalidate];
            }
            if (block) block();
        });
    }
    return self;
}

- (void)fire {
    if (_source) {
        dispatch_resume(_source);
    }
}

- (void)invalidate {
    if (_source) {
        dispatch_source_cancel(_source);
        _source = nil;
    }
}

@end
