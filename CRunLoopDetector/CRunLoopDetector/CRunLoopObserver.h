//
//  CRunLoopObserver.h
//  CRunLoopDetector
//
//  Created by bo on 24/02/2017.
//  Copyright © 2017 bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CRunLoopIntervalClock <NSObject>

- (void)runLoopWakeUp:(NSDate *)date;
- (void)runLoopStop:(NSDate *)date;

@end

@interface CRunLoopObserver : NSObject

@property(nonatomic, weak) id<CRunLoopIntervalClock> delegate;

//Default detect to main thread.
- (void)startObserve;
- (void)endObserve;

@end
