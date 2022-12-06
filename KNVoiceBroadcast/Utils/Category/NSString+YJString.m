//

#import "NSString+YJString.h"

@implementation NSString (YJString)

+ (NSString *)stringFromNumber:(double)number {
    
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterSpellOutStyle;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    numFormatter.locale = locale;
    
    NSString *numStr = [numFormatter stringFromNumber:[NSNumber numberWithDouble:number]];
    
    return numStr;
}

@end
