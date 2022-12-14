//

#import "NSDictionary+YJDictionary.h"

@implementation NSDictionary (YJDictionary)

- (id)nunullValueForKey:(NSString *)key {
    id object = [self valueForKey:key];
    if ([object isEqual:[NSNull null]]) return nil;
    return object;
}

- (id)nunullObjectForKey:(NSString *)key {
    id object = [self objectForKey:key];
    
    if ([object isEqual:[NSNull null]]) return nil;
    return object;
}

@end
