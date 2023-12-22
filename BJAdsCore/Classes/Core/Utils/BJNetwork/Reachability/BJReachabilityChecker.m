// Copyright 2017 Google
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>
#import "BJReachabilityChecker.h"
#import "BJReachabilityChecker+Internal.h"
#import "BJReachabilityMessageCode.h"

//static GULLoggerService kGULLoggerReachability = @"[GULReachability]";
#if !TARGET_OS_WATCH
static void ReachabilityCallback(SCNetworkReachabilityRef reachability,
                                 SCNetworkReachabilityFlags flags,
                                 void *info);

static const struct BJReachabilityApi kGULDefaultReachabilityApi = {
    SCNetworkReachabilityCreateWithName,
    SCNetworkReachabilitySetCallback,
    SCNetworkReachabilityScheduleWithRunLoop,
    SCNetworkReachabilityUnscheduleFromRunLoop,
    CFRelease,
};

static NSString *const kBJReachabilityUnknownStatus = @"Unknown";
static NSString *const kGULReachabilityConnectedStatus = @"Connected";
static NSString *const kGULReachabilityDisconnectedStatus = @"Disconnected";
#endif
@interface BJReachabilityChecker ()

@property(nonatomic, assign) const struct BJReachabilityApi *reachabilityApi;
@property(nonatomic, assign) BJReachabilityStatus reachabilityStatus;
@property(nonatomic, copy) NSString *host;
#if !TARGET_OS_WATCH
@property(nonatomic, assign) SCNetworkReachabilityRef reachability;
#endif

@end

@implementation BJReachabilityChecker

@synthesize reachabilityApi = reachabilityApi_;
#if !TARGET_OS_WATCH
@synthesize reachability = reachability_;
#endif

- (const struct BJReachabilityApi *)reachabilityApi {
  return reachabilityApi_;
}

- (void)setReachabilityApi:(const struct BJReachabilityApi *)reachabilityApi {
#if !TARGET_OS_WATCH
  if (reachability_) {
//    GULLogError(kGULLoggerReachability, NO,
//                [NSString stringWithFormat:@"I-REA%06ld", (long)kBJReachabilityMessageCode000],
//                @"Cannot change reachability API while reachability is running. "
//                @"Call stop first.");
    return;
  }
  reachabilityApi_ = reachabilityApi;
#endif
}

@synthesize reachabilityStatus = reachabilityStatus_;
@synthesize host = host_;
@synthesize reachabilityDelegate = reachabilityDelegate_;

- (BOOL)isActive {
#if !TARGET_OS_WATCH
  return reachability_ != nil;
#else
  return NO;
#endif
}

- (void)setReachabilityDelegate:(id<BJReachabilityDelegate>)reachabilityDelegate {
  if (reachabilityDelegate &&
      (![(NSObject *)reachabilityDelegate conformsToProtocol:@protocol(BJReachabilityDelegate)])) {
//    GULLogError(kGULLoggerReachability, NO,
//                [NSString stringWithFormat:@"I-NET%06ld", (long)kBJReachabilityMessageCode005],
//                @"Reachability delegate doesn't conform to Reachability protocol.");
    return;
  }
  reachabilityDelegate_ = reachabilityDelegate;
}

- (instancetype)initWithReachabilityDelegate:(id<BJReachabilityDelegate>)reachabilityDelegate
                                    withHost:(NSString *)host {
  self = [super init];

  if (!host || !host.length) {
//    GULLogError(kGULLoggerReachability, NO,
//                [NSString stringWithFormat:@"I-REA%06ld", (long)kBJReachabilityMessageCode001],
//                @"Invalid host specified");
    return nil;
  }
  if (self) {
#if !TARGET_OS_WATCH
    [self setReachabilityDelegate:reachabilityDelegate];
    reachabilityApi_ = &kGULDefaultReachabilityApi;
    reachabilityStatus_ = kBJReachabilityUnknown;
    host_ = [host copy];
    reachability_ = nil;
#endif
  }
  return self;
}

- (void)dealloc {
  reachabilityDelegate_ = nil;
  [self stop];
}

- (BOOL)start {
#if TARGET_OS_WATCH
  return NO;
#else

  if (!reachability_) {
    reachability_ = reachabilityApi_->createWithNameFn(kCFAllocatorDefault, [host_ UTF8String]);
    if (!reachability_) {
      return NO;
    }
    SCNetworkReachabilityContext context = {
        0,                       /* version */
        (__bridge void *)(self), /* info (passed as last parameter to reachability callback) */
        NULL,                    /* retain */
        NULL,                    /* release */
        NULL                     /* copyDescription */
    };
    if (!reachabilityApi_->setCallbackFn(reachability_, ReachabilityCallback, &context) ||
        !reachabilityApi_->scheduleWithRunLoopFn(reachability_, CFRunLoopGetMain(),
                                                 kCFRunLoopCommonModes)) {
      reachabilityApi_->releaseFn(reachability_);
      reachability_ = nil;

//      GULLogError(kGULLoggerReachability, NO,
//                  [NSString stringWithFormat:@"I-REA%06ld", (long)kBJReachabilityMessageCode002],
//                  @"Failed to start reachability handle");
      return NO;
    }
  }
//  GULLogDebug(kGULLoggerReachability, NO,
//              [NSString stringWithFormat:@"I-REA%06ld", (long)kBJReachabilityMessageCode003],
//              @"Monitoring the network status");
  return YES;
#endif
}

