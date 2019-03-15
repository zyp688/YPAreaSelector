//
//  YPAreaSelectView.h
//  CitysAreaDemo
//
//  Created by WorkZyp on 2019/3/13.
//  Copyright © 2019年 Zyp. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @brief 地址选择的模式- 省市两级、省市县三级
 @see   AreasSelectorShowType
 */
typedef enum {
    /** *   省市区 模式 默认provinceCityCounty */
    YPAREA_SELECTOR_DATA_PCC,
    /** *   省市模式 provinceCity*/
    YPAREA_SELECTOR_DATA_PC,
    
}YPAREA_SELECTOR_DATA_TYPE;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief 支持的可扩展可修改的配置Interface
 */
@interface YPAreaSelectorConfig : NSObject

/**
 @brief 省市区/省市 数据类型设置  默认为省市区
 @see   YPAREA_SELECTOR_DATA_TYPE
 */
@property (assign, nonatomic) YPAREA_SELECTOR_DATA_TYPE dataType;

/**
 @brief 设置地址选择区视图的高度
 */
@property (assign, nonatomic) CGFloat areaSelectViewHeight;

/**
 @brief 是否需要单击屏幕 来触发 取消  默认为NO
 */
@property (assign, nonatomic) BOOL isNeedSingleClickToCancel;

/**
 @brief 地址选择器的背景色 默认白色
 */
@property (strong, nonatomic) UIColor *bgColor;

/**
 @brief 选择的结果展示的颜色  默认lightGrayColor
 */
@property (strong, nonatomic) UIColor *chooseResultTextColor;

/**
 @brief 每行的背景颜色  --- 距离选中行 逐级渐变 默认灰
 */
@property (strong, nonatomic) UIColor *rowItemBgColor;

/**
 @brief 每行的字体的颜色  默认为黑色
 */
@property (strong, nonatomic) UIColor *rowItemTextColor;

/**
 @brief 每行的字体 - 默认 [UIFont systemFontOfSize:18]
 */
@property (strong, nonatomic) UIFont *rowItemFont;

/**
 @brief 默认配置
 */
+ (instancetype)defaultConfig;

@end


/**
 @brief 地址选择器Interface
 */
@interface YPAreaSelectView : UIView

/**
 @brief 创建对象
 */
+ (instancetype)createAreasSelectView;

/**
 @brief 显示选择器
 */
- (void)showAreaSelectorChooseComplete:(void(^)(NSString *_Nullable province, NSString *_Nullable city, NSString *_Nullable county))complete;


/**
 @brief 更新配置
 */
- (void)updateConfig:(void(^)(YPAreaSelectorConfig *config))config;

@end





NS_ASSUME_NONNULL_END
