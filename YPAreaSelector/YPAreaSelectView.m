//
//  YPAreaSelectView.m
//  CitysAreaDemo
//
//  Created by WorkZyp on 2019/3/13.
//  Copyright © 2019年 Zyp. All rights reserved.
//

#import "YPAreaSelectView.h"


#define kYPScreen_W     ([UIScreen mainScreen].bounds.size.width)
#define kYPScreen_H     ([UIScreen mainScreen].bounds.size.height)
#define kYPTopToolView_Height   40.f
@interface YPAreaSelectView ()  <UIPickerViewDataSource,UIPickerViewDelegate>

/** 省数组*/
@property (strong, nonatomic) NSArray *provincesArr;
/** 选中的省索引*/
@property (assign, nonatomic) NSInteger currentSelProvinceIndex;
/** 市数组*/
@property (strong, nonatomic) NSArray *citiesArr;
/** 选中的市索引*/
@property (assign, nonatomic) NSInteger currentSelCityIndex;
/** 区数组*/
@property (strong, nonatomic) NSArray *countiesArr;
/** 选中的区索引*/
@property (assign, nonatomic) NSInteger currentSelCountyIndex;


/** 地点选择器*/
@property (strong, nonatomic) UIView *areaSelectView;
/** 确定、取消 功能按钮*/
@property (strong, nonatomic) UIView *topToolView;
/** 选择的结果*/
@property (strong, nonatomic) UILabel *chooseResultLbl;
/** 地址选择*/
@property (strong, nonatomic) UIPickerView *areaPickerView;
/** 每个item的大小*/
@property (assign, nonatomic) CGFloat item_width;

/** 选择后的结果回调*/
@property (copy, nonatomic) void(^chooseCompleteBlock)(NSString *province, NSString *city, NSString *county);

/** 配置类*/
@property (strong, nonatomic) YPAreaSelectorConfig *config;

@end

@implementation YPAreaSelectView


#pragma mark - 💕生命周期💕 Methods
/**
 @brief 实例对象
 */
+ (instancetype)createAreasSelectView {
    YPAreaSelectView *view = [[YPAreaSelectView alloc] initWithFrame:CGRectMake(0, 0, kYPScreen_W, kYPScreen_H)];
    //初始化默认配置
    view.config = [YPAreaSelectorConfig defaultConfig];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [view addSubview:view.areaSelectView];
    
    
    //默认处于隐藏状态
    [view dismissAreaSelectView];
    
    //防止在跟视图中出现 makeKeyAndVisible方法未执行完，获取不到window对象
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    });
    
    
    return view;
}
//MARK: 析构函数
- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@ dealloc!", NSStringFromClass(self.class));
#endif
}
//MARK:点击取消
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.alpha) {
        if (self.config.isNeedSingleClickToCancel) {
            [self dismissAreaSelectView];
        }
    }
}

#pragma mark -  💕定义的💕Methods
//MARK: 更新配置
- (void)updateConfig:(void(^)(YPAreaSelectorConfig *config))config {
    config ? config(self.config) : nil;
}

//MARK: 核心方法 - 调用显示选择器
- (void)showAreaSelectorChooseComplete:(void(^)(NSString *_Nullable province, NSString *_Nullable city, NSString *_Nullable county))complete {
    self.chooseCompleteBlock = complete;
    [self showAreaSelectView];
}

//MARK: 重置一下配置
- (void)resetConfig {
    self.currentSelProvinceIndex = 0;
    self.currentSelCityIndex = 0;
    self.currentSelCountyIndex = 0;
    
    self.provincesArr = [self getProvincesArr];
    self.citiesArr = [self getCitiesArrWithIndex:0];
    [self.areaPickerView reloadAllComponents];
    
    [self.areaPickerView selectRow:0 inComponent:0 animated:NO];
    [self.areaPickerView selectRow:0 inComponent:1 animated:NO];
    
    if (self.config.dataType == YPAREA_SELECTOR_DATA_PCC) {
        self.countiesArr = [self getCountiesArrWithIndex:0];
        [self.areaPickerView reloadComponent:2];
        [self.areaPickerView selectRow:0 inComponent:2 animated:NO];
    }
    
    self.chooseResultLbl.text = [NSString stringWithFormat:@"%@%@%@",[self safeGetCurrentProvince], [self safeGetCurrentCity], [self safeGetCurrentCounty]];
    
    self.chooseResultLbl.textColor = self.config.chooseResultTextColor;

    self.areaSelectView.backgroundColor = self.config.bgColor;

    //    item不同时，有bug
    //    [self setSelectRowBgColor:self.config.selectedRowBgColor];
    
}

