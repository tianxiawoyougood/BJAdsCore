//
//  BJNetwork.m
//  NetWorkDemo
//
//  Created by cc on 2022/4/22.
//

#import "BJNetwork.h"
#import "BJNetworkMessageCode.h"
#import "BJNetworkInternal.h"
#import "BJMutableDictionary.h"
#import "BJNetworkConstants.h"
#import "BJReachabilityChecker.h"

#define WeakSelf(weakSelf)  __weak __typeof(self) weakSelf = self;
#define StrongSelf(strongSelf)   __strong typeof(self) strongSelf = weakSelf;


/// Constant string for request header Content-Encoding.
static NSString *const kBJNetworkContentCompressionKey = @"Content-Encoding";

/// Constant string for request header Content-Encoding value.
static NSString *const kBJNetworkContentCompressionValue = @"gzip";

/// Constant string for request header Content-Length.
static NSString *const kBJNetworkContentLengthKey = @"Content-Length";

/// Constant string for request header Content-Type.
static NSString *const kBJNetworkContentTypeKey = @"Content-Type";

/// Constant string for request header Content-Type value.
static NSString *const kBJNetworkContentTypeValue = @"application/x-www-form-urlencoded";

/// Constant string for GET request method.
static NSString *const kBJNetworkGETRequestMethod = @"GET";

/// Constant string for POST request method.
static NSString *const kBJNetworkPOSTRequestMethod = @"POST";

/// Default constant string as a prefix for network logger.
static NSString *const kBJNetworkLogTag = @"Google/Utilities/Network";

@interface BJNetwork ()<BJReachabilityDelegate, BJNetworkLoggerProtocol>{
    /// Network reachability.
    BJReachabilityChecker *_reachability;
}

/// The dictionary of requests by session IDs { NSString : id }.
@property(nonatomic, strong) BJMutableDictionary *requests;

@end

@implementation BJNetwork

- (instancetype)init {
  return [self initWithReachabilityHost:kBJNetworkReachabilityHost];
}

- (instancetype)initWithReachabilityHost:(NSString *)reachabilityHost {
  self = [super init];
  if (self) {
    // Setup reachability.
    _reachability = [[BJReachabilityChecker alloc] initWithReachabilityDelegate:self
                                                                        withHost:reachabilityHost];
    if (![_reachability start]) {
      return nil;
    }

    _requests = [[BJMutableDictionary alloc] init];
    _timeoutInterval = kBJNetworkTimeOutInterval;
  }
  return self;
}

- (void)dealloc {
  _reachability.reachabilityDelegate = nil;
  [_reachability stop];
}

#pragma mark - External Methods

+ (void)handleEventsForBackgroundURLSessionID:(NSString *)sessionID
                            completionHandler:(BJNetworkSystemCompletionHandler)completionHandler {
  [BJNetworkURLSession handleEventsForBackgroundURLSessionID:sessionID
                                            completionHandler:completionHandler];
}

