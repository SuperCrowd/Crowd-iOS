//
//  macros.h
//  Crowd
//
//  Created by Bobby Gill on 11/1/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "LoggerClient.h"

#ifdef DEBUG
#define LOG_TWILIO(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"twilio",level,__VA_ARGS__)

#else
#define LOG_TWILIO(...) do {} while(0)
#endif