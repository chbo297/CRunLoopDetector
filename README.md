# CRunLoopDetector  
  
  检测RunLoop的时长，可以准确的获得发生卡顿的RunLoop，输出堆栈信息。
但笔者用这个思路实现后才发现，打出的堆栈信息离发生卡顿的地方想去甚远。在一次RunLoop过程中，某处卡顿结束后，后面还会进出非常多正常的堆栈信息，结果就是，在RunLoop的最后获取到堆栈时，完全找不到卡顿发生的地方，这是一个小坑。。。