- (NSString *)postURL:(NSURL *)url
                   payload:(NSData *)payload
                     queue:(dispatch_queue_t)queue
    usingBackgroundSession:(BOOL)usingBackgroundSession
         completionHandler:(BJNetworkCompletionHandler)handler {
  if (!url.absoluteString.length) {
    [self handleErrorWithCode:BJErrorCodeNetworkInvalidURL queue:queue withHandler:handler];
    return nil;
  }

  NSTimeInterval timeOutInterval = _timeoutInterval ?: kBJNetworkTimeOutInterval;

  NSMutableURLRequest *request =
      [[NSMutableURLRequest alloc] initWithURL:url
                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                               timeoutInterval:timeOutInterval];

  if (!request) {
    [self handleErrorWithCode:BJErrorCodeNetworkSessionTaskCreation
                        queue:queue
                  withHandler:handler];
    return nil;
  }

  NSError *compressError = nil;
//  NSData *compressedData = [NSData gul_dataByGzippingData:payload error:&compressError];
    NSData *compressedData = payload;

  if (!compressedData || compressError) {
    if (compressError || payload.length > 0) {
      // If the payload is not empty but it fails to compress the payload, something has been wrong.
      [self handleErrorWithCode:BJErrorCodeNetworkPayloadCompression
                          queue:queue
                    withHandler:handler];
      return nil;
    }
    compressedData = [[NSData alloc] init];
  }

  NSString *postLength = @(compressedData.length).stringValue;

  // Set up the request with the compressed data.
  [request setValue:postLength forHTTPHeaderField:kBJNetworkContentLengthKey];
  request.HTTPBody = compressedData;
  request.HTTPMethod = kBJNetworkPOSTRequestMethod;
  [request setValue:kBJNetworkContentTypeValue forHTTPHeaderField:kBJNetworkContentTypeKey];
  [request setValue:kBJNetworkContentCompressionValue
      forHTTPHeaderField:kBJNetworkContentCompressionKey];

  BJNetworkURLSession *fetcher = [[BJNetworkURLSession alloc] initWithNetworkLoggerDelegate:self];
  fetcher.backgroundNetworkEnabled = usingBackgroundSession;

//    WeakSelf(weakSelf);
  NSString *requestID = [fetcher
      sessionIDFromAsyncPOSTRequest:request
                  completionHandler:^(NSHTTPURLResponse *response, NSData *data,
                                      NSString *sessionID, NSError *error) {
//      StrongSelf(weakSelf);
      if (error) {
          if (handler) {
              handler(response, @{}, error);
          }
          return;
      }
      
      NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//      BJNetwork *strongSelf = weakSelf;
//                    if (!strongSelf) {
//                      return;
//                    }
                    dispatch_queue_t queueToDispatch = queue ? queue : dispatch_get_main_queue();
                    dispatch_async(queueToDispatch, ^{
                      if (sessionID.length) {
                        [self.requests removeObjectForKey:sessionID];
                      }
                      if (handler) {
                        handler(response, result, error);
                      }
                    });
                  }];
  if (!requestID) {
    [self handleErrorWithCode:BJErrorCodeNetworkSessionTaskCreation
                        queue:queue
                  withHandler:handler];
    return nil;
  }

  [self GULNetwork_logWithLevel:kBJNetworkLogLevelDebug
                    messageCode:kBJNetworkMessageCodeNetwork000
                        message:@"Uploading data. Host"
                        context:url];
  _requests[requestID] = fetcher;
  return requestID;
}

- (NSString *)getURL:(NSURL *)url
                   headers:(NSDictionary *)headers
                     queue:(dispatch_queue_t)queue
    usingBackgroundSession:(BOOL)usingBackgroundSession
         completionHandler:(BJNetworkCompletionHandler)handler {
  if (!url.absoluteString.length) {
    [self handleErrorWithCode:BJErrorCodeNetworkInvalidURL queue:queue withHandler:handler];
    return nil;
  }

  NSTimeInterval timeOutInterval = _timeoutInterval ?: kBJNetworkTimeOutInterval;
  NSMutableURLRequest *request =
      [[NSMutableURLRequest alloc] initWithURL:url
                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                               timeoutInterval:timeOutInterval];

  if (!request) {
    [self handleErrorWithCode:BJErrorCodeNetworkSessionTaskCreation
                        queue:queue
                  withHandler:handler];
    return nil;
  }

  request.HTTPMethod = kBJNetworkGETRequestMethod;
  request.allHTTPHeaderFields = headers;
    
  BJNetworkURLSession *fetcher = [[BJNetworkURLSession alloc] initWithNetworkLoggerDelegate:self];
  fetcher.backgroundNetworkEnabled = usingBackgroundSession;
    
  WeakSelf(weakSelf);
  NSString *requestID = [fetcher
      sessionIDFromAsyncGETRequest:request
                 completionHandler:^(NSHTTPURLResponse *response, NSData *data, NSString *sessionID,
                                     NSError *error) {
      if (error) {
          if (handler) {
              handler(response, @{}, error);
          }
          return;
      }
      
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                   dispatch_queue_t queueToDispatch = queue ? queue : dispatch_get_main_queue();
                   dispatch_async(queueToDispatch, ^{
                     if (sessionID.length) {
                         [weakSelf.requests removeObjectForKey:sessionID];
                     }
                     if (handler) {
                       handler(response, result, error);
                     }
                   });
                 }];

  if (!requestID) {
    [self handleErrorWithCode:BJErrorCodeNetworkSessionTaskCreation
                        queue:queue
                  withHandler:handler];
    return nil;
  }

  [self GULNetwork_logWithLevel:kBJNetworkLogLevelDebug
                    messageCode:kBJNetworkMessageCodeNetwork001
                        message:@"Downloading data. Host"
                        context:url];
  _requests[requestID] = fetcher;
  return requestID;
}

