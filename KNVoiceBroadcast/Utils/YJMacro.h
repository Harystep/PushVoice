//

#ifndef YJMacro_h
#define YJMacro_h

//MARK: - device **************************************************************
#define yjIOS12_1   @available(iOS 12.1, *)
#define yjIOS12     @available(iOS 12.0, *)
#define yjIOS11     @available(iOS 11.0, *)
#define yjIOS10     @available(iOS 10.0, *)
#define yjIOS9      @available(iOS 9.0, *)
#define yjIOS8      @available(iOS 8.0, *)

//MARK: - screen **************************************************************
#define wdScreenWidth            CGRectGetWidth([UIScreen mainScreen].bounds)
#define wdScreenHeight           CGRectGetHeight([UIScreen mainScreen].bounds)
#define wdScreenBounds           [UIScreen mainScreen].bounds

#endif /* YJMacro_h */
