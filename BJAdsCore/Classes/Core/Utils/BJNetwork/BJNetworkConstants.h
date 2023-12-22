//
//  BJNetworkConstants.h
//  NetWorkDemo
//
//  Created by cc on 2022/4/22.
//

#import <Foundation/Foundation.h>

/// Error codes in Firebase Network error domain.
/// Note: these error codes should never change. It would make it harder to decode the errors if
/// we inadvertently altered any of these codes in a future SDK version.
typedef NS_ENUM(NSInteger, BJNetworkErrorCode) {
  /// Unknown error.
  BJNetworkErrorCodeUnknown = 0,
  /// Error occurs when the request URL is invalid.
  BJErrorCodeNetworkInvalidURL = 1,
  /// Error occurs when request cannot be constructed.
  BJErrorCodeNetworkRequestCreation = 2,
  /// Error occurs when payload cannot be compressed.
  BJErrorCodeNetworkPayloadCompression = 3,
  /// Error occurs when session task cannot be created.
  BJErrorCodeNetworkSessionTaskCreation = 4,
  /// Error occurs when there is no response.
  BJErrorCodeNetworkInvalidResponse = 5
};

#pragma mark - Network constants

/// The prefix of the ID of the background session.
extern NSString *const kBJNetworkBackgroundSessionConfigIDPrefix;

/// The sub directory to store the files of data that is being uploaded in the background.
extern NSString *const kBJNetworkApplicationSupportSubdirectory;

/// Name of the temporary directory that stores files for background uploading.
extern NSString *const kBJNetworkTempDirectoryName;

/// The period when the temporary uploading file can stay.
extern const NSTimeInterval kBJNetworkTempFolderExpireTime;

/// The default network request timeout interval.
extern const NSTimeInterval kBJNetworkTimeOutInterval;

/// The host to check the reachability of the network.
extern NSString *const kBJNetworkReachabilityHost;

/// The key to get the error context of the UserInfo.
extern NSString *const kBJNetworkErrorContext;

#pragma mark - Network Status Code

extern const int kBJNetworkHTTPStatusOK;
extern const int kBJNetworkHTTPStatusNoContent;
extern const int kBJNetworkHTTPStatusCodeMultipleChoices;
extern const int kBJNetworkHTTPStatusCodeMovedPermanently;
extern const int kBJNetworkHTTPStatusCodeFound;
extern const int kBJNetworkHTTPStatusCodeNotModified;
extern const int kBJNetworkHTTPStatusCodeMovedTemporarily;
extern const int kBJNetworkHTTPStatusCodeNotFound;
extern const int kBJNetworkHTTPStatusCodeCannotAcceptTraffic;
extern const int kBJNetworkHTTPStatusCodeUnavailable;
