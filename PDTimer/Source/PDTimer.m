//
//  PDTimer.m
//  PDTimer
//
//  Created by liang on 2018/5/28.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDTimer.h"

@implementation PDTimer {
    dispatch_source_t _timer;
    
    NSTimeInterval _ti;
    NSTimeInterval _leeway;
    dispatch_queue_t _queue;
    dispatch_block_t _block;
}

- (void)dealloc {
    [self invalidate];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti
                              leeway:(NSTimeInterval)leeway
                               queue:(dispatch_queue_t)queue
                               block:(dispatch_block_t)block {
    self = [super init];
    if (self) {
        _ti = ti;
        _leeway = leeway;
        _queue = queue;
        _block = [block copy];
    }
    return self;
}

- (void)fire {
    if (_timer) { return; }
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, _ti * NSEC_PER_SEC, _leeway * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            !strongSelf->_block ?: strongSelf->_block();
        }
    });
    
    dispatch_resume(_timer);
}

- (void)invalidate {
    if (!_timer) { return; }
    
    dispatch_source_cancel(_timer);
    _timer = nil;
}

@end
