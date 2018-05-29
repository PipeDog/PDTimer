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
    NSLog(@"%@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _timer = [[PDTimer alloc] initWithTimeInterval:1.f repeats:YES block:^{
        NSLog(@"time block, %@", [NSThread currentThread]);
    } inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [_timer fire];
}

- (IBAction)didClickPushButton:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"VC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didClickInvalidButton:(id)sender {
    [_timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
