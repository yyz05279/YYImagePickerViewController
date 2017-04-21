//
//  AppConstants.h
//  CardMaster
//
//  Created by Lyner on 13-7-9.
//  Copyright (c) 2013年 GL. All rights reserved.
//
 
#import <Foundation/Foundation.h>

#pragma mark - 功能定义区

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define BottomProductHeight RELATIVE_WIDTH(116)
#define mNavBarWithStateHeight 64
#define CommonCornerRadius  4

/**
 *   颜色定义
 */
// tableview  cell 的底色
#define kCellBgColor  0xE6E0D4
// tableview cell 文字颜色
#define kCellTextColor 0x7D7A69
//导航栏背景色
#define kNavBarBackColor mRGBToColor(0xe74e3e)
#define mRGBToColor(rgb) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0 green:((float)((rgb & 0xFF00) >> 8))/255.0 blue:((float)(rgb & 0xFF))/255.0 alpha:1.0]

#define YYTextColor mRGBToColor(0x333333)
#define YYGlobalColor mRGBToColor(0xf74a4a)

// 数据库文件名称
#define kDefaultDBName  @"shhy_scangain_app.db"

// 检索历史的 检索来源类型,  CODE  , KEYWORD
#define kSearchType_Scan @"SCAN"
#define kSearchType_Keyword @"KEYWORD"



#define XcodeAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

// 常用的宏定义
#define IS_IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
    CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define WIN_SIZE [UIScreen mainScreen].bounds.size
#define WIN_WIDTH [UIScreen mainScreen].bounds.size.width
#define WIN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define IS_IPHONE6_LATER ((WIN_WIDTH >= 375 && WIN_HEIGHT >= 667) == YES ? YES:NO)
#define NAV_BAR_BACK_IMG @"banner"


// 把16进制的颜色转成UIColor对象 
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#pragma mark - HTTP请求定义区


// 与服务器连接超时设定
#define WSURL_TIMEOUT 60

// Frame的快捷操作
static inline CGFloat GG_X(UIView *view){ return view.frame.origin.x;}
static inline CGFloat GG_Y(UIView *view){ return view.frame.origin.y;}
static inline CGFloat GG_W(UIView *view){ return view.frame.size.width;}
static inline CGFloat GG_H(UIView *view){ return view.frame.size.height;}
static inline CGFloat GG_BOTTOM_Y(UIView *view){ return GG_Y(view) + GG_H(view);};
static inline CGFloat GG_RIGHT_X(UIView *view){ return GG_X(view) + GG_W(view);};
// 快捷方式
#define ccp(x,y) CGPointMake(x, y)
#define ccs(x,y) CGSizeMake(x, y)
#define ccr(x,y,w,h) CGRectMake(x,y,w,h)
#define AppendString(str1, str2) [NSString stringWithFormat:@"%@%@", str1, str2]

#define BASE_WIDTH  750.0
#define BASE_HEIGHT 1334.0

#define RELATIVE_WIDTH(w) WIN_WIDTH/BASE_WIDTH * w
#define RELATIVE_HEIGHT(h) WIN_HEIGHT/BASE_HEIGHT * h

//图片加载打开还是关闭
#define ISDFNetReachableViaClose @"ISDFNetReachableViaClose"

//没有昵称 统一改成 智慧社区用户
#define AppNoneUserNickname @"智慧社区业主"
#define IsDeveloping @"程序猿正在努力开发中，敬请期待..."
#define NoneNetworkCode 201601121531
#define MedicineReminderSaveLocationName @"20160114110400"

//每个小区固定的物业ID
//#define AppPropertyCode @"TEST_CODE" // 物业Code
