//
//  NSString+AZMOption.m
//  VideoEditTool
//
//  Created by mac219 on 20/1/27.
//  Copyright © 2020年 azmtb. All rights reserved.
//

#import "NSString+AZMOption.h"
#import "NSNumber+AZMOption.h"
#import "NSData+AZMOption.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "AZMCategoriesMacro.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

AZM_SYNTH_DUMMY_CLASS(NSString_AZMOption)

typedef enum {
    NSStringAuthCodeEncoded,
    NSStringAuthCodeDecoded
} NSStringAuthCode;

@implementation NSString (AZMOption)

+(NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    //NSData *data = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data=[NSData azm_dataWithHexString:encryptText];
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}
- (NSArray<NSString *> *)azm_toArray{
    if (!self.length) {
        return nil;
    }
    
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.length; i++) {
        NSString *stringItem = [self substringWithRange:NSMakeRange(i, 1)];
        [array addObject:stringItem];
    }
    return [array copy];
}
+ (NSInteger)azm_fileSizeAtPath:(NSString*)filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        //        NSLog(@"%d",[[manager attributesOfItemAtPath:filePath error:nil] fileSize]);
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (NSString *)md2String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md2String];
}

- (NSString *)md4String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md4String];
}

- (NSString *)md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5String];
}

- (NSString *)sha1String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha1String];
}

- (NSString *)sha224String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha224String];
}

- (NSString *)sha256String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha256String];
}

- (NSString *)sha384String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha384String];
}

- (NSString *)sha512String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha512String];
}

- (NSString *)crc32String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] crc32String];
}

- (NSString *)verticalString{
    if (!self.length) return self;
    NSMutableString *temp = @"".mutableCopy;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        [temp appendFormat:@"%@\n", substring];
    }];
    return [temp substringToIndex:temp.length - 1];
}
- (CGSize)azm_sizeWithfont:(UIFont *)font maxSize:(CGSize)maxSize{
    
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (CGSize)azm_sizeWithAttrs:(NSDictionary *)attrs maxSize:(CGSize)maxSize{
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size;
}

- (NSString *)azm_trimStringWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth{
    if (!self.length) {
        return self;
    }
    NSMutableString *temp = [NSMutableString stringWithString:self];
    for (int i = 0; i < temp.length;) {
        [temp deleteCharactersInRange:NSMakeRange(temp.length - 1, 1)];
        CGFloat width = [temp azm_sizeWithfont:font maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
        if (width <= maxWidth) break;
    }
    return temp.copy;
}

- (NSString *)azm_insertCommaFornumberString{
    
    NSString *new = [[self componentsSeparatedByString:@","] componentsJoinedByString:@""];
    NSUInteger pointIndex = [new rangeOfString:@"."].location == NSNotFound ? new.length : [new rangeOfString:@"."].location;
    NSString *temp = [new substringToIndex:pointIndex];
    NSMutableString *reslutStr = [NSMutableString stringWithString:new];
    int i = 1;
    while (temp.length > 3) {
        [reslutStr insertString:@"," atIndex:(pointIndex - 3 * i)];
        temp = [reslutStr substringToIndex:(pointIndex - 3 * i)];
        i++;
    }
    return reslutStr.copy;
}

- (float)azm_deleteCommaFornumberValue{
    NSMutableString *temp = [NSMutableString stringWithString:self];
    [temp replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, temp.length)];
    return [temp floatValue];
}

- (NSString *)azm_getPinYinWithChineseString{
    NSMutableString *ms = self.mutableCopy;
    CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO);
    return ms.copy;
}

- (NSString *)azm_stringByReplaceSpecial{
    NSString *str;
    str = [self stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    str = [str stringByReplacingOccurrencesOfString:@"&#8220;" withString:@"“"];
    str = [str stringByReplacingOccurrencesOfString:@"&#8221;" withString:@"”"];
    str = [str stringByReplacingOccurrencesOfString:@"&#8230;" withString:@"..."];
    str = [str stringByReplacingOccurrencesOfString:@"&#8764;" withString:@"~"];
    str = [str stringByReplacingOccurrencesOfString:@"&#8216;" withString:@"‘"];
    
    return str;
}
- (NSString *)azm_addSeperatorForPhoneString{
    NSMutableString *temp = [NSMutableString stringWithString:self];
    if (self.length > 7) {
        [temp insertString:@" " atIndex:3];
        [temp insertString:@" " atIndex:8];
    }else if (self.length > 3){
        [temp insertString:@" " atIndex:3];
    }
    return temp.copy;
}

- (NSString *)azm_hmacMD5StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            azm_hmacMD5StringWithKey:key];
}

