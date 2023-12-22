//
//  BJNetworkConstants.m
//  NetWorkDemo
//
//  Created by cc on 2022/4/22.
//

#import "BJNetworkConstants.h"

NSString *const kBJNetworkBackgroundSessionConfigIDPrefix = @"com.bj.network.background-upload";
NSString *const kBJNetworkApplicationSupportSubdirectory = @"BJ/Network";
NSString *const kBJNetworkTempDirectoryName = @"BJNetworkTemporaryDirectory";
const NSTimeInterval kBJNetworkTempFolderExpireTime = 60 * 60;  // 1 hour
const NSTimeInterval kBJNetworkTimeOutInterval = 60;            // 1 minute.
NSString *const kBJNetworkReachabilityHost = @"app-measurement.com";
NSString *const kBJNetworkErrorContext = @"Context";

const int kBJNetworkHTTPStatusOK = 200;
const int kBJNetworkHTTPStatusNoContent = 204;
const int kBJNetworkHTTPStatusCodeMultipleChoices = 300;
const int kBJNetworkHTTPStatusCodeMovedPermanently = 301;
const int kBJNetworkHTTPStatusCodeFound = 302;
const int kBJNetworkHTTPStatusCodeNotModified = 304;
const int kBJNetworkHTTPStatusCodeMovedTemporarily = 307;
const int kBJNetworkHTTPStatusCodeNotFound = 404;
const int kBJNetworkHTTPStatusCodeCannotAcceptTraffic = 429;
const int kBJNetworkHTTPStatusCodeUnavailable = 503;

NSString *const kBJNetworkErrorDomain = @"com.gul.network.ErrorDomain";
