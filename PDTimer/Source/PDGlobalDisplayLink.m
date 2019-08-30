//
//  PDGlobalDisplayLink.m
//  PDTimer
//
//  Created by liang on 2019/8/30.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDGlobalDisplayLink.h"

@implementation PDGlobalDisplayLink {
    CADisplayLink *_displayLink;
    NSHashTable<id<PDGlobalDisplayLinkDelegate>> *_delegates;
}

+ (PDGlobalDisplayLink *)globalDisplayLink {
    static PDGlobalDisplayLink *_globalDisplayLink;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalDisplayLink = [[PDGlobalDisplayLink alloc] init];
    });
    return _globalDisplayLink;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)bind:(id<PDGlobalDisplayLinkDelegate>)delegate {
    if ([_delegates containsObject:delegate]) { return; }
    if (![delegate respondsToSelector:@selector(tick:)]) { return; }
    
    [_delegates addObject:delegate];
    [self beginVSyncSignalRCV];
}

- (void)unbind:(id<PDGlobalDisplayLinkDelegate>)delegate {
    if (![_delegates containsObject:delegate]) { return; }
    
    [_delegates removeObject:delegate];
}

#pragma mark - Private Methods
- (void)beginVSyncSignalRCV {
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopVSyncSignalRCV {
    if (!_displayLink) {
        return;
    }
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)tick:(CADisplayLink *)displayLink {
    NSArray<id<PDGlobalDisplayLinkDelegate>> *delegates = _delegates.allObjects;
    
    if (!delegates.count) {
        [self stopVSyncSignalRCV];
        return;
    }
    
    for (id<PDGlobalDisplayLinkDelegate> delegate in delegates) {
        [delegate tick:displayLink];
    }
}

@end
