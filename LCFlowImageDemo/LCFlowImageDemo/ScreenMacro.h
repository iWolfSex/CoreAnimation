//
//  ScreenMacro.h
//  JGQHCarNetworking
//
//  Created by iWolf on 2019/11/14.
//  Copyright © 2019 iWolf. All rights reserved.
//

/*
*  尺寸相关的宏定义
*/

#ifndef ScreenMacro_h
#define ScreenMacro_h



#define WinSize_Width  [[UIScreen mainScreen] bounds].size.width   //屏幕宽度
#define WinSize_Height [[UIScreen mainScreen] bounds].size.height  //屏幕高度

#define HwinScale [[UIScreen mainScreen] bounds].size.width/375    //iphone6缩放宽度比例
#define VwinScale [[UIScreen mainScreen] bounds].size.height/667   //iphone6缩放高度比例

#define Scale(s) HwinScale*s  //根据宽度比例缩放

/*状态栏高度+ NavgationBar高度*/
#define NavgationBar_Height   (kIs_iPhoneX ? 88:64)
/*TabBar高度*/
#define TabBar_Height         (kIs_iPhoneX?(49.0 + 34.0):(49.0))
/*状态栏高度*/
#define kStatusBarHeight (CGFloat)(kIs_iPhoneX?(44.0):(20.0))
/*顶部安全区域远离高度*/
#define kTopBarSafeHeight (CGFloat)(kIs_iPhoneX?(44.0):(0))
/*底部安全区域远离高度*/
#define kBottomSafeHeight (CGFloat)(kIs_iPhoneX?(34.0):(0))
/*iPhoneX的状态栏高度差值*/
#define kTopBarDifHeight (CGFloat)(kIs_iPhoneX?(24.0):(0))
/*导航条和Tabbar总高度*/
#define kNavAndTabHeight (NavgationBar_Height + kTabBarHeight)


#define ItemViewControllerFrame CGRectMake(0, 0, WinSize_Width, WinSize_Height-TabBar_Height)

#define kIs_iPhoneX WinSize_Width >=375.0f && WinSize_Height >=812.0f&& kIs_iphone

#define   iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kAdapter(w) WinSize_Width / 750.0f * w


#endif /* ScreenMacro_h */
