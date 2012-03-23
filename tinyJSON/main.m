//
//  main.m
//  tinyJSON
//
//  Created by Robert Diamond on 3/22/12.
//  Copyright (c) 2012 America Online. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tinyJSONParser.h"

int main(int argc, const char * argv[])
{

  @autoreleasepool {
    NSString *testString = @"{ \"a\": \"bcd\", \"qrs\" : 75 }";
    tinyJSONParser *jp = [[tinyJSONParser alloc] init];
    NSLog(@"basic test: \n%@\n%@", testString, [jp parse:testString]);
    testString = @"[\"string 1\", 45, 67, [ 1, 2, 3 ], { \"tt\" : \"uu\" } ]";  
    NSLog(@"more complex test: \n%@\n%@", testString, [jp parse:testString]);

    NSError *error = nil;
    testString = [[NSString alloc] initWithContentsOfFile:@"/Users/rmd6502/mobile_config.json" encoding:NSUTF8StringEncoding error:&error];
    if (error) {
      NSLog(@"Failed to read mobile_config.json");
    } else {
      NSLog(@"read large file: %@", [jp parse:testString]);
    }
  }
    return 0;
}

