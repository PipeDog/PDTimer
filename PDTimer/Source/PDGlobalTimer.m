//
//  PDGlobalTimer.m
//  PDTimer
//
//  Created by liang on 2019/3/22.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDGlobalTimer.h"
#import "PDTimer.h"

typedef NS_OPTIONS(NSUInteger, PDGlobalTimerDelegateOptions) {
    PDGlobalTimerDelegateOptionsNone         = 0,
    PDGlobalTimerDelegateOptionsTick         = 1 << 0,
    PDGlobalTimerDelegateOptionsTimeInterval = 1 << 1,
    PDGlobalTimerDelegateOptionsPreTimestamp = 1 << 2,
};

@interface PDGlobalTimer () {
    PDTimer *_timer;
}

@property (nonatomic, strong) NSHashTable<id<PDGlobalTimerDelegate>> *delegates;
@property (nonatomic, strong) NSMapTable<id<PDGlobalTimerDelegate>, NSNumber *> *impls;

@end

@implementation PDGlobalTimer

+ (PDGlobalTimer *)globalTimer {
    static PDGlobalTimer *__globalTimer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalTimer = [PDGlobalTimer new];
        __weak typeof(__globalTimer) __weakGlobalTimer = __globalTimer;
        __globalTimer->_timer = [[PDTimer alloc] initWithTimeInterval:1.f leeway:0.f queue:dispatch_get_main_queue() block:^{
            __strong typeof(__weakGlobalTimer) __strongGlobalTimer = __weakGlobalTimer;
            if (__strongGlobalTimer) {
                [__strongGlobalTimer tick];
            }
        }];
    });
    return __globalTimer;
}

- (void)tick {
    NSTimeInterval curTimestamp = [NSDate date].timeIntervalSince1970;
    
    for (id<PDGlobalTimerDelegate>delegate in [self.delegates setRepresentation]) {
        NSNumber *number = [self.impls objectForKey:delegate];
        if (!number) { continue; }
        
        PDGlobalTimerDelegateOptions options = [number unsignedIntegerValue];
        
        if (!(options & PDGlobalTimerDelegateOptionsTick)) {
            continue;
        }
        
        if (!(options & PDGlobalTimerDelegateOptionsTimeInterval) ||
            !(options & PDGlobalTimerDelegateOptionsPreTimestamp)) {
            [delegate tick:self]; continue;
        }
        
        NSTimeInterval preTimestamp = delegate.preTimestamp;
        NSTimeInterval diff = curTimestamp - preTimestamp;
        
        static NSTimeInterval const bias = 0.01f;
        
        if (fabs(diff - delegate.timeInterval) < bias || preTimestamp < bias) {
            [delegate tick:self];
        }
    }
}

#pragma mark - Binding Methods
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
    if ([delegate respondsToSelector:@selector(preTimestamp)]) {
        options |= PDGlobalTimerDelegateOptionsPreTimestamp;
    }
    
    [self.impls setObject:@(options) forKey:delegate];
}

- (void)unbind:(id<PDGlobalTimerDelegate>)delegate {
    if (delegate) [self.delegates removeObject:delegate];
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
