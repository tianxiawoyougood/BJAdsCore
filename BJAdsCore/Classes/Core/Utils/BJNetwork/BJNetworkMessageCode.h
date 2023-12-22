//
//  BJNetworkMessageCode.h
//  NetWorkDemo
//
//  Created by cc on 2022/4/22.
//

#import <Foundation/Foundation.h>

// Make sure these codes do not overlap with any contained in the FIRAMessageCode enum.
typedef NS_ENUM(NSInteger, BJNetworkMessageCode) {
  // GULNetwork.m
  kBJNetworkMessageCodeNetwork000 = 900000,  // I-NET900000
  kBJNetworkMessageCodeNetwork001 = 900001,  // I-NET900001
  kBJNetworkMessageCodeNetwork002 = 900002,  // I-NET900002
  kBJNetworkMessageCodeNetwork003 = 900003,  // I-NET900003
  // GULNetworkURLSession.m
  kBJNetworkMessageCodeURLSession000 = 901000,  // I-NET901000
  kBJNetworkMessageCodeURLSession001 = 901001,  // I-NET901001
  kBJNetworkMessageCodeURLSession002 = 901002,  // I-NET901002
  kBJNetworkMessageCodeURLSession003 = 901003,  // I-NET901003
  kBJNetworkMessageCodeURLSession004 = 901004,  // I-NET901004
  kBJNetworkMessageCodeURLSession005 = 901005,  // I-NET901005
  kBJNetworkMessageCodeURLSession006 = 901006,  // I-NET901006
  kBJNetworkMessageCodeURLSession007 = 901007,  // I-NET901007
  kBJNetworkMessageCodeURLSession008 = 901008,  // I-NET901008
  kBJNetworkMessageCodeURLSession009 = 901009,  // I-NET901009
  kBJNetworkMessageCodeURLSession010 = 901010,  // I-NET901010
  kBJNetworkMessageCodeURLSession011 = 901011,  // I-NET901011
  kBJNetworkMessageCodeURLSession012 = 901012,  // I-NET901012
  kBJNetworkMessageCodeURLSession013 = 901013,  // I-NET901013
  kBJNetworkMessageCodeURLSession014 = 901014,  // I-NET901014
  kBJNetworkMessageCodeURLSession015 = 901015,  // I-NET901015
  kBJNetworkMessageCodeURLSession016 = 901016,  // I-NET901016
  kBJNetworkMessageCodeURLSession017 = 901017,  // I-NET901017
  kBJNetworkMessageCodeURLSession018 = 901018,  // I-NET901018
  kBJNetworkMessageCodeURLSession019 = 901019,  // I-NET901019
};