- (NSString *)azm_hmacSHA1StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            azm_hmacSHA1StringWithKey:key];
	
}

- (NSString *)azm_hmacSHA224StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            azm_hmacSHA224StringWithKey:key];
	
}

- (NSString *)azm_hmacSHA256StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            azm_hmacSHA256StringWithKey:key];
	
}

- (NSString *)azm_hmacSHA384StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            azm_hmacSHA384StringWithKey:key];
	
}

- (NSString *)azm_hmacSHA512StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
            azm_hmacSHA512StringWithKey:key];
	
}

- (NSString *)azm_authCodeEncoded:(NSString *)key encoding:(NSStringEncoding)encoding
{
    return [self _azm_authCode:key operation:NSStringAuthCodeEncoded encoding:encoding expiry:0];
}

- (NSString *)azm_authCodeEncoded:(NSString *)key encoding:(NSStringEncoding)encoding expiry:(NSUInteger)expiry
{
    return [self _azm_authCode:key operation:NSStringAuthCodeEncoded encoding:encoding expiry:expiry];
}

- (NSString *)azm_authCodeEncoded:(NSString *)key
{
    return [self azm_authCodeEncoded:key encoding:NSISOLatin1StringEncoding];
}

- (NSString *)azm_authCodeDecoded:(NSString *)key encoding:(NSStringEncoding)encoding
{
    return [self _azm_authCode:key operation:NSStringAuthCodeDecoded encoding:encoding expiry:0];
}

- (NSString *)azm_authCodeDecoded:(NSString *)key encoding:(NSStringEncoding)encoding expiry:(NSUInteger)expiry
{
    return [self _azm_authCode:key operation:NSStringAuthCodeDecoded encoding:encoding expiry:expiry];
}

- (NSString *)azm_authCodeDecoded:(NSString *)key
{
    return [self azm_authCodeDecoded:key encoding:NSISOLatin1StringEncoding];
}

- (NSData *)hexData{
    if ([self length] ==0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc]initWithCapacity:[self length]*2];
    NSRange range;
    if ([self length] %2==0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [self length]; i +=2) {
        unsigned int anInt;
        NSString *hexCharStr = [self substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc]initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc]initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location+= range.length;
        range.length=2;
    }
    return hexData;
}

- (NSString *)azm_aes128DecryptWithkey:(NSString *)key iv:(NSString *)iv{
    return [[NSString alloc] initWithData:[self.hexData azm_aes256DecryptWithkey:[key dataUsingEncoding:NSUTF8StringEncoding] iv:[iv dataUsingEncoding:NSUTF8StringEncoding]] encoding:NSUTF8StringEncoding];
}

- (NSString *)azm_aes128EncryptWithKey:(NSString *)key iv:(NSString *)iv{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] azm_aes256EncryptWithKey:[key dataUsingEncoding:NSUTF8StringEncoding] iv:[iv dataUsingEncoding:NSUTF8StringEncoding]].hexString;
    
}

- (NSString *)base64DecodedString{
    NSData *data = [NSData azm_dataWithBase64EncodedString:self];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)base64EncodedString{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}
- (NSString *)azm_base64EncodedString:(NSStringEncoding)encoding {
    return [[self dataUsingEncoding:encoding] base64EncodedString];
    
}

- (NSString *)azm_base64DecodedString:(NSStringEncoding)encoding {
    NSData *data = [NSData azm_dataWithBase64EncodedString:self];
    return [[NSString alloc] initWithData:data encoding:encoding];
    
}

- (NSString *)urlDecodedString{
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)urlEncodedString{
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @""; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString * const kAFCharactersSubDelimitersToEncode = @"";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }

}

- (NSString *)escapingHTMLString{
    NSUInteger len = self.length;
    if (!len) return self;
    
    unichar *buf = malloc(sizeof(unichar) * len);
    if (!buf) return nil;
    [self getCharacters:buf range:NSMakeRange(0, len)];
    
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        unichar c = buf[i];
        NSString *esc = nil;
        switch (c) {
            case 34: esc = @"&quot;"; break;
            case 38: esc = @"&amp;"; break;
            case 39: esc = @"&apos;"; break;
            case 60: esc = @"&lt;"; break;
            case 62: esc = @"&gt;"; break;
            default: break;
        }
        if (esc) {
            [result appendString:esc];
        } else {
            CFStringAppendCharacters((CFMutableStringRef)result, &c, 1);
        }
    }
    free(buf);
    return result;

    
}

