/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

// Make sure these codes do not overlap with any contained in the FIRAMessageCode enum.
typedef NS_ENUM(NSInteger, BJReachabilityMessageCode) {
  // GULReachabilityChecker.m
  kBJReachabilityMessageCode000 = 902000,  // I-NET902000
  kBJReachabilityMessageCode001 = 902001,  // I-NET902001
  kBJReachabilityMessageCode002 = 902002,  // I-NET902002
  kBJReachabilityMessageCode003 = 902003,  // I-NET902003
  kBJReachabilityMessageCode004 = 902004,  // I-NET902004
  kBJReachabilityMessageCode005 = 902005,  // I-NET902005
  kBJReachabilityMessageCode006 = 902006,  // I-NET902006
};
