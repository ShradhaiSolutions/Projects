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

#define ENTRY_LOG      DDLogDebug(@"%s ENTRY ", __PRETTY_FUNCTION__);
#define EXIT_LOG       DDLogDebug(@"%s EXIT ", __PRETTY_FUNCTION__);
#define ERROR_EXIT_LOG DDLogError(@"%s ERROR EXIT", __PRETTY_FUNCTION__);


//Compiler does the string concatenation
#define LogVerbose(frmt, ...) DDLogVerbose(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogDebug(frmt, ...) DDLogDebug(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogInfo(frmt, ...) DDLogInfo(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogWarn(frmt, ...) DDLogWarn(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#define LogError(frmt, ...) DDLogError(@"%s: " frmt, __PRETTY_FUNCTION__, ##__VA_ARGS__);

#ifdef DEBUG
static int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static int ddLogLevel = LOG_LEVEL_ERROR;
#endif

#endif

//LogVerbose(@"Verbose");
//LogDebug(@"Debug");
//LogInfo(@"Info");
//LogWarn(@"Warn");
//LogError(@"Error");

