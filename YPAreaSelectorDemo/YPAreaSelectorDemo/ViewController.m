//
//  ViewController.m
//  YPAreaSelectorDemo
//
//  Created by WorkZyp on 2019/3/15.
//  Copyright © 2019年 Zyp. All rights reserved.
//

#import "ViewController.h"
#import "YPAreaSelectView.h"


@interface ViewController ()

@property (strong, nonatomic) YPAreaSelectView *areaV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    
    self.areaV = [YPAreaSelectView createAreasSelectView];
    
    
    CGFloat screen_w = [UIScreen mainScreen].bounds.size.width;
    UIButton *btn = [self quickGetButtonWithFrame:CGRectMake(0, 100, screen_w, 40) title:@"省市区三级联动-地址选择器" titleColor:[UIColor redColor] selector:@selector(btnClicked:)];
    btn.tag = 100;
    [self.view addSubview:btn];
    
    
    UIButton *btn2 = [self quickGetButtonWithFrame:CGRectMake(0, 150, screen_w, 40) title:@"省市二级联动-地址选择器" titleColor:[UIColor purpleColor] selector:@selector(btnClicked:)];
    btn2.tag = 101;
    [self.view addSubview:btn2];
    
    
}

//MARK: 点击体验
- (void)btnClicked:(UIButton *)btn {
    if (btn.tag == 100) {//三级选择器
        //更新配置信息
        [self.areaV updateConfig:^(YPAreaSelectorConfig * _Nonnull config) {
            //省市区
            config.dataType = YPAREA_SELECTOR_DATA_PCC;
            //点击屏幕其他位置 触发取消操作
            config.isNeedSingleClickToCancel = YES;
            
        }];
        
    }else {//二级选择器
        //更新配置信息
        [self.areaV updateConfig:^(YPAreaSelectorConfig * _Nonnull config) {
            //省市
            config.dataType = YPAREA_SELECTOR_DATA_PC;
            //点击屏幕其他位置 不触发取消操作
            config.isNeedSingleClickToCancel = NO;
        }];
    }
    
    //显示选择器
    [self.areaV showAreaSelectorChooseComplete:^(NSString * _Nullable province, NSString * _Nullable city, NSString * _Nullable county) {
        [btn setTitle:[NSString stringWithFormat:@"%@%@%@",province,city,county] forState:UIControlStateNormal];
    }];
}

//MARK: 快速创建Button
- (UIButton *)quickGetButtonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor selector:(SEL)sel{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


@end
