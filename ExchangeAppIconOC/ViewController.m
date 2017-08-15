//
//  ViewController.m
//  ExchangeAppIconOC
//
//  Created by thinkjoy on 2017/8/8.
//  Copyright © 2017年 杜瑞胜. All rights reserved.
//
//icon图标来源  http://code.cocoachina.com/view/134988
//参考    http://blog.csdn.net/qq_31810357/article/details/68489138

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UISwitch *isHideAlertSwitch;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //应用是否更新过图标
    NSString *iconName = [[UIApplication sharedApplication] alternateIconName];
    
    NSInteger selectedIndex =   0;
    
    if ([iconName isEqualToString:@"NewIcon_Fine"]) {
        selectedIndex   =   1;
    }else if ([iconName isEqualToString:@"NewIcon_HeavyRain"]) {
        selectedIndex   =   2;
    }else if ([iconName isEqualToString:@"NewIcon_LightRain"]) {
        selectedIndex   =   3;
    }else if ([iconName isEqualToString:@"NewIcon_Snow"]) {
        selectedIndex   =   4;
    }
    _segmentControl.selectedSegmentIndex    =   selectedIndex;
    
}
- (IBAction)switchHadChanged:(UISwitch *)sender {
    
    [self runtimeReplaceAlert];
}

- (IBAction)clickSegmentControl:(UISegmentedControl *)sender
{
    NSString * iconName;
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            iconName    =   nil;
        }
        break;
        case 1:
        {
            iconName    =   @"NewIcon_Fine";
        }
        break;
        case 2:
        {
            iconName    =   @"NewIcon_HeavyRain";
        }
        break;
        case 3:
        {
            iconName    =   @"NewIcon_LightRain";
        }
        break;
        case 4:
        {
            iconName    =   @"NewIcon_Snow";
        }
        break;
        default:
        break;
    }
    
    if ([UIApplication sharedApplication].supportsAlternateIcons) {
        
        /*注：待替换的Icon直接放到目录中即可，本人放到.xcassets文件中，出现一直替换原始默认图标的问题，不知道是不是个别现象*/
        [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"errpr = %@",error);
            }else{
                
                NSLog(@"suceess");
            }
        }];
    }
}

// 利用runtime来替换展现弹出框的方法
- (void)runtimeReplaceAlert
{
    
    if (_isHideAlertSwitch.on == NO) {
        Method presentM = class_getInstanceMethod(self.class, @selector(presentViewController:animated:completion:));
        Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(drs_presentViewController:animated:completion:));
        // 交换方法实现
        method_exchangeImplementations(presentM, presentSwizzlingM);

    }else{
        Method presentM = class_getInstanceMethod(self.class, @selector(presentViewController:animated:completion:));
        Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(drs_presentViewController:animated:completion:));
        method_exchangeImplementations(presentM, presentSwizzlingM);

    }
    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method presentM = class_getInstanceMethod(self.class, @selector(presentViewController:animated:completion:));
//        Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(drs_presentViewController:animated:completion:));
//        // 交换方法实现
//        method_exchangeImplementations(presentM, presentSwizzlingM);
//    });
}

// 自己的替换展示弹出框的方法
- (void)drs_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        NSLog(@"title : %@",((UIAlertController *)viewControllerToPresent).title);
        NSLog(@"message : %@",((UIAlertController *)viewControllerToPresent).message);
        
        // 换图标时的提示框的title和message都是nil，由此可特殊处理
        UIAlertController *alertController = (UIAlertController *)viewControllerToPresent;
        if (alertController.title == nil && alertController.message == nil) { // 是换图标的提示
            return;
        } else {// 其他提示还是正常处理
            [self drs_presentViewController:viewControllerToPresent animated:flag completion:completion];
            return;
        }
    }
    
    [self drs_presentViewController:viewControllerToPresent animated:flag completion:completion];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
