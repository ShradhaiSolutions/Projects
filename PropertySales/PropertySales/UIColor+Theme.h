//
//  UIColor+Theme.h
//  PropertySales
//
//  Created by Muddineti, Dhana (NonEmp) on 2/23/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface UIColor (UIColor_Theme)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)colorWithHex:(int)hex;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIColor *)blueTintColor;
+ (UIColor *)redTintColor;
+ (UIColor*)greenTintColor;

+ (UIColor*)differentTintColor;
@end
