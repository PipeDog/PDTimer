//
//  PDTimer.h
//  PDTimer
//
//  Created by liang on 2018/5/28.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDTimer : NSObject

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats
                               block:(dispatch_block_t)block; // Callback in main queue.

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats
                               block:(dispatch_block_t)block
                             inQueue:(dispatch_queue_t)queue; // Callback in specified queue.

- (void)fire;
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
