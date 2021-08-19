//
//  OpertionViewController.m
//  NSOperation
//
//  Created by HX on 2020/5/29.
//  Copyright © 2020 HX. All rights reserved.
//

#import "OpertionViewController.h"
#import "CustomOperation.h"

@interface OpertionViewController ()

/* 剩余火车票数 */
@property (nonatomic, assign) int ticketSurplusCount;
@property (readwrite, nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSOperationQueue *queue;

@end

/*
 NSOperation是苹果基于GCD、面向对象的封装，简单易用、代码可读性也更高。
核心
   队列：NSOperationQueue
        1、主队列和自定义队列。主队列运行在主线程之上，而自定义队列在后台执行。
            NSOperationQueue *queue = [NSOperationQueue mainQueue];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   任务：NSOperation（抽象类)
        1、NSInvocationOperation
        2、NSBlockOperation
            NSBlockOperation 是否开启新线程，取决于操作的个数。如果添加的操作的个数多，就会自动开启新线程。当然开启的线程数是由系统来决定的。
 
 
 为什么要使用 NSOperation、NSOperationQueue？

 1、可添加完成的代码块，在操作完成后执行。
 2、添加操作之间的依赖关系，方便的控制执行顺序。（添加任务依赖）
 3、设定操作执行的优先级。
 4、可以很方便的取消一个操作的执行。
 5、使用 KVO 观察对操作执行状态的更改：isReady、isExecuteing、isFinished、isCancelled。(任务执行状态)【重点】
    如果只重写了mian方法，底层控制变更任务执行完成状态，以及任务退出状态。
    如果重写start方法，自行控制状态。
 6、最大并发量


 如果所插入的操作存在依赖关系、优先完成依赖操作。
 如果所插入的操作不存在依赖关系、队列并发数为1下采用先进先出的原则、反之直接开辟新的线程执行
 
 */


@implementation OpertionViewController

- (void)printLog {
    NSLog(@"1     %@",[NSThread currentThread]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];     // 主队列
    
    NSOperationQueue *customQueue = [[NSOperationQueue alloc] init];// 自定义队列
    
    // 创建 NSInvocationOperation
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self
                                                                      selector:@selector(printLog)
                                                                        object:nil];
    // 创建 NSBlockOperation
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [self printLog];
    }];
    
    [mainQueue addOperation:op1];
    
    [customQueue addOperation:op2];
     */


//    1、在当前线程使用子类 NSInvocationOperation
//    [self useInvocationOperation];
    
//    在其他线程使用子类 NSInvocationOperation
//    [NSThread detachNewThreadSelector:@selector(useInvocationOperation) toTarget:self withObject:nil];

//    在当前线程使用 NSBlockOperation
//    [self useBlockOperation];
    
//    使用 NSBlockOperation 的 AddExecutionBlock: 方法
//    [self useBlockOperationAddExecutionBlock];

//    使用自定义继承自 NSOperation 的子类
    [self useCustomOperation];
    
//    使用addOperation: 添加操作到队列中
//    [self addOperationToQueue];
    
//    使用 addOperationWithBlock: 添加操作到队列中
//    [self addOperationWithBlockToQueue];
    
//    设置最大并发操作数（MaxConcurrentOperationCount）
//    [self setMaxConcurrentOperationCount];
    
//    设置优先级
//    [self setQueuePriority];
    
//    添加依赖
//    [self addDependency];
    
//    线程间的通信
//    [self communication];
    
//    完成操作
//    [self completionBlock];
    
//    不考虑线程安全
//    [self initTicketStatusNotSave];
    
//    考虑线程安全
//    [self initTicketStatusSave];
    
//    operationQueue 挂起、继续、取消
//    [self controlOperationQueue];
    
}

#pragma mark - 使用NSInvocationOperation
- (void)useInvocationOperation {
    // 1.创建 NSInvocationOperation 对象
    NSInvocationOperation * op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    NSLog(@"2---%@", [NSThread currentThread]);
    // 2.调用 start 方法开始执行操作
    [op start];
    NSLog(@"3---%@", [NSThread currentThread]);
}

#pragma mark - 使用NSInvocationOperation
- (void)useBlockOperation {
    // 1.创建 NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [self task:1];
    }];
    // 2.调用 start 方法开始执行操作
    [op start];
}

- (void)useBlockOperationAddExecutionBlock {
    // 1.创建 NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [self task:1];
    }];
    // 2.添加额外的操作
    [op addExecutionBlock:^{
        [self task:2];
    }];
    [op addExecutionBlock:^{
        [self task:3];
    }];
    [op addExecutionBlock:^{
        [self task:4];
    }];
    [op start];
}

/**
 * 使用自定义继承自 NSOperation 的子类
 */
- (void)useCustomOperation {
    // 1.创建 CustomOperation 对象
    CustomOperation *op = [[CustomOperation alloc] init];
    // 2.调用 start 方法开始执行操作
    [op start];
}


/**
 * 使用 addOperation: 将操作加入到操作队列中
 */
