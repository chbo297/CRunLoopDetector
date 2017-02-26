//
//  CRunLoopDetector.h
//  CRunLoopDetector
//
//  Created by bo on 24/02/2017.
//  Copyright © 2017 bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRunLoopDetector : NSObject

+ (instancetype)sharedRunLoopDetector;

- (void)startDetecting;
- (void)stopDetecting;

@end