- (BOOL)azm_matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}

- (void)azm_enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                         usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}

- (NSString *)azm_stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                                withString:(NSString *)replacement {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return self;
    return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}
- (NSNumber *)numberValue {
    return [NSNumber azm_numberWithString:self];
}
- (char)charValue {
    return self.numberValue.charValue;
}

- (unsigned char) unsignedCharValue {
    return self.numberValue.unsignedCharValue;
}

- (short) shortValue {
    return self.numberValue.shortValue;
}

- (unsigned short) unsignedShortValue {
    return self.numberValue.unsignedShortValue;
}

- (unsigned int) unsignedIntValue {
    return self.numberValue.unsignedIntValue;
}

- (long) longValue {
    return self.numberValue.longValue;
}

- (unsigned long) unsignedLongValue {
    return self.numberValue.unsignedLongValue;
}

- (unsigned long long) unsignedLongLongValue {
    return self.numberValue.unsignedLongLongValue;
}

- (NSUInteger) unsignedIntegerValue {
    return self.numberValue.unsignedIntegerValue;
}

+ (NSString *)azm_stringWithUTF32Char:(UTF32Char)char32 {
    char32 = NSSwapHostIntToLittle(char32);
    return [[NSString alloc] initWithBytes:&char32 length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

+ (NSString *)azm_stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length {
    return [[NSString alloc] initWithBytes:(const void *)char32
                                    length:length * 4
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

- (void)azm_enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block {
    NSString *str = self;
    if (range.location != 0 || range.length != self.length) {
        str = [self substringWithRange:range];
    }
    NSUInteger len = [str lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    UTF32Char *char32 = (UTF32Char *)[str cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
    if (len == 0 || char32 == NULL) return;
    
    NSUInteger location = 0;
    BOOL stop = NO;
    NSRange subRange;
    UTF32Char oneChar;
    
    for (NSUInteger i = 0; i < len; i++) {
        oneChar = char32[i];
        subRange = NSMakeRange(location, oneChar > 0xFFFF ? 2 : 1);
        block(oneChar, subRange, &stop);
        if (stop) return;
        location += subRange.length;
    }
}

- (NSString *)azm_stringByAppendingNameScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

- (NSString *)azm_stringByAppendingPathScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    NSString *ext = self.pathExtension;
    NSRange extRange = NSMakeRange(self.length - ext.length, 0);
    if (ext.length > 0) extRange.location -= 1;
    NSString *scaleStr = [NSString stringWithFormat:@"@%@x", @(scale)];
    return [self stringByReplacingCharactersInRange:extRange withString:scaleStr];
}

- (NSString *)azm_scaledNameWithType:(NSString *)type{
    NSArray *scales = [NSString _azm_preferredScales];
    __block NSString *scaledName = nil;
    __block NSString *path = nil;
    [scales enumerateObjectsUsingBlock:^(NSNumber *scale, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [self azm_stringByAppendingNameScale:scale.floatValue];
        path = [[NSBundle mainBundle] pathForResource:name ofType:type];
        if (path) {
            scaledName = [name stringByAppendingString:[NSString stringWithFormat:@".%@", type]];
            *stop = YES;
        }
    }];
    return scaledName;
}

- (NSString *)azm_stringByTrim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (BOOL)azm_isNotBlank {
    NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![blank characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)azm_containsString:(NSString *)string {
    if (string == nil) return NO;
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)azm_containsCharacterSet:(NSCharacterSet *)set {
    if (set == nil) return NO;
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

+ (NSString *)azm_stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

- (NSData *)dataValue {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (id)jsonValue {
    return [[self dataValue] jsonValue];
}

- (NSString *)firstCharUpperString{
    if (self.length == 0) return self;
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%c", [self characterAtIndex:0]].uppercaseString];
    if (self.length >= 2) [string appendString:[self substringFromIndex:1]];
    return string;
}
#pragma mark --❤️-- private methods

+ (NSArray *)_azm_preferredScales {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

- (NSString *)azm_hexStringToString {
    NSMutableString * newString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [self length]){
        NSString * hexChar = [self substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    return newString.copy;
}

- (NSString *)_azm_authCode:(NSString *)auth_key operation:(NSStringAuthCode)operation encoding:(NSStringEncoding)encoding expiry:(NSInteger)expiry;
{
    int ckey_length = 4;
    NSString *keya ;
    NSString *keyb ;
    NSString *keyc ;
    if(auth_key.length > 16){
        keya = [[auth_key substringToIndex:16] md5String];
        keyb = [[auth_key substringWithRange:NSMakeRange(16,16)] md5String];
    }else{
        keya = [auth_key md5String];
        keyb = [[[NSString alloc] init] md5String];
    }
    long now = (long)([[NSDate date] timeIntervalSince1970] * 1000.0f);
    NSString *nowString = [[NSString alloc]initWithFormat:@"%ld",now];
    keyc = ckey_length > 0 ? (operation == NSStringAuthCodeDecoded ? [self substringToIndex:ckey_length] : [[nowString md5String] substringFromIndex:([nowString md5String].length - ckey_length)]) : @"";
    NSString *tempKey =[[NSString alloc]initWithFormat:@"%@%@",keya,keyc];
    NSString *key = [[NSString alloc]initWithFormat:@"%@%@",keya,[tempKey md5String]];
    
    NSUInteger key_length = key.length;
    NSString *string ;
    if(operation == NSStringAuthCodeDecoded){
        string = [[self substringFromIndex:ckey_length] azm_base64DecodedString: encoding];
        if(string == nil){
            return nil;
        }
    }else{
        NSString *timeString;
        if(expiry > 0){
            timeString = [[NSString alloc]initWithFormat:@"%010d",(int)([[NSDate date] timeIntervalSince1970] + expiry)];
        }else{
            timeString = [[NSString alloc]initWithFormat:@"%010d",0];
        }
        NSString *temp = [[[[self stringByAppendingString:keyb] md5String] substringToIndex:16] stringByAppendingString:self];
        string = [timeString stringByAppendingString:temp];
    }
    NSUInteger string_length = string.length;
    
    NSMutableArray *rndkey = [NSMutableArray array];
    NSMutableArray *box = [NSMutableArray array];
    NSMutableString *result = [NSMutableString string];
    
    for(int i = 0; i <= 255; i++) {
        [rndkey addObject:[NSNumber numberWithUnsignedShort:[key characterAtIndex:i%key_length]]];
        [box addObject:[NSNumber numberWithUnsignedShort:i]];
    }
    
    int j = 0;
    for(int i = 0; i < 256; i++) {
        unsigned short b = [[box objectAtIndex:i] unsignedShortValue];
        unsigned short r = [[rndkey objectAtIndex:i] unsignedShortValue];
        j = (j + b + r) % 256;
        [box replaceObjectAtIndex:i withObject:[box objectAtIndex:j]];
        [box replaceObjectAtIndex:j withObject:[NSNumber numberWithUnsignedShort:b]];
    }
    
    int a = 0;
    j = 0;
    for(int i = 0; i < string_length; i++) {
        a = (a + 1) % 256;
        unsigned short b = [[box objectAtIndex:a] unsignedShortValue];
        j = (j + b) % 256;
        [box replaceObjectAtIndex:a withObject:[box objectAtIndex:j]];
        [box replaceObjectAtIndex:j withObject:[NSNumber numberWithUnsignedShort:b]];
        
        unsigned short sc = [string characterAtIndex:i];
        unsigned short bi = [[box objectAtIndex:(([[box objectAtIndex:a] unsignedShortValue] + [[box objectAtIndex:j] unsignedShortValue]) % 256)] unsignedShortValue];
        unsigned short k = sc ^ bi;
        [result appendFormat:@"%C",k];
    }
    if(operation == NSStringAuthCodeDecoded) {
        NSString *time = [result substringToIndex:10];
        NSString *check = [result substringWithRange:NSMakeRange(10, 16)];
        NSString *check1 = [[[[result substringFromIndex:26] stringByAppendingString:keyb] md5String] substringToIndex:16];
        if([time intValue] == 0 || [time intValue] > (int)[[NSDate date] timeIntervalSince1970]){
            if([check isEqualToString: check1]){
                return [result substringFromIndex:26];
            }else{
                return nil;
            }
        }else{
            return nil;
        }
    } else {
        return [keyc stringByAppendingString:[[result azm_base64EncodedString:encoding] stringByReplacingOccurrencesOfString:@"=" withString:@""]];
    }
}

- (BOOL)_azm_isValidateByRegex:(NSString *)regex {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pre evaluateWithObject:self];
}

- (BOOL)azm_isNumber{
    NSString *regex = @"^[0-9]*$";
    return [self _azm_isValidateByRegex:regex];
}

- (BOOL)azm_isPhoneNumberBy11Num {
    NSString *regex = @"^[0-9]{11}";
    return [self _azm_isValidateByRegex:regex];
}

- (BOOL)azm_isMobileNumber{
    /**
     *  手机号以13、15、18、170开头，8个 \\d 数字字符
     *  小灵通 区号：010,020,021,022,023,024,025,027,028,029 还有未设置的新区号xxx
     */
    NSString *mobileNoRegex = @"^1((3\\d|5[0-35-9]|8[025-9])\\d|70[059])\\d{7}$";//除4以外的所有个位整数，不能使用[^4,\\d]匹配，这里是否iOS Bug?
    NSString *phsRegex =@"^0(10|2[0-57-9]|\\d{3})\\d{7,8}$";
    
    BOOL ret = [self _azm_isValidateByRegex:mobileNoRegex];
    BOOL ret1 = [self _azm_isValidateByRegex:phsRegex];
    return (ret || ret1);
}

- (BOOL)azm_isEmailAddress {
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self _azm_isValidateByRegex:emailRegex];
}

- (BOOL)azm_isSimpleVerifyIdentityCardNum {
    NSString *regex2 = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    return [self _azm_isValidateByRegex:regex2];
}

- (BOOL)azm_isCarNumber{
    //车牌号:湘K-DE829 香港车牌号码:粤Z-J499港
    NSString *carRegex = @"^[\\u4e00-\\u9fff]{1}[a-zA-Z]{1}[-][a-zA-Z_0-9]{4}[a-zA-Z_0-9_\\u4e00-\\u9fff]$";//其中\\u4e00-\\u9fa5表示unicode编码中汉字已编码部分，\\u9fa5-\\u9fff是保留部分，将来可能会添加
    return [self _azm_isValidateByRegex:carRegex];
}

- (BOOL)azm_isMacAddress{
    NSString * macAddRegex = @"([A-Fa-f\\d]{2}:){5}[A-Fa-f\\d]{2}";
    return  [self _azm_isValidateByRegex:macAddRegex];
}

- (BOOL)azm_isUrl
{
    NSString *regex = @"^((http)|(https))+:[^\\s]+\\.[^\\s]*$";
    return [self _azm_isValidateByRegex:regex];
}

- (BOOL)azm_isChinese;
{
    NSString *chineseRegex = @"^[\\u4e00-\\u9fa5]+$";
    return [self _azm_isValidateByRegex:chineseRegex];
}

- (BOOL)azm_isPostalcode {
    NSString *postalRegex = @"^[0-8]\\d{5}(?!\\d)$";
    return [self _azm_isValidateByRegex:postalRegex];
}

- (BOOL)azm_isTaxNo
{
    NSString *taxNoRegex = @"[0-9]\\d{13}([0-9]|X)$";
    return [self _azm_isValidateByRegex:taxNoRegex];
}

- (BOOL)azm_isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;
{
    //  [\\u4e00-\\u9fa5A-Za-z0-9_]{4,20}
    NSString *hanzi = containChinese ? @"\\u4e00-\\u9fa5" : @"";
    NSString *first = firstCannotBeDigtal ? @"^[a-zA-Z_]" : @"";
    
    NSString *regex = [NSString stringWithFormat:@"%@[%@A-Za-z0-9_]{%d,%d}", first, hanzi, (int)(minLenth-1), (int)(maxLenth-1)];
    return [self _azm_isValidateByRegex:regex];
}

- (BOOL)azm_isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
              containDigtal:(BOOL)containDigtal
              containLowLetter:(BOOL)containLowLetter
              containUpLetter:(BOOL)containUpLetter
      containOtherCharacter:(NSString *)containOtherCharacter
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;
{
    NSString *firstRegex = firstCannotBeDigtal ? @"^[a-zA-Z_]" : @"";
    NSString *containRegex = [NSString stringWithFormat:@"%@%@%@%@%@",containChinese ? @"\\u4e00-\\u9fa5" : @"", containLowLetter ? @"a-z" : @"", containUpLetter ? @"A-Z" : @"", containDigtal ? @"0-9" : @"", containOtherCharacter ?: @""];
    NSString *lengthRegex = [NSString stringWithFormat:@"(?=^.{%@,%@}$)", @(minLenth), @(maxLenth)];
    NSString *regex = [NSString stringWithFormat:@"%@(?:%@[%@]+)", lengthRegex, firstRegex, containRegex];
    return [self _azm_isValidateByRegex:regex];
}

//精确的身份证号码有效性检测
- (BOOL)azm_accurateVerifyIDCardNumber {
    NSString *value = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    int length =0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    if (!areaFlag) {
        return false;
    }
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    switch (length) {
        case 15:
        year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
        
        if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
            
            regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                     options:NSRegularExpressionCaseInsensitive
                                                                       error:nil];//测试出生日期的合法性
        }else {
            regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                    options:NSRegularExpressionCaseInsensitive
                                                                      error:nil];//测试出生日期的合法性
        }
        numberofMatch = [regularExpression numberOfMatchesInString:value
                                                           options:NSMatchingReportProgress
                                                             range:NSMakeRange(0, value.length)];
        
        if(numberofMatch >0) {
            return YES;
        }else {
            return NO;
        }
        case 18:
        year = [value substringWithRange:NSMakeRange(6,4)].intValue;
        if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
            
            regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                     options:NSRegularExpressionCaseInsensitive
                                                                       error:nil];//测试出生日期的合法性
        }else {
            regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                     options:NSRegularExpressionCaseInsensitive
                                                                       error:nil];//测试出生日期的合法性
        }
        numberofMatch = [regularExpression numberOfMatchesInString:value
                                                           options:NSMatchingReportProgress
                                                             range:NSMakeRange(0, value.length)];
        
        if(numberofMatch >0) {
            int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
            int Y = S %11;
            NSString *M =@"F";
            NSString *JYM =@"10X98765432";
            M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
            if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                return YES;// 检测ID的校验位
            }else {
                return NO;
            }
            
        }else {
            return NO;
        }
        default:
        return NO;
    }
}

/** 银行卡号有效性问题Luhn算法
 *  现行 16 位银联卡现行卡号开头 6 位是 622126～622925 之间的，7 到 15 位是银行自定义的，
 *  可能是发卡分行，发卡网点，发卡序号，第 16 位是校验码。
 *  16 位卡号校验位采用 Luhm 校验方法计算：
 *  1，将未带校验位的 15 位卡号从右依次编号 1 到 15，位于奇数位号上的数字乘以 2
 *  2，将奇位乘积的个十位全部相加，再加上所有偶数位上的数字
 *  3，将加法和加上校验位能被 10 整除。
 */
- (BOOL)azm_isBankCard{
    NSString * lastNum = [[self substringFromIndex:(self.length-1)] copy];//取出最后一位
    NSString * forwardNum = [[self substringToIndex:(self.length -1)] copy];//前15或18位
    
    NSMutableArray * forwardArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<forwardNum.length; i++) {
        NSString * subStr = [forwardNum substringWithRange:NSMakeRange(i, 1)];
        [forwardArr addObject:subStr];
    }
    
    NSMutableArray * forwardDescArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = (int)(forwardArr.count-1); i> -1; i--) {//前15位或者前18位倒序存进数组
        [forwardDescArr addObject:forwardArr[i]];
    }
    
    NSMutableArray * arrOddNum = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 < 9
    NSMutableArray * arrOddNum2 = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 > 9
    NSMutableArray * arrEvenNum = [[NSMutableArray alloc] initWithCapacity:0];//偶数位数组
    
    for (int i=0; i< forwardDescArr.count; i++) {
        NSInteger num = [forwardDescArr[i] intValue];
        if (i%2) {//偶数位
            [arrEvenNum addObject:[NSNumber numberWithInteger:num]];
        }else{//奇数位
            if (num * 2 < 9) {
                [arrOddNum addObject:[NSNumber numberWithInteger:num * 2]];
            }else{
                NSInteger decadeNum = (num * 2) / 10;
                NSInteger unitNum = (num * 2) % 10;
                [arrOddNum2 addObject:[NSNumber numberWithInteger:unitNum]];
                [arrOddNum2 addObject:[NSNumber numberWithInteger:decadeNum]];
            }
        }
    }
    
    __block  NSInteger sumOddNumTotal = 0;
    [arrOddNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNumTotal += [obj integerValue];
    }];
    
    __block NSInteger sumOddNum2Total = 0;
    [arrOddNum2 enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNum2Total += [obj integerValue];
    }];
    
    __block NSInteger sumEvenNumTotal =0 ;
    [arrEvenNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumEvenNumTotal += [obj integerValue];
    }];
    
    NSInteger lastNumber = [lastNum integerValue];
    
    NSInteger luhmTotal = lastNumber + sumEvenNumTotal + sumOddNum2Total + sumOddNumTotal;
    
    return (luhmTotal%10 ==0)?YES:NO;
}

