//
//  NSNumber+AZMOption.m
//  VideoEditTool
//
//  Created by mac219 on 20/11/13.
//  Copyright © 2020年 azmtb. All rights reserved.
//

#import "NSNumber+AZMOption.h"
#import "NSString+AZMOption.h"
#import "AZMCategoriesMacro.h"

AZM_SYNTH_DUMMY_CLASS(NSNumber_AZMOption)

@implementation NSNumber (AZMOption)
+ (NSNumber *)azm_numberWithString:(NSString *)string {
    NSString *str = [[string azm_stringByTrim] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }
    
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{@"true" :   @(YES),
                @"yes" :    @(YES),
                @"false" :  @(NO),
                @"no" :     @(NO),
                @"nil" :    [NSNull null],
                @"null" :   [NSNull null],
                @"<null>" : [NSNull null]};
    });
    NSNumber *num = dic[str];
    if (num) {
        if (num == (id)[NSNull null]) return nil;
        return num;
    }
    
    // hex number
    int sign = 0;
    if ([str hasPrefix:@"0x"]) sign = 1;
    else if ([str hasPrefix:@"-0x"]) sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num = -1;
        BOOL suc = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    // normal number
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];

	
}
@end
