//
//  CRunLoopTimeInspector.m
//  CRunLoopDetector
//
//  Created by bo on 24/02/2017.
//  Copyright © 2017 bo. All rights reserved.
//

#import "CRunLoopTimeInspector.h"

@interface CRunLoopOverTimeTag : NSObject

@property (nonatomic) NSDate *date;
@property (nonatomic) NSTimeInterval duration;

@end

@implementation CRunLoopOverTimeTag

- (NSString *)description {
    return [NSString stringWithFormat:@"%@,%f", self.date, self.duration];
}

@end

@interface CRunLoopTimeInspector ()

@property (nonatomic) NSOperationQueue *recordStackSymbolsQueue;

@property (nonatomic) NSMutableArray<CRunLoopOverTimeTag *> *overTimeRecordation;

@end

@implementation CRunLoopTimeInspector {
    NSDate *_lastWakeUp;
}

- (void)runLoopWakeUp:(NSDate *)date {
    _lastWakeUp = date;
    
}

- (void)runLoopStop:(NSDate *)date {
    if (_lastWakeUp) {
        CRunLoopOverTimeTag *tag = [CRunLoopOverTimeTag new];
        tag.date = date;
        tag.duration = [date timeIntervalSinceDate:_lastWakeUp];
        _lastWakeUp = nil;
        
        if (tag.duration > 0.2f) {
            [self doRecordWithOverTimeTags:@[tag]];
        } else if (tag.duration > 0.02f) {
            [self __overTimeRecording:tag];
        }
    }
    
}

- (void)__overTimeRecording:(CRunLoopOverTimeTag *)tag {
    [self.overTimeRecordation addObject:tag];
    //只记录最近12次超时
    if (self.overTimeRecordation.count > 12) {
        [self.overTimeRecordation removeObjectAtIndex:0];
    }
    
    //"每次超时都检测"的模式下现在开始对overTimeRecordation进行分析
    [self analyzeRecordation];
}

- (void)analyzeRecordation {
    if (self.overTimeRecordation.count < 2) {
        return;
    }
    
    __block NSTimeInterval blockTotalDuration = 0;
    __block CRunLoopOverTimeTag *lastTag;
    __block NSInteger localIdx = -1;
    [self.overTimeRecordation enumerateObjectsWithOptions:NSEnumerationReverse
                                               usingBlock:^(CRunLoopOverTimeTag * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                   
                                                   blockTotalDuration += obj.duration;
                                                   
                                                   if (idx == self.overTimeRecordation.count - 1) {
                                                       lastTag = obj;
                                                   } else {
                                                       NSTimeInterval interval = [lastTag.date timeIntervalSinceDate:obj.date] + obj.duration;
                                                       
                                                       if (blockTotalDuration / interval > 0.2f) {
                                                           localIdx = idx;
                                                           *stop = YES;
                                                       }
                                                   }
                                                   
                                               }];
    
    if (localIdx != -1) {
        NSRange selectRang = NSMakeRange(localIdx, self.overTimeRecordation.count - localIdx);
        NSArray *selectTags = [self.overTimeRecordation subarrayWithRange:selectRang];
        [self.overTimeRecordation removeObjectsInArray:selectTags];
        
        [self doRecordWithOverTimeTags:selectTags];
    }
}

- (void)doRecordWithOverTimeTags:(NSArray<CRunLoopOverTimeTag *> *)overTimeTags {
    NSArray *stackSymbols = [NSThread callStackSymbols];
    [self.recordStackSymbolsQueue addOperationWithBlock:^{
        [self recordStackSymbols:stackSymbols overTimeTags:overTimeTags];
    }];
}

//must executing in recordStackSymbolsQueue
- (void)recordStackSymbols:(NSArray<NSString *> *)stackSymbols
              overTimeTags:(NSArray<CRunLoopOverTimeTag *> *)overTimeTags {
    
    NSLog(@"tags\n%@", overTimeTags);
    NSLog(@"stack:\n%@", stackSymbols);
}

- (NSOperationQueue *)recordStackSymbolsQueue {
    if (!_recordStackSymbolsQueue) {
        _recordStackSymbolsQueue = [NSOperationQueue new];
        _recordStackSymbolsQueue.qualityOfService = NSQualityOfServiceUtility;
        _recordStackSymbolsQueue.maxConcurrentOperationCount = 1;
    }
    return _recordStackSymbolsQueue;
}

@end
