//
//  PDGlobalTimer.h
//  PDTimer
//
//  Created by liang on 2019/3/22.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PDGlobalTimer;

@protocol PDGlobalTimerDelegate <NSObject>

- (void)tick:(PDGlobalTimer *)timer;

@optional
// Callback interval, the requirement is a positive integer, default is 1.
@property (nonatomic, assign) NSTimeInterval timeInterval;

@end

@interface PDGlobalTimer : NSObject

@property (class, strong, readonly) PDGlobalTimer *globalTimer;
@property (nonatomic, assign, getter=isRunning, readonly) BOOL running;

- (void)bind:(id<PDGlobalTimerDelegate>)delegate;
- (void)unbind:(id<PDGlobalTimerDelegate>)delegate;

- (void)fire;
- (void)invalidate;

+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
