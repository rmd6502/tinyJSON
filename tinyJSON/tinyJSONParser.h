//
//  tinyJSONParser.h
//  tinyJSON
//
//  Created by Robert Diamond on 3/22/12.
//  Copyright (c) 2012 America Online. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface tinyJSONParser : NSObject {
  NSCharacterSet *begins;
  NSCharacterSet *numberChars;
}

@property (nonatomic, copy) NSString *data;
@property (nonatomic, assign) NSRange currentRange;

- (id)parse:(NSString *)aString;

@end
