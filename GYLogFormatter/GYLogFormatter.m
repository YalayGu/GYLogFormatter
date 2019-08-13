//
//  GYLogFormatter.m
//  GYLogFormatter
//
//  Created by Yalay Gu on 2019/8/13.
//  Copyright © 2019 Yalay Gu. All rights reserved.
//

#if DEBUG

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static inline void gy_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    BOOL isAddedMethod = class_addMethod(theClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (isAddedMethod) {
        class_replaceMethod(theClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark -

typedef NS_ENUM(NSUInteger, GYLogFormatterObjectType) {
    GYLogFormatterObjectTypeArray,
    GYLogFormatterObjectTypeSet,
    GYLogFormatterObjectTypeDictionary,
};

static NSDictionary<NSNumber *, NSArray *> *__bracketsMap;

@interface GYLogFormatter : NSObject

@end

@implementation GYLogFormatter

+ (void)load
{
    __bracketsMap = @{@(GYLogFormatterObjectTypeArray)      : @[@"[", @"]"],
                      @(GYLogFormatterObjectTypeSet)        : @[@"(", @")"],
                      @(GYLogFormatterObjectTypeDictionary) : @[@"{", @"}"]
                      };
}


+ (NSString *)formatChildObject:(id)childObject locale:(id)locale indent:(NSUInteger)level
{
    if ([childObject respondsToSelector:@selector(descriptionWithLocale:indent:)]) {
        return [childObject descriptionWithLocale:locale indent:level];
    } else if ([childObject isKindOfClass:NSString.class]) {
        return [NSString stringWithFormat:@"\"%@\"", childObject];
    } else {
        return [NSString stringWithFormat:@"%@", childObject];
    }
}

+ (NSString *)gy_descriptionWithLocale:(id)locale indent:(NSUInteger)level instance:(id)instance objectType:(GYLogFormatterObjectType)objectType
{
    NSMutableArray *appendFormatLines = [NSMutableArray array];
    [appendFormatLines addObject:__bracketsMap[@(objectType)].firstObject];
    if (objectType == GYLogFormatterObjectTypeDictionary) {
        [instance enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            NSString *formatKeyString = [self formatChildObject:key locale:locale indent:level + 1];
            NSString *formatObjectString = [self formatChildObject:object locale:locale indent:level + 1];
            NSString *formatString = [NSString stringWithFormat:@"    %@ = %@;", formatKeyString, formatObjectString];
            [appendFormatLines addObject:formatString];
        }];
    } else {
        [instance enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
            NSString *formatObjectString = [self formatChildObject:object locale:locale indent:level + 1];
            NSString *formatString = [NSString stringWithFormat:@"    %@,", formatObjectString];
            [appendFormatLines addObject:formatString];
        }];
    }
    [appendFormatLines addObject:__bracketsMap[@(objectType)].lastObject];
    NSMutableString *indentation = NSMutableString.string;
    if ([instance count]) {
        [indentation appendString:@"\n"];
        for (int i = 0; i < level; i++) {
            [indentation appendString:@"    "];
        }
    }
    return [appendFormatLines componentsJoinedByString:indentation];
}

@end

@implementation NSSet (LogPrintChinese)

+ (void)load
{
    gy_swizzleSelector(self, @selector(descriptionWithLocale:indent:), @selector(log_descriptionWithLocale:indent:));
}

- (NSString *)log_descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [GYLogFormatter gy_descriptionWithLocale:locale indent:level instance:self objectType:GYLogFormatterObjectTypeSet];
}

@end

@implementation NSArray (LogPrintChinese)

+ (void)load
{
     gy_swizzleSelector(self, @selector(descriptionWithLocale:indent:), @selector(log_descriptionWithLocale:indent:));
}

- (NSString *)log_descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [GYLogFormatter gy_descriptionWithLocale:locale indent:level instance:self objectType:GYLogFormatterObjectTypeArray];
}

@end

@implementation NSDictionary (LogPrintChinese)

+ (void)load
{
    gy_swizzleSelector(self, @selector(descriptionWithLocale:indent:), @selector(log_descriptionWithLocale:indent:));
}

- (NSString *)log_descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [GYLogFormatter gy_descriptionWithLocale:locale indent:level instance:self objectType:GYLogFormatterObjectTypeDictionary];
}

@end

#endif