- (void)addOperationToQueue {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    // 使用 NSInvocationOperation 创建操作1
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task) object:nil];
    // 使用 NSInvocationOperation 创建操作2
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task) object:nil];
    // 使用 NSBlockOperation 创建操作3
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        [self task:3];
    }];
    
    [op3 addExecutionBlock:^{
        [self task:4];
    }];
    
    // 3.使用 addOperation: 添加所有操作到队列中
    [queue addOperation:op1]; // [op1 start]
    [queue addOperation:op2]; // [op2 start]
    [queue addOperation:op3]; // [op3 start]
//   [queue addOperations:@[op1, op2, op3] waitUntilFinished:NO];
}


/**
 * 设置 MaxConcurrentOperationCount（最大并发操作数）
 */
- (void)setMaxConcurrentOperationCount {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.设置最大并发操作数
    queue.maxConcurrentOperationCount = 1; // 串行队列
//    queue.maxConcurrentOperationCount = 2; // 并发队列
//    queue.maxConcurrentOperationCount = 8; // 并发队列
    // 3.添加操作
    [queue addOperationWithBlock:^{
        [self task:1];
    }];
    [queue addOperationWithBlock:^{
        [self task:2];
    }];
    [queue addOperationWithBlock:^{
        [self task:3];
    }];
    [queue addOperationWithBlock:^{
        [self task:4];
    }];
}

/**
 * 使用 addOperationWithBlock: 将操作加入到操作队列中
 */
- (void)addOperationWithBlockToQueue {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.使用 addOperationWithBlock: 添加操作到队列中
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];          // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

/**
 * 设置优先级
 * 就绪状态下，优先级高的会优先执行，但是执行时间长短并不是一定的，所以优先级高的并不是一定会先执行完毕
 */
- (void)setQueuePriority {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [self task:1];
    }];
    [op1 setQueuePriority:(NSOperationQueuePriorityVeryLow)];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [self task:2];
    }];
    [op2 setQueuePriority:(NSOperationQueuePriorityVeryHigh)];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
}

/**
 * 操作依赖
 * 使用方法：addDependency:
 */
- (void)addDependency {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [self task:1];
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [self task:2];
    }];
    
    // 3.添加依赖
    [op2 addDependency:op1];    // 让op2 依赖于 op1，则先执行op1，在执行op2
    
    // 4.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
}

/**
 * 线程间通信
 */
- (void)communication {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        [self task:1];
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            [self task:2];
        }];
    }];
}

/**
 * 完成操作 completionBlock
 */
- (void)completionBlock {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [self task:1];
    }];
    
    // 3.添加完成操作
    op1.completionBlock = ^{
        [self task:2];
    };
    
    // 4.添加操作到队列中
    [queue addOperation:op1];
}

#pragma mark - 线程安全
/**
 * 非线程安全：不使用 NSLock
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    
    self.ticketSurplusCount = 50;
    
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
   
    
    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%d 窗口:%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 * 线程安全：使用 NSLock 加锁
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */
- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    
    self.ticketSurplusCount = 50;
    
    self.lock = [[NSLock alloc] init];
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 加锁
        [self.lock lock];
        
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%d 窗口:%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        // 解锁
        [self.lock unlock];
        
        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

- (void)controlOperationQueue {
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    queue.name = @"hx";
    queue.maxConcurrentOperationCount = 2;
    _queue = queue;
    for (int i = 0; i < 100; i++) {
        [queue addOperationWithBlock:^{
            [self task:i];
        }];
    }
}

- (IBAction)pauseOrContinue:(UIButton *)sender {
    if (self.queue.operationCount == 0) {
        NSLog(@"当前没有操作，没有必要挂起和继续");
        return;
    }
    if (self.queue.suspended) {
        NSLog(@"当前是挂起状态，准备继续");
    } else {
        NSLog(@"当前是执行状态，准备挂起");
    }
    self.queue.suspended = !self.queue.suspended;
    /*
     问题 挂起队列又执行了两次？ 已经被线程调度的人任务 无法挂起，这里挂起指的是队列
    2020-06-03 21:08:13.174344+0800 NSOperation_Demo[53624:1015202] 当前是执行状态，准备挂起
    2020-06-03 21:08:13.393628+0800 NSOperation_Demo[53624:1015667] <NSThread: 0x600002a11340>{number = 6, name = (null)}---41
    2020-06-03 21:08:13.393628+0800 NSOperation_Demo[53624:1015668] <NSThread: 0x600002a6c800>{number = 3, name = (null)}---40
     */
}


- (IBAction)cancel:(UIButton *)sender {
    [self.queue cancelAllOperations];
}

/**
 * 任务1
 */
- (void)task1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]);     // 打印当前线程
    }
}

/**
 * 任务2
 */
- (void)task2 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"2---%@", [NSThread currentThread]);     // 打印当前线程
    }
}


// 任务
- (void)task:(NSInteger)index {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"%ld---%@", (long)index,[NSThread currentThread]);     // 打印当前线程
    }
}

@end