+ (NSString *)azm_hexStringWithInteger:(NSInteger)integer {
    NSString *hexString = @"";
    NSInteger remainder = 0;
    for (NSInteger i = 0; i < 9; i++) {
        remainder = integer % 16;
        integer = integer / 16;
        NSString *letter = [self hexLetterStringWithInteger:remainder];
        hexString = [letter stringByAppendingString:hexString];
        if (integer == 0) {
            break;
        }
        
    }
    return hexString;
}

-(NSString *)deleteCharacters{
    
    if (self.length==0 || !self) {
        return nil;
    }
    
    NSError *error = nil;
    NSString *pattern = @"[^a-zA-Z0-9\u4e00-\u9fa5]";//正则取反
    NSRegularExpression *regularExpress = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];//这个正则可以去掉所有特殊字符和标点
    NSString *string = [regularExpress stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
    
    return string;
}

+ (NSString *)hexLetterStringWithInteger:(NSInteger)integer {
    NSAssert(integer < 16, @"要转换的数必须是16进制里的个位数，也即小于16，但你传给我是%@", @(integer));
    
    NSString *letter = nil;
    switch (integer) {
        case 10:
            letter = @"A";
            break;
        case 11:
            letter = @"B";
            break;
        case 12:
            letter = @"C";
            break;
        case 13:
            letter = @"D";
            break;
        case 14:
            letter = @"E";
            break;
        case 15:
            letter = @"F";
            break;
        default:
            letter = [[NSString alloc]initWithFormat:@"%@", @(integer)];
            break;
    }
    return letter;
}

