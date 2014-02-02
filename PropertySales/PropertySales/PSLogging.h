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

#define ENTRY_LOG      DDLogVerbose(@"%s ENTRY ", __PRETTY_FUNCTION__);
#define EXIT_LOG       DDLogVerbose(@"%s EXIT ", __PRETTY_FUNCTION__);
#define ERROR_EXIT_LOG DDLogError(@"%s ERROR EXIT", __PRETTY_FUNCTION__);

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

#endif