//MARK: 显示
- (void)showAreaSelectView {
    if (!self.alpha) {
        //还原初始数据 进行显示
        [self resetConfig];
        
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:0.35 animations:^{
            weakSelf.areaSelectView.frame = CGRectMake(0, kYPScreen_H - weakSelf.config.areaSelectViewHeight, kYPScreen_W, weakSelf.config.areaSelectViewHeight);
            weakSelf.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
}
//MARK: 隐藏
- (void)dismissAreaSelectView {
    if (self.alpha) {
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:0.35 animations:^{
            weakSelf.areaSelectView.frame = CGRectMake(0, kYPScreen_H, kYPScreen_W, weakSelf.config.areaSelectViewHeight);
            weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
    
}
//设置选中的行的颜色---TODO:有bug 用代理方式替换
- (void)setSelectRowBgColor:(UIColor *)rowBgColor {
    NSArray *subviews = self.areaPickerView.subviews;
    if (!(subviews.count > 0)) {
        return;
    }
    NSArray *coloms = subviews.firstObject;
    if (coloms) {
        NSArray *subviewCache = [coloms valueForKey:@"subviewCache"];
        if (subviewCache.count > 0) {
            UIView *middleContainerView = [subviewCache.firstObject valueForKey:@"middleContainerView"];
            if (middleContainerView) {
                middleContainerView.backgroundColor = rowBgColor;
            }
        }
    }
}

//MARK: 得到省数组
- (NSArray *)getProvincesArr {
    NSMutableArray *provinces = [NSMutableArray array];
    for (NSDictionary *subDict in [self getAreasPlistData]) {
        NSString *provinceStr = [NSString stringWithFormat:@"%@",subDict[@"name"]];
        [provinces addObject:provinceStr];
    }
    return provinces;
}

//MARK: 得到市数组
- (NSArray *)getCitiesArrWithIndex:(NSInteger)index {
    NSMutableArray *returnCitiesArr = [NSMutableArray array];
    if (index >= [self getAreasPlistData].count) {
        index = 0;
    }
    NSDictionary *provinceDict = [self getAreasPlistData][index];
    NSArray *citiesArr = [NSArray arrayWithArray:provinceDict[@"cities"]];
    for (int j = 0; j < citiesArr.count; j ++) {
        NSDictionary *cityDict = citiesArr[j];
        NSString *cityStr = [NSString stringWithFormat:@"%@",cityDict[@"name"]];
        [returnCitiesArr addObject:cityStr];
    }
    
    return [NSArray arrayWithArray:returnCitiesArr];
}

//MARK: 得到区数组
- (NSArray *)getCountiesArrWithIndex:(NSInteger)index {
    NSMutableArray *returnCountiesArr = [NSMutableArray array];
    NSDictionary *provinceDict = [self getAreasPlistData][self.currentSelProvinceIndex];
    NSArray *citiesArr = [NSArray arrayWithArray:provinceDict[@"cities"]];
    if (index >= citiesArr.count) {
        index = 0;
    }
    NSDictionary *cityDict = citiesArr[index];
    NSArray *countiesArr = [NSArray arrayWithArray:cityDict[@"counties"]];
    for (int i = 0; i < countiesArr.count; i ++) {
        NSString *countyStr = [NSString stringWithFormat:@"%@",countiesArr[i]];
        [returnCountiesArr addObject:countyStr];
    }
    
    return [NSArray arrayWithArray:returnCountiesArr];
}

//MARK: 获取plist数据
- (NSArray *)getAreasPlistData {
    NSString *areasPlistPath =  [[NSBundle mainBundle] pathForResource:@"AreasData.bundle/AreasPlist" ofType:@"plist"];
    NSArray *areasArr = [[NSArray alloc] initWithContentsOfFile:areasPlistPath];
    return areasArr;
}


#pragma mark - 💕点击事件💕 Actions
//MARK: 确定选择被点击
- (void)sureBtnClicked:(UIButton *)btn {
    self.chooseCompleteBlock ? self.chooseCompleteBlock([self safeGetCurrentProvince], [self safeGetCurrentCity], [self safeGetCurrentCounty]) : nil;
    [self dismissAreaSelectView];
}
//MARK: 取消选择被点击
- (void)cancelBtnClicked:(UIButton *)btn {
    [self dismissAreaSelectView];
}

#pragma mark - 💕代理方法💕 Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.item_width;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35.f;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return (self.config.dataType == YPAREA_SELECTOR_DATA_PCC) ? 3 : 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0://省份数组
        {
            return self.provincesArr.count;
        }
            break;
        case 1:
        {
            return self.citiesArr.count;
        }
            break;
        case 2:
        {
            return self.countiesArr.count;
        }
            break;
        default:
            break;
    }
    return 3;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            self.currentSelProvinceIndex = row;
            //选定省之后- 确定市数组
            self.citiesArr = [self getCitiesArrWithIndex:row];
            //确定市数组后- 刷新市数组
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            self.currentSelCityIndex = 0;
            
            if (self.config.dataType == YPAREA_SELECTOR_DATA_PCC) {
                //确定区数组
                self.countiesArr = [self getCountiesArrWithIndex:self.currentSelCityIndex];
                //刷新区数组
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:YES];
                self.currentSelCountyIndex = 0;
            }
        }
            break;
        case 1:
        {
            self.currentSelCityIndex = row;
            //选定市之后- 确定区数组
            self.countiesArr = [self getCountiesArrWithIndex:row];
            
            if (self.config.dataType == YPAREA_SELECTOR_DATA_PCC) {
                //确定区数组后- 刷新区数组
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:YES];
                self.currentSelCountyIndex = 0;
            }
            
        }
            break;
        case 2:
        {
            self.currentSelCountyIndex = row;
        }
            break;
            
        default:
            break;
    }
    
    self.chooseResultLbl.text = [NSString stringWithFormat:@"%@%@%@",[self safeGetCurrentProvince], [self safeGetCurrentCity], [self safeGetCurrentCounty]];
    
}
/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            NSString *provinceStr = self.provincesArr[row];
            return provinceStr;
        }
            break;
        case 1:
        {
            NSString *cityStr = self.citiesArr[row];
            return cityStr;
        }
            break;
        case 2:
        {
            NSString *countyStr = self.countiesArr[row];
            return countyStr;
        }
            break;

        default:
            break;
    }
    return @"";
}
*/

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *itemLbl = [[UILabel alloc]initWithFrame:CGRectMake(component * self.item_width, 0, self.item_width, 35.f)];
    // 选中后的行的背景色
    itemLbl.backgroundColor = self.config.rowItemBgColor;
    
    itemLbl.textAlignment = NSTextAlignmentCenter;
    itemLbl.textColor = self.config.rowItemTextColor;
    itemLbl.font = self.config.rowItemFont;
    NSString *textStr = @"";
    switch (component) {
        case 0:
            textStr = self.provincesArr[row];
            break;
        case 1:
            textStr = self.citiesArr[row];
            break;
        case 2:
            textStr = self.countiesArr[row];
            break;
        default:
            break;
    }
    itemLbl.text = textStr;
    return itemLbl;
}


