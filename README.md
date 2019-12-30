# YPAreaSelector（QQ打趣群：68153279）
## ☆☆☆ “最新最全的-省市区选择器、三级联动选择器、地址选择器” ☆☆☆

### 支持pod导入
pod 'YPAreaSelector','~> 1.0.0'

### 更改记录：
2019.03.19 --> 更新地区数据，支持Cocoapod导入

2019.03.18 --> 初始化工程，规整程序路径.

### 代码应用

```
//初始化
+(instancetype)createAreasSelectView;

//更新所需要的样式信息    具体支持的修改信息请移步 YPAreaSelectorConfig
- (void)updateConfig:(void(^)(YPAreaSelectorConfig *config))config;

//显示选择器并拿到选择的结果回调
- (void)showAreaSelectorChooseComplete:(void(^)(NSString *_Nullable province, NSString *_Nullable city, NSString *_Nullable county))complete;

```
***

### 效果图演示
![image](https://github.com/zyp688/YPAreaSelector/blob/master/YPAreaSelectorDemo.gif) 

##### 【借鉴声明：本篇无借鉴，如有雷同，纯属扯淡】
