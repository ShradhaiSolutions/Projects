//
//  PSLogging.h
//  PropertySales
//
//  Created by Dhana Prakash Muddineti on 2/1/14.
//  Copyright (c) 2014 Shradha iSolutions. All rights reserved.
//

#ifndef PropertySales_PSLogging_h
#define PropertySales_PSLogging_h

#import "DDLog.h"

#ifdef DEBUG

static int ddLogLevel = LOG_LEVEL_DEBUG;

#define ENTRY_LOG      DDLogDebug(@"%s ENTRY. isMainThread - %@", __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO");
#define EXIT_LOG       DDLogDebug(@"%s EXIT. isMainThread - %@", __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO");
#define ERROR_EXIT_LOG DDLogError(@"%s ERROR EXIT. isMainThread - %@", __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO");



#define LogVerbose(frmt, ...) DDLogVerbose(@"%s: isMainThread - %@:  " frmt, __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO", ##__VA_ARGS__);
#define LogDebug(frmt, ...) DDLogDebug(@"%s: isMainThread - %@:  " frmt, __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO", ##__VA_ARGS__);
#define LogInfo(frmt, ...) DDLogInfo(@"%s: isMainThread - %@:  " frmt, __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO", ##__VA_ARGS__);
#define LogWarn(frmt, ...) DDLogWarn(@"%s: isMainThread - %@:  " frmt, __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO", ##__VA_ARGS__);
#define LogError(frmt, ...) DDLogError(@"%s: isMainThread - %@:  " frmt, __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO", ##__VA_ARGS__);

//With whether the current thread is Main thread or not
#define LogDetails(frmt, ...) DDLogInfo(@"%s: isMainThread - %@:  " frmt, __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO", ##__VA_ARGS__);

#else

static int ddLogLevel = LOG_LEVEL_ERROR;

#define ENTRY_LOG      DDLogDebug(@"%s ENTRY ", __PRETTY_FUNCTION__);
#define EXIT_LOG       DDLogDebug(@"%s EXIT ", __PRETTY_FUNCTION__);
#define ERROR_EXIT_LOG DDLogError(@"%s ERROR EXIT", __PRETTY_FUNCTION__);

//Compiler does the string concatenation
#define LogVerbose(frmt, ...) DDLogVerbose(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogDebug(frmt, ...) DDLogDebug(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogInfo(frmt, ...) DDLogInfo(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogWarn(frmt, ...) DDLogWarn(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogError(frmt, ...) DDLogError(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);

//With whether the current thread is Main thread or not
#define LogDetails(frmt, ...) DDLogInfo(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);

#endif
