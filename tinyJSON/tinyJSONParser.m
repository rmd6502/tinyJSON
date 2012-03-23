//
//  tinyJSONParser.m
//  tinyJSON
//
//  Created by Robert Diamond on 3/22/12.
//  Copyright (c) 2012 Robert M. Diamond. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "tinyJSONParser.h"

#define ADVANCE(next) \
  currentRange.length -= (next.location - currentRange.location) + next.length; \
  currentRange.location = next.location + next.length

@interface tinyJSONParser(Private)
- (NSDictionary *)parseDictionary;
- (NSArray *)parseArray;
- (NSString *)parseString;
- (NSNumber *)parseNumber;
- (NSNumber *)parseBoolean;
- (id)parseValue;
@end

@implementation tinyJSONParser
@synthesize data;
@synthesize currentRange;

- (id)init {
  if ((self = [super init]) != nil) {
    begins = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];
    numberChars = [[NSCharacterSet decimalDigitCharacterSet] 
                   mutableCopy] ;
    [(NSMutableCharacterSet *)numberChars addCharactersInString:@"+-.E"];
  }
  return self;
}

- (void)dealloc {
  [begins release];
  [numberChars release];
  [super dealloc];
}

- (id)parse:(NSString *)aString {
  self.data = aString;
  self.currentRange = NSMakeRange(0, data.length);
  return [self parseValue];
}

- (NSDictionary *)parseDictionary {
  NSMutableDictionary *ret = [NSMutableDictionary dictionary];
  NSRange first = NSMakeRange(0, 0);
  while (YES) {
    first = [data rangeOfCharacterFromSet:begins options:0 range:currentRange];
    if (first.location == NSNotFound) break;
    NSString *firstChar = [data substringWithRange:first];
    if ([firstChar isEqualToString:@"}"]) { ADVANCE(first); return ret; }
    if ([firstChar isEqualToString:@","]) { ADVANCE(first); continue; }
    NSString *key = [self parseString];
    if (key == nil) return nil;
    NSRange next = [data rangeOfCharacterFromSet:begins options:0 range:currentRange];
    firstChar = [data substringWithRange:next];
    if (![firstChar isEqualToString:@":"]) return nil;
    ADVANCE(next);
    id value = [self parseValue];
    [ret setValue:value forKey:key];
  }
  return ret;
}
- (NSArray *)parseArray {
  NSMutableArray *ret = [NSMutableArray array];
  
  while (YES) {
    id val = [self parseValue];
    if (val == nil) return nil;
    [ret addObject:val];
    NSRange first = [data rangeOfCharacterFromSet:begins options:0 range:currentRange];
    NSString *firstChar = [data substringWithRange:first];
    ADVANCE(first);
    if ([firstChar isEqualToString:@"]"]) return ret;
    else if (![firstChar isEqualToString:@","]) return nil;
  }
  return ret;
}

- (NSString *)parseString {
  NSRange first = [data rangeOfCharacterFromSet:begins options:0 range:currentRange];
  NSString *firstChar = [data substringWithRange:first];
  if (![firstChar isEqualToString:@"\""]) return nil;
  ADVANCE(first);
  NSRange next = [data rangeOfString:@"\"" options:NSRegularExpressionSearch range:currentRange];
  if (next.location == NSNotFound) return nil;
  ADVANCE(next);
  return [data substringWithRange:NSMakeRange(first.location + 1, next.location - first.location - 1)];
}

- (NSNumber *)parseNumber {
  NSRange first = currentRange;
  NSRange next = [data rangeOfCharacterFromSet:[numberChars invertedSet] options:0 range:currentRange];
  if (next.location == NSNotFound) {
    next = first;
  } else {
    next = NSMakeRange(first.location, next.location - first.location);
  }
  NSString *num = [data substringWithRange:next];
  ADVANCE(next);
  return [NSNumber numberWithDouble:[num doubleValue]];
}

- (NSNumber *)parseBoolean {
  NSRange next = [data rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet] invertedSet] options:0 range:currentRange];
  NSString *val = [[data substringWithRange:NSMakeRange(currentRange.location, next.location - currentRange.location)] lowercaseString];
  ADVANCE(next);
  --currentRange.location; ++currentRange.length;
  if ([val isEqualToString:@"t"] || [val isEqualToString:@"true"]) {
    return [NSNumber numberWithBool:YES];
  }
  return [NSNumber numberWithBool:NO];
}

- (id)parseValue {
  NSRange r = [data rangeOfCharacterFromSet:begins options:0 range:currentRange];
  if (r.location == NSNotFound) {
    return nil;
  }

  NSString *firstChar = [data substringWithRange:r];
  NSLog(@"currentRange %@ r %@ char %@", NSStringFromRange(currentRange), NSStringFromRange(r), firstChar);
  ADVANCE(r);
  if ([firstChar isEqualToString:@"{"]) {
    return [self parseDictionary];
  } else if ([firstChar isEqualToString:@"["]) {
    return [self parseArray];
  } else if ([firstChar isEqualToString:@"\""]) {
    --currentRange.location; ++currentRange.length;
    return [self parseString];
  } else if ([@"tTfF" rangeOfString:firstChar].location != NSNotFound) {
    --currentRange.location; ++currentRange.length;
    return [self parseBoolean];
  } else if ([firstChar rangeOfCharacterFromSet:numberChars].location != NSNotFound) {
    --currentRange.location; ++currentRange.length;
    return [self parseNumber];
  }
  
  return nil;
}

@end