#pragma mark - 💕GET/SET💕
- (NSArray *)provincesArr {
    if (!_provincesArr) {
        _provincesArr = [NSArray array];
    }
    
    return _provincesArr;
}

- (NSArray *)citiesArr {
    if (!_citiesArr) {
        _citiesArr = [NSArray array];
    }
    
    return _citiesArr;
}

- (NSArray *)countiesArr {
    if (!_countiesArr) {
        _countiesArr = [NSArray array];
    }
    
    return _countiesArr;
}
- (UIView *)areaSelectView {
    if (!_areaSelectView) {
        _areaSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, kYPScreen_H - self.config.areaSelectViewHeight, kYPScreen_W, self.config.areaSelectViewHeight)];
        [_areaSelectView addSubview:self.topToolView];
        [_areaSelectView addSubview:self.areaPickerView];
    }
    
    return _areaSelectView;
}

- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kYPScreen_W, kYPTopToolView_Height)];
        
        UIButton *cancelBtn = [self createButtonWithFrame:CGRectMake(15, 5, 50, kYPTopToolView_Height - 10) title:@"取消" titleColor:[UIColor grayColor] selector:@selector(cancelBtnClicked:)];
        [_topToolView addSubview:cancelBtn];
        
        UIButton *sureBtn = [self createButtonWithFrame:CGRectMake(kYPScreen_W - 65, 5, 50, kYPTopToolView_Height - 10) title:@"确定" titleColor:[UIColor redColor] selector:@selector(sureBtnClicked:)];
        [_topToolView addSubview:sureBtn];
        
        self.chooseResultLbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, kYPScreen_W - 120, kYPTopToolView_Height)];
        self.chooseResultLbl.textColor = [UIColor blueColor];
        self.chooseResultLbl.textAlignment = NSTextAlignmentCenter;
        [_topToolView addSubview:self.chooseResultLbl];
        
    }
    
    return _topToolView;
}

