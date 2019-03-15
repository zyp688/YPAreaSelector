# YPAreaSelector
三级联动地址选择器

### 应用场景
```
地址选择器，应用场景是在是太多了...不过多介绍
只提雷区:网上多数地区数据都已经过时了,而且三级省市区的资料更是比较少，因业务需求做个Demo，有需要的朋友可以直接使用。
```
``#地区更新于2019-03-15，辛苦更新，有需要的麻烦给个辛苦的Star吧...``

### 具体用法
```
//初始化
+(instancetype)createAreasSelectView;

//更新所需要的样式信息    具体支持的修改信息请移步 YPAreaSelectorConfig
- (void)updateConfig:(void(^)(YPAreaSelectorConfig *config))config;

//显示选择器并拿到选择的结果回调
- (void)showAreaSelectorChooseComplete:(void(^)(NSString *_Nullable province, NSString *_Nullable city, NSString *_Nullable county))complete;

```
### 效果图演示
![image](https://github.com/zyp688/YPAreaSelector/blob/master/YPAreaSelectorDemo.gif) 

##### 【借鉴声明：本篇无借鉴，如有雷同，纯属扯淡】

###### 更多技术探讨研究，欢迎小伙伴们加Q群68153279，我们一起进步！

