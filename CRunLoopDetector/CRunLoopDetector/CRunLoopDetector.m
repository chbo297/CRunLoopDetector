//
//  CRunLoopDetector.m
//  CRunLoopDetector
//
//  Created by bo on 24/02/2017.
//  Copyright © 2017 bo. All rights reserved.
//

#import "CRunLoopDetector.h"
#import "CRunLoopTimeInspector.h"

@interface CRunLoopDetector ()

@property (nonatomic) CRunLoopObserver *observer;
@property (nonatomic) CRunLoopTimeInspector *timeInspector;

@end

@implementation CRunLoopDetector

+ (instancetype)sharedRunLoopDetector {
    static CRunLoopDetector *detector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [[self alloc] init];
    });
    return detector;
}

- (void)startDetecting {
    self.observer.delegate = self.timeInspector;
    [self.observer startObserve];
}

- (void)stopDetecting {
    [self.observer endObserve];
}

- (CRunLoopObserver *)observer {
    if (!_observer) {
        _observer = [CRunLoopObserver new];
    }
    return _observer;
}

- (CRunLoopTimeInspector *)timeInspector {
    if (!_timeInspector) {
        _timeInspector = [CRunLoopTimeInspector new];
    }
    return _timeInspector;
}


@end
