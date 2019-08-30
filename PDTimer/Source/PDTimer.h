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

/*
 * @param ti
 * The number of seconds between firings of the timer.
 *
 * @param leeway
 * The seconds leeway for the timer.
 *
 * @param queue
 * The dispatch queue to which the event handler block will be submitted.
 *
 * @param block
 * The registration handler block to submit to the source's target queue.
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)ti
                              leeway:(NSTimeInterval)leeway
                               queue:(dispatch_queue_t)queue
                               block:(dispatch_block_t)block;

- (void)fire;
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
