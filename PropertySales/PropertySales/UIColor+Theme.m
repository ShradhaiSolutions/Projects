//
//  UIColor+Theme.m
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/23/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#import "UIColor+Theme.h"


@implementation UIColor (UIColor_Theme)

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([hexString hasPrefix:@"#"]) {
        [scanner setScanLocation:1]; // bypass '#' character
    }
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor*)colorWithHex:(int)hex
{
    float red = ((hex >> 24) & 0xFF)/255.0f;
    float green = ((hex >> 16) & 0xFF)/255.0f;
    float blue = ((hex >> 8) & 0xFF)/255.0f;
    float alpha = ((hex >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0,0,1,1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(UIColor*)blueTintColor {
    static UIColor *blueColor = nil;
    
    if (!blueColor){
        blueColor = [[UIColor alloc] initWithRed:0.153 green:0.486 blue:0.878 alpha:1.0]; 
    }
    
    return blueColor;
}

+(UIColor*)redTintColor {
    static UIColor *redColor = nil;
    
    if (!redColor){
        redColor = [[UIColor alloc ] initWithRed:0.792 green:0.059 blue:0.059 alpha:1.0]; 
    }
    
    return redColor;
}

+(UIColor*)greenTintColor {
    static UIColor *greenColor = nil;
    
    if (!greenColor){
        greenColor = [[UIColor alloc ] initWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    }
    
    return greenColor;
}

@end
