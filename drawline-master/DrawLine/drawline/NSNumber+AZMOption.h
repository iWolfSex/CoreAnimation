//
//  NSNumber+AZMOption.h
//  VideoEditTool
//
//  Created by mac219 on 20/11/13.
//  Copyright © 2020年 azmtb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (AZMOption)

/**将NSString数字字符串转成NSNumber，如果满足规则返回想要值，不满足返回nil*/
+ (nullable NSNumber *)azm_numberWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
