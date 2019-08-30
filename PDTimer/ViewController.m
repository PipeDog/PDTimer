//
//  ViewController.m
//  PDTimer
//
//  Created by liang on 2018/5/28.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDTimer.h"
#import "PDGlobalDisplayLink.h"

@interface ViewController () <PDGlobalDisplayLinkDelegate>

@property (nonatomic, strong) PDTimer *timer;

@end

@implementation ViewController

- (void)dealloc {
    [_timer invalidate];
    NSLog(@"%@ => dealloc", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _timer = [[PDTimer alloc] initWithTimeInterval:1.f leeway:0.01f queue:dispatch_get_main_queue() block:^{
        NSLog(@"time block, %@", [NSThread currentThread]);
    }];
}

- (IBAction)fire:(id)sender {
    [_timer fire];
}

- (IBAction)invalidate:(id)sender {
    [_timer invalidate];
}

- (IBAction)bind:(id)sender {
    [[PDGlobalDisplayLink globalDisplayLink] bind:self];
}

- (IBAction)unbind:(id)sender {
    [[PDGlobalDisplayLink globalDisplayLink] unbind:self];
}

- (IBAction)push:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VC"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - PDGlobalDisplayLinkDelegate
- (void)tick:(CADisplayLink *)displayLink {
    NSLog(@"%.4f", [NSDate date].timeIntervalSince1970);
}

@end
