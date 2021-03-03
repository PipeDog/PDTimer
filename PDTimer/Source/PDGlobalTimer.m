//
//  PDGlobalTimer.m
//  PDTimer
//
//  Created by liang on 2019/3/22.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDGlobalTimer.h"
#import <objc/runtime.h>
#import "PDTimer.h"

typedef NS_OPTIONS(NSUInteger, PDGlobalTimerDelegateOptions) {
    PDGlobalTimerDelegateOptionsNone         = 0,
    PDGlobalTimerDelegateOptionsTick         = 1 << 0,
    PDGlobalTimerDelegateOptionsTimeInterval = 1 << 1,
};

@interface PDGlobalTimer () {
    PDTimer *_timer;
}

@property (nonatomic, strong) NSHashTable<id<PDGlobalTimerDelegate>> *delegates;
@property (nonatomic, strong) NSMapTable<id<PDGlobalTimerDelegate>, NSNumber *> *impls;

@end

@implementation PDGlobalTimer

@synthesize running = _running;

static PDGlobalTimer *__globalTimer;

+ (PDGlobalTimer *)globalTimer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (__globalTimer == nil) {
            __globalTimer = [[self alloc] init];
        }
    });
    return __globalTimer;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized (self) {
        if (__globalTimer == nil) {
            __globalTimer = [super allocWithZone:zone];
        }
    }
    return __globalTimer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        _timer = [[PDTimer alloc] initWithTimeInterval:1.f leeway:0.f queue:dispatch_get_main_queue() block:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) { return; }
            
            [strongSelf tick];
        }];
        
        _running = NO;
    }
    return self;
}

#pragma mark - Public Methods
- (void)fire {
    if (self.isRunning) { return; }
    
    _running = YES;
    [self->_timer fire];
}

- (void)invalidate {
    if (!self.isRunning) { return; }
    
    _running = NO;
    [self->_timer invalidate];
}

- (void)bind:(id<PDGlobalTimerDelegate>)delegate {
    if ([self.delegates containsObject:delegate]) return;
    
    [self.delegates addObject:delegate];
    
    PDGlobalTimerDelegateOptions options = PDGlobalTimerDelegateOptionsNone;
    
    if ([delegate respondsToSelector:@selector(tick:)]) {
        options |= PDGlobalTimerDelegateOptionsTick;
    }
    if ([delegate respondsToSelector:@selector(timeInterval)]) {
        options |= PDGlobalTimerDelegateOptionsTimeInterval;
    }
    
    [self.impls setObject:@(options) forKey:delegate];
}

- (void)unbind:(id<PDGlobalTimerDelegate>)delegate {
    if (delegate) [self.delegates removeObject:delegate];
}

#pragma mark - Private Methods
- (void)tick {
    NSTimeInterval curTimestamp = [NSDate date].timeIntervalSince1970;
    
    for (id<PDGlobalTimerDelegate>delegate in [self.delegates setRepresentation]) {
        NSNumber *number = [self.impls objectForKey:delegate];
        if (!number) { continue; }
        
        PDGlobalTimerDelegateOptions options = [number unsignedIntegerValue];
        
        if (!(options & PDGlobalTimerDelegateOptionsTick)) {
            continue;
        }
        
        if (!(options & PDGlobalTimerDelegateOptionsTimeInterval)) {
            [delegate tick:self]; continue;
        }
        
        static const char *preTimestampKey = "preTimestampKey";
        NSTimeInterval preTimestamp = [objc_getAssociatedObject(delegate, preTimestampKey) doubleValue];
        NSTimeInterval diff = curTimestamp - preTimestamp;
        NSTimeInterval bias = MIN(delegate.timeInterval / 10.f, 0.2f);
        bias = MAX(bias, 0.05f); // 0.05s ~ 0.2s
        
        if (fabs(diff - delegate.timeInterval) < bias || preTimestamp < bias || diff > delegate.timeInterval) {
            objc_setAssociatedObject(delegate, preTimestampKey, @(curTimestamp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [delegate tick:self];
        }
    }
}

#pragma mark - Getter Methods
- (NSHashTable<id<PDGlobalTimerDelegate>> *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (NSMapTable<id<PDGlobalTimerDelegate>, NSNumber *> *)impls {
    if (!_impls) {
        _impls = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _impls;
}

@end