- (void)stop {
#if !TARGET_OS_WATCH
  if (reachability_) {
    reachabilityStatus_ = kBJReachabilityUnknown;
    reachabilityApi_->unscheduleFromRunLoopFn(reachability_, CFRunLoopGetMain(),
                                              kCFRunLoopCommonModes);
    reachabilityApi_->releaseFn(reachability_);
    reachability_ = nil;
  }
#endif
}

#if !TARGET_OS_WATCH
- (BJReachabilityStatus)statusForFlags:(SCNetworkReachabilityFlags)flags {
  BJReachabilityStatus status = kBJReachabilityNotReachable;
  // If the Reachable flag is not set, we definitely don't have connectivity.
  if (flags & kSCNetworkReachabilityFlagsReachable) {
    // Reachable flag is set. Check further flags.
    if (!(flags & kSCNetworkReachabilityFlagsConnectionRequired)) {
// Connection required flag is not set, so we have connectivity.
#if TARGET_OS_IOS || TARGET_OS_TV
      status = (flags & kSCNetworkReachabilityFlagsIsWWAN) ? kBJReachabilityViaCellular
                                                           : kBJReachabilityViaWifi;
#elif TARGET_OS_OSX
      status = kBJReachabilityViaWifi;
#endif
    } else if ((flags & (kSCNetworkReachabilityFlagsConnectionOnDemand |
                         kSCNetworkReachabilityFlagsConnectionOnTraffic)) &&
               !(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
// If the connection on demand or connection on traffic flag is set, and user intervention
// is not required, we have connectivity.
#if TARGET_OS_IOS || TARGET_OS_TV
      status = (flags & kSCNetworkReachabilityFlagsIsWWAN) ? kBJReachabilityViaCellular
                                                           : kBJReachabilityViaWifi;
#elif TARGET_OS_OSX
      status = kBJReachabilityViaWifi;
#endif
    }
  }
  return status;
}

- (void)reachabilityFlagsChanged:(SCNetworkReachabilityFlags)flags {
  BJReachabilityStatus status = [self statusForFlags:flags];
  if (reachabilityStatus_ != status) {
    NSString *reachabilityStatusString;
    if (status == kBJReachabilityUnknown) {
      reachabilityStatusString = kBJReachabilityUnknownStatus;
    } else {
      reachabilityStatusString = (status == kBJReachabilityNotReachable)
                                     ? kGULReachabilityDisconnectedStatus
                                     : kGULReachabilityConnectedStatus;
    }

//    GULLogDebug(kGULLoggerReachability, NO,
//                [NSString stringWithFormat:@"I-REA%06ld", (long)kBJReachabilityMessageCode004],
//                @"Network status has changed. Code:%@, status:%@", @(status),
//                reachabilityStatusString);
    reachabilityStatus_ = status;
    [reachabilityDelegate_ reachability:self statusChanged:reachabilityStatus_];
  }
}

#endif
@end

#if !TARGET_OS_WATCH
static void ReachabilityCallback(SCNetworkReachabilityRef reachability,
                                 SCNetworkReachabilityFlags flags,
                                 void *info) {
  BJReachabilityChecker *checker = (__bridge BJReachabilityChecker *)info;
  [checker reachabilityFlagsChanged:flags];
}
#endif

// This function used to be at the top of the file, but it was moved here
// as a workaround for a suspected compiler bug. When compiled in Release mode
// and run on an iOS device with WiFi disabled, the reachability code crashed
// when calling SCNetworkReachabilityScheduleWithRunLoop, or shortly thereafter.
// After unsuccessfully trying to diagnose the cause of the crash, it was
// discovered that moving this function to the end of the file magically fixed
// the crash. If you are going to edit this file, exercise caution and make sure
// to test thoroughly with an iOS device under various network conditions.
const NSString *BJReachabilityStatusString(BJReachabilityStatus status) {
  switch (status) {
    case kBJReachabilityUnknown:
      return @"Reachability Unknown";

    case kBJReachabilityNotReachable:
      return @"Not reachable";

    case kBJReachabilityViaWifi:
      return @"Reachable via Wifi";

    case kBJReachabilityViaCellular:
      return @"Reachable via Cellular Data";

    default:
      return [NSString stringWithFormat:@"Invalid reachability status %d", (int)status];
  }
}