- (UIPickerView *)areaPickerView {
    if (!_areaPickerView) {
        _areaPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kYPTopToolView_Height, kYPScreen_W, self.config.areaSelectViewHeight - kYPTopToolView_Height)];
        _areaPickerView.delegate = self;
        _areaPickerView.dataSource = self;
    }
    
    return _areaPickerView;
}

- (CGFloat)item_width {
    return ((self.config.dataType == YPAREA_SELECTOR_DATA_PCC) ? (kYPScreen_W / 3.0) : (kYPScreen_W / 2.0));
}

//MARK: 快速创建Button
- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor selector:(SEL)sel{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
//MARK: 得到对应选取的值-处理下容错
- (NSString *)safeGetCurrentProvince {
    if (self.currentSelProvinceIndex < self.provincesArr.count) {
        return self.provincesArr[self.currentSelProvinceIndex];
    }else {
        return self.provincesArr[0];
    }
}
- (NSString *)safeGetCurrentCity {
    if (self.currentSelCityIndex < self.citiesArr.count) {
        return self.citiesArr[self.currentSelCityIndex];
    }else {
        return self.citiesArr[0];
    }
}
- (NSString *)safeGetCurrentCounty {
    if (self.config.dataType == YPAREA_SELECTOR_DATA_PCC) {
        if (self.currentSelCountyIndex < self.countiesArr.count) {
            return self.countiesArr[self.currentSelCountyIndex];
        }else {
            return self.countiesArr[0];
        }
    }
    return @"";
}


@end



@implementation YPAreaSelectorConfig

+ (instancetype)defaultConfig {
    YPAreaSelectorConfig *config = [YPAreaSelectorConfig new];
    
    //默认的配置
    config.areaSelectViewHeight = 220.f;
    config.rowItemBgColor = [UIColor groupTableViewBackgroundColor];
    config.chooseResultTextColor = [UIColor lightGrayColor];
    config.dataType = YPAREA_SELECTOR_DATA_PCC;
    config.isNeedSingleClickToCancel = NO;
    config.bgColor = [UIColor whiteColor];
    config.rowItemTextColor = [UIColor blackColor];
    config.rowItemFont = [UIFont systemFontOfSize:18];
    
    return config;
}

@end
