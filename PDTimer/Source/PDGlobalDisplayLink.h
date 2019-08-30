//
//  PDGlobalDisplayLink.h
//  PDTimer
//
//  Created by liang on 2019/8/30.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDGlobalDisplayLinkDelegate <NSObject>

- (void)tick:(CADisplayLink *)displayLink;

@end

@interface PDGlobalDisplayLink : NSObject

@property (class, strong, readonly) PDGlobalDisplayLink *globalDisplayLink;

- (void)bind:(id<PDGlobalDisplayLinkDelegate>)delegate;
- (void)unbind:(id<PDGlobalDisplayLinkDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
