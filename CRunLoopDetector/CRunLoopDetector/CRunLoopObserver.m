//
//  CRunLoopObserver.m
//  CRunLoopDetector
//
//  Created by bo on 24/02/2017.
//  Copyright © 2017 bo. All rights reserved.
//

#import "CRunLoopObserver.h"

@interface CRunLoopObserver ()

@property (nonatomic) CFRunLoopObserverRef observer;

@end

@implementation CRunLoopObserver

- (void)startObserve {
    CFRunLoopRef threadref = [self observeThread];
    CFRunLoopObserverRef observerref = self.observer;
    
    if (!CFRunLoopContainsObserver(threadref, observerref, kCFRunLoopCommonModes)) {
        CFRunLoopAddObserver(threadref, observerref, kCFRunLoopCommonModes);
    }
}

- (void)endObserve {
    CFRunLoopRef threadref = [self observeThread];
    CFRunLoopObserverRef observerref = self.observer;
    
    if (CFRunLoopContainsObserver(threadref, observerref, kCFRunLoopCommonModes)) {
        CFRunLoopRemoveObserver(threadref, observerref, kCFRunLoopCommonModes);
    }
}

- (CFRunLoopRef)observeThread {
    return CFRunLoopGetMain();
}

- (CFRunLoopObserverRef)observer {
    if (!_observer) {
        
        //1.创建监听者
        /*
         第一个参数:怎么分配存储空间
         第二个参数:要监听的状态 kCFRunLoopAllActivities 所有的状态
         第三个参数:时候持续监听
         第四个参数:优先级 总是传0
         第五个参数:当状态改变时候的回调
         */
        _observer =
        CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            
            /*
             kCFRunLoopEntry = (1UL << 0),        即将进入runloop
             kCFRunLoopBeforeTimers = (1UL << 1), 即将处理timer事件
             kCFRunLoopBeforeSources = (1UL << 2),即将处理source事件
             kCFRunLoopBeforeWaiting = (1UL << 5),即将进入睡眠
             kCFRunLoopAfterWaiting = (1UL << 6), 被唤醒
             kCFRunLoopExit = (1UL << 7),         runloop退出
             kCFRunLoopAllActivities = 0x0FFFFFFFU
             */
            switch (activity) {
                case kCFRunLoopEntry:
                    break;
                case kCFRunLoopBeforeTimers:
                    break;
                case kCFRunLoopBeforeSources:
                    break;
                case kCFRunLoopBeforeWaiting:
                    if ([self.delegate respondsToSelector:@selector(runLoopStop:)]) {
                        [self.delegate runLoopStop:[NSDate date]];
                    }
                    break;
                case kCFRunLoopAfterWaiting:
                    if ([self.delegate respondsToSelector:@selector(runLoopWakeUp:)]) {
                        [self.delegate runLoopWakeUp:[NSDate date]];
                    }
                    break;
                case kCFRunLoopExit:
                    break;
                default:
                    break;
            }
        });
    }
    return _observer;
}

@end