- (void)downloadFileWihtPath:(NSString *)path
                    savePath:(NSString *)savePath
      usingBackgroundSession:(BOOL)usingBackgroundSession
           completionHandler:(BJNetworkCompletionHandler)handler {
    
    if (path.length <= 0 || savePath.length <= 0) {
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (error) {
            handler ? handler(nil,@{},error) : nil;
            return;
        }
        NSError * err = nil;
        NSURL *newLocation = [NSURL fileURLWithPath:savePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if ([fm fileExistsAtPath:savePath]) {
            [fm removeItemAtPath:savePath error:&err];
        }
        
        [fm moveItemAtURL:location toURL:newLocation error:&err];
        handler ? handler(nil,@{@"path":newLocation},nil) : nil;

    }];
    [task resume];
}

- (BOOL)hasUploadInProgress {
  return _requests.count > 0;
}

#pragma mark - Network Reachability

/// Tells reachability delegate to call reachabilityDidChangeToStatus: to notify the network
/// reachability has changed.
- (void)reachability:(BJReachabilityChecker *)reachability
       statusChanged:(BJReachabilityStatus)status {
  _networkConnected = (status == kBJReachabilityViaCellular || status == kBJReachabilityViaWifi);
  [_reachabilityDelegate reachabilityDidChange];
}

#pragma mark - Network logger delegate

- (void)setLoggerDelegate:(id<BJNetworkLoggerProtocol>)loggerDelegate {
  // Explicitly check whether the delegate responds to the methods because conformsToProtocol does
  // not work correctly even though the delegate does respond to the methods.
  if (!loggerDelegate ||
      ![loggerDelegate respondsToSelector:@selector(GULNetwork_logWithLevel:
                                                                messageCode:message:contexts:)] ||
      ![loggerDelegate respondsToSelector:@selector(GULNetwork_logWithLevel:
                                                                messageCode:message:context:)] ||
      ![loggerDelegate respondsToSelector:@selector(GULNetwork_logWithLevel:
                                                                messageCode:message:)]) {
//    GULLogError(kBJLoggerNetwork, NO,
//                [NSString stringWithFormat:@"I-NET%06ld", (long)kBJNetworkMessageCodeNetwork002],
//                @"Cannot set the network logger delegate: delegate does not conform to the network "
//                 "logger protocol.");
    return;
  }
  _loggerDelegate = loggerDelegate;
}

#pragma mark - Private methods

/// Handles network error and calls completion handler with the error.
- (void)handleErrorWithCode:(NSInteger)code
                      queue:(dispatch_queue_t)queue
                withHandler:(BJNetworkCompletionHandler)handler {
  NSDictionary *userInfo = @{kBJNetworkErrorContext : @"Failed to create network request"};
  NSError *error = [[NSError alloc] initWithDomain:kBJNetworkErrorDomain
                                              code:code
                                          userInfo:userInfo];
  [self GULNetwork_logWithLevel:kBJNetworkLogLevelWarning
                    messageCode:kBJNetworkMessageCodeNetwork002
                        message:@"Failed to create network request. Code, error"
                       contexts:@[ @(code), error ]];
  if (handler) {
    dispatch_queue_t queueToDispatch = queue ? queue : dispatch_get_main_queue();
    dispatch_async(queueToDispatch, ^{
      handler(nil, nil, error);
    });
  }
}

