//
//  ViewController.m
//  PDTimer
//
//  Created by liang on 2018/5/28.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDTimer.h"

@interface ViewController ()

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

- (IBAction)push:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VC"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
