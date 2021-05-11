//
//  AZMCategoriesMacro.h
//  VideoEditTool
//
//  Created by mac219 on 20/11/16.
//  Copyright © 2020年 azmtb. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NSDate+AZMOption.h"
#ifndef AZMCategoriesMacro_h
#define AZMCategoriesMacro_h

#ifndef AZM_USER_DEFAULTS
#define AZM_USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#endif

#ifndef AZM_LOCAL
#define AZM_LOCAL(_s_) NSLocalizedString((_s_), nil)
#endif

#ifndef AZM_ROOT_WINDOW
#define AZM_ROOT_WINDOW [UIApplication sharedApplication].delegate.window
#endif

#ifndef AZM_MAX_SIZE
#define AZM_MAX_SIZE CGSizeMake(MAXFLOAT, MAXFLOAT)
#endif

#ifndef AZM_CLAMP // 返回中间值
#define AZM_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef AZM_SWAP // 值交换
#define AZM_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

#ifndef AZM_INDEX_PATH
#define AZM_INDEX_PATH(_row_, _section_) [NSIndexPath indexPathForRow:(_row_) inSection:(_section_)]
#endif

#ifndef AZM_SYNTH_DUMMY_CLASS
#define AZM_SYNTH_DUMMY_CLASS(_name_) \
@interface AZM_SYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation AZM_SYNTH_DUMMY_CLASS_ ## _name_ @end
#endif
#ifndef AZM_LOG
#ifdef DEBUG
#define AZM_LOG(fmt, ...) fprintf(stderr,"%s:%d %s\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[[NSDate date] azm_stringWithFormat:@"MM/dd/HH/mm/ss"] UTF8String], [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String])
#else
#define AZM_LOG(...)
#endif
#endif
#ifndef AZM_PATH_IMAGE
#define AZM_PATH_IMAGE(_i_) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForAuxiliaryExecutable:(_i_)]]
#endif

/**
 *  判断block存在后执行
 */
#ifndef AZMBlock
#define AZMBlock(_b_, ...) if(_b_){_b_(__VA_ARGS__);}
#endif

/**
 AZMStrongify
 AZMStrongify用来解除循环引用
 */
#ifndef AZMWeakify
#if DEBUG
#if __has_feature(objc_arc)
#define AZMWeakify(object) __weak __typeof__(object) weak##_##object = object
#else
#define AZMWeakify(object) __block __typeof__(object) block##_##object = object
#endif
#else
#if __has_feature(objc_arc)
#define AZMWeakify(object) __weak __typeof__(object) weak##_##object = object
#else
#define AZMWeakify(object) __block __typeof__(object) block##_##object = object
#endif
#endif
#endif

#ifndef AZMStrongify
#if DEBUG
#if __has_feature(objc_arc)
#define AZMStrongify(object) __typeof__(object) object = weak##_##object
#else
#define AZMStrongify(object) __typeof__(object) object = block##_##object
#endif
#else
#if __has_feature(objc_arc)
#define AZMStrongify(object) __typeof__(object) object = weak##_##object
#else
#define AZMStrongify(object) __typeof__(object) object = block##_##object
#endif
#endif
#endif
static __unused void _AZMBlockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}

#ifndef AZM_ON_EXIT
#define AZM_ON_EXIT __strong void(^block)(void) __attribute__((cleanup(_AZMBlockCleanUp), unused)) = ^
#endif
/**去除performSelector在ARC中的警告*/
#ifndef AZM_LEAK_WARNING_IGNORE
#define AZM_LEAK_WARNING_IGNORE(_method_) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
_method_; \
_Pragma("clang diagnostic pop") \
} while (0)
#endif
#endif /* AZMCategoriesMacro_h */