- (BOOL)azm_isIPAddress{
    NSString *regex = [NSString stringWithFormat:@"^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL rc = [pre evaluateWithObject:self];
    
    if (rc) {
        NSArray *componds = [self componentsSeparatedByString:@"."];
        
        BOOL v = YES;
        for (NSString *s in componds) {
            if (s.integerValue > 255) {
                v = NO;
                break;
            }
        }
        
        return v;
    }
    
    return NO;
}

- (NSInteger)azm_textLength {
    CGFloat count = 0;
    for (int i=0; i<self.length; i++) {
        NSRange range = NSMakeRange(i, 1) ;
        NSString *aStr = [self substringWithRange:range];
        // 中文算一个，英文算两个字符
        count += [aStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1?1:0.5;
    }
    return (NSInteger)count;
}

- (NSString *)azm_subTextLength:(NSInteger)len {
    if(self.length<=len) return self;
    int count=0;
    NSMutableString *sb = [NSMutableString string];
    for (int i=0; i<self.length; i++) {
        NSRange range = NSMakeRange(i, 1) ;
        NSString *aStr = [self substringWithRange:range];
        count += [aStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1?2:1;
        [sb appendString:aStr];
        if(count >= len*2) {
            return [sb copy];
        }
    }
    return self;
}

- (BOOL)azm_stringIsEmpty{
    
    if (!self || self.length == 0) {
        return YES;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [self stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0 || !trimedString) {
            return YES;
        } else {
            return NO;
        }
    }
    
}

- (NSString *)azm_stringByRemoveLastCharacter {
    return [self azm_stringByRemoveCharacterAtIndex:self.length - 1];
}

- (NSString *)azm_stringByRemoveCharacterAtIndex:(NSUInteger)index {
    NSRange rangeForRemove = [self rangeOfComposedCharacterSequenceAtIndex:index];
    NSString *resultString = [self stringByReplacingCharactersInRange:rangeForRemove withString:@""];
    return resultString;
}
@end