#pragma mark - Network logger

- (void)GULNetwork_logWithLevel:(BJNetworkLogLevel)logLevel
                    messageCode:(BJNetworkMessageCode)messageCode
                        message:(NSString *)message
                       contexts:(NSArray *)contexts {
  // Let the delegate log the message if there is a valid logger delegate. Otherwise, just log
  // errors/warnings/info messages to the console log.
  if (_loggerDelegate) {
    [_loggerDelegate GULNetwork_logWithLevel:logLevel
                                 messageCode:messageCode
                                     message:message
                                    contexts:contexts];
    return;
  }
  if (_isDebugModeEnabled || logLevel == kBJNetworkLogLevelError ||
      logLevel == kBJNetworkLogLevelWarning || logLevel == kBJNetworkLogLevelInfo) {
    NSString *formattedMessage = GULStringWithLogMessage(message, logLevel, contexts);
    NSLog(@"%@", formattedMessage);
//    GULLogBasic((GULLoggerLevel)logLevel, kBJLoggerNetwork, NO,
//                [NSString stringWithFormat:@"I-NET%06ld", (long)messageCode], formattedMessage,
//                NULL);
  }
}

- (void)GULNetwork_logWithLevel:(BJNetworkLogLevel)logLevel
                    messageCode:(BJNetworkMessageCode)messageCode
                        message:(NSString *)message
                        context:(id)context {
  if (_loggerDelegate) {
    [_loggerDelegate GULNetwork_logWithLevel:logLevel
                                 messageCode:messageCode
                                     message:message
                                     context:context];
    return;
  }
  NSArray *contexts = context ? @[ context ] : @[];
  [self GULNetwork_logWithLevel:logLevel messageCode:messageCode message:message contexts:contexts];
}

- (void)GULNetwork_logWithLevel:(BJNetworkLogLevel)logLevel
                    messageCode:(BJNetworkMessageCode)messageCode
                        message:(NSString *)message {
  if (_loggerDelegate) {
    [_loggerDelegate GULNetwork_logWithLevel:logLevel messageCode:messageCode message:message];
    return;
  }
  [self GULNetwork_logWithLevel:logLevel messageCode:messageCode message:message contexts:@[]];
}

/// Returns a string for the given log level (e.g. kBJNetworkLogLevelError -> @"ERROR").
static NSString *GULLogLevelDescriptionFromLogLevel(BJNetworkLogLevel logLevel) {
  static NSDictionary *levelNames = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    levelNames = @{
      @(kBJNetworkLogLevelError) : @"ERROR",
      @(kBJNetworkLogLevelWarning) : @"WARNING",
      @(kBJNetworkLogLevelInfo) : @"INFO",
      @(kBJNetworkLogLevelDebug) : @"DEBUG"
    };
  });
  return levelNames[@(logLevel)];
}

/// Returns a formatted string to be used for console logging.
static NSString *GULStringWithLogMessage(NSString *message,
                                         BJNetworkLogLevel logLevel,
                                         NSArray *contexts) {
  if (!message) {
    message = @"(Message was nil)";
  } else if (!message.length) {
    message = @"(Message was empty)";
  }
  NSMutableString *result = [[NSMutableString alloc]
      initWithFormat:@"<%@/%@> %@", kBJNetworkLogTag, GULLogLevelDescriptionFromLogLevel(logLevel),
                     message];

  if (!contexts.count) {
    return result;
  }

  NSMutableArray *formattedContexts = [[NSMutableArray alloc] init];
  for (id item in contexts) {
    [formattedContexts addObject:(item != [NSNull null] ? item : @"(nil)")];
  }

  [result appendString:@": "];
  [result appendString:[formattedContexts componentsJoinedByString:@", "]];
  return result;
}


@end
