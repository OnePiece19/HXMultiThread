//
//  GCDViewController.m
//  GCD
//
//  Created by HX on 2019/11/6.
//  Copyright © 2019 GCD. All rights reserved.
//

#import "GCDViewController.h"
#import "UserCenter.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"

@interface GCDViewController ()

/* 剩余火车票数 */
@property (nonatomic, assign) int ticketSurplusCount;

@end

/*
GCD中有两个核心概念：
   线程（执行的路径）
   同步异步(执行的方式)
   任务（实行什么操作）
   队列（用来存放任务）

用同步的方式执行任务：《只能在当前线程中执行任务，不具备开启新线程的能力》
       dispatch_sync(dispatch_queue_t queue, dispatch_block_t block)
用异步的方式执行任务：《可以在新的线程中执行任务，具备开启新线程的能力》
       dispatch_async(dispatch_queue_t queue, dispatch_block_t block)
 
 
               串行队列            并行队列/全局队列               主队列
 同步sync    线程：未开启            新线程：未开启          造成死锁的线程【切记】;
             任务：串行              任务：串行            原因：dispatch_sync是一部分(先执行)，然后一部分是执行block，
                                                        然后返回dispatch_sync，并且dispatch_sync不释放
 
 异步async   新线程：开启（一条）      新线程：开启           新线程：未开启
             任务：串行              任务：并行             任务：串行
 
 【重点】 同步+主队列死锁的原因：队列引起的循环等待【详见图解】
  
 1、同步dispatch_sync
 2、异步dispatch_async
 3、线程通信
 4、栅栏barrier
 5、延迟执行dispatch_after
 6、定时执行dispatch_source_t
 7、执行一次dispatch_once
 8、执行多次dispatch_apply
 9、按组执行dispatch_group
 10、信号量dispatch_semaphore
 
*/
@implementation GCDViewController
{
    dispatch_semaphore_t semaphoreLock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 串行队列的创建方法
    dispatch_queue_t serialQueue = dispatch_queue_create("serial.queue", DISPATCH_QUEUE_SERIAL);

    // 并行队列的创建方法 == globalQueue
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 全局队列的创建方法 == 后台执行
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    // 获得主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    
    
    dispatch_sync(serialQueue, ^{ /*任务*/ });     //  同步 + 串行 :没有开启新线程，串行执行

    dispatch_sync(concurrentQueue, ^{ /*任务*/ }); //  同步 + 并发/全局 :没有开启新线程，串行执行

//    dispatch_sync(mainQueue, ^{ /*任务*/ });       //  死锁：队列引起的循环等待

    dispatch_async(serialQueue, ^{ /*任务*/ });    //  异步 + 串行:开辟一个线程，串行执行

    dispatch_async(concurrentQueue, ^{ /*任务*/ });//  异步 + 并行/全局: 开启多个线程，并行

    dispatch_async(mainQueue, ^{ /*任务*/ });      //  异步 + 主队列: 不开启新线程，在主线程执行
    
    
    
    
    dispatch_group_t group = dispatch_group_create();              // 建一个调度任务组
    
    dispatch_group_async(group, concurrentQueue, ^{ /*任务*/ });    // 把一个任务异步提交到任务组里
    
    dispatch_group_enter(group);                                   // 这种方式用在不使用dispatch_group_async来提交任务，
    
    dispatch_group_leave(group);                                   // 且必须dispatch_group_enter配合使用
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);             // 设置等待执行完任务组时间。返回0成功，非0则失败
    
    dispatch_group_notify(group, concurrentQueue, ^{ /* 任务 */ }); // 用来监听任务组事件的执行完毕
    
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); // 创建semaphore并初始化信号的总量
    
    dispatch_semaphore_signal(semaphore);                          // 发送一个信号量，让信号总量+1
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);     // 可以使总信号量-1，信号总量<0时就会一直等待（阻塞所在线程），否则正常执行

    
    /* 1
     * 同步 + 串行/并行/全局 :没有开启新线程，串行执行
     * 同步 + 主队列: 锁死，dispatch_sync是一部分(先执行)，然后一部分是执行block，然后返回dispatch_sync，并且dispatch_sync不释放
     */

//    [self syncBlock:serialQueue];
//    [self syncBlock:concurrentQueue];
//    [self syncBlock:globalQueue];
//    [self syncBlock:mainQueue]; //锁死
    
//    [self syncGlobalQueue];//面试题
    [self syncSerialQueue];//面试题

    /* 2
     * 异步 + 串行:开辟一个线程，串行执行
     * 异步 + 并行/全局: 开启多个线程，并行
     * 异步 + 主队列: 不开启新线程，在主线程执行
     */
//    [self asyncBlock:serialQueue];
//    [self asyncBlock:concurrentQueue];
//    [self asyncBlock:globalQueue];
//    [self asyncBlock:mainQueue];
    
//    [self asynGolbal];//面试题
    
    /* 3
     * dispatch_barrier_async 在 异步+并发队列，起到栅栏的作用
     * 顺序：异步执行完栅栏之前的任务后—>栅栏任务->异步栅栏之后的任务
     */
//    [self communication];
//    [self barrier];
//    [self mutliReadWrite];
    
//    [self after];
//    [self time];
//    [self once];
//    [self apply];

//    [self usingGroup];
    
    /*
     注意：group这里的任务必须要是同步执行的！！！
     注意：group这里的任务必须要是同步执行的！！！
     注意：group这里的任务必须要是同步执行的！！！
     group 的任务不能再有异步的线程
     */
//    [self group];
//    [self testUsingGroupAsync];
//    [self testUsingGroupEnterLeave];
//    [self usingGroup0];
//    [self testUsingGroupEnterLeave];
//    [self testUsingGroupAF];

    
//    [self question1];
//    [self question2];
//    [self question3];
//    [self question4];
    
    /*
     Semaphore 实现多个网络 异步请求，重点，重点，重点！
     */
//    [self testUsingSemaphore];

        /* 信号量 dispatch_semaphore */
//        semaphore 线程同步
//        [self semaphoreSync];
//        semaphore 线程安全
//        非线程安全：不使用 semaphore
//        [self initTicketStatusNotSave];
//        线程安全：使用 semaphore 加锁
//        [self initTicketStatusSave];
}

#pragma mark - 同步
// 1、同步+任何队列，都不会开启线程，串行；并且 + 主队列造成锁死
- (void)syncBlock:(dispatch_queue_t)queue {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"sync---begin");
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    NSLog(@"sync---end");
}
// 同步+并发队列，
- (void)syncGlobalQueue {
    /*
     1、同步任务，在当前线程执行。 -->打印1
     2、提交了一个{NSLog(@"2");dispatch_sync(globalQueue, ^{NSLog(@"3");});NSLog(@"4");任务到（全局并发队列），打印2
     3、又提交一个任务^{NSLog(@"3")};到全局并发队列，重点【并发队列，并发执行】，打印3,然后45
     });
     */
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"1");
    dispatch_sync(globalQueue, ^{
        NSLog(@"2");
        dispatch_sync(globalQueue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
    // 打印结果 12345
}
// 同步+串行队列
- (void)syncSerialQueue {
    dispatch_queue_t serialQueue = dispatch_queue_create("serial.queue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    dispatch_sync(serialQueue, ^{
        NSLog(@"2");
        dispatch_sync(serialQueue, ^{//死锁
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
    // 结果：1、2 死锁
}


#pragma mark - 异步
// 2、《异步+串行，开启一个线程 串行执行》《异步+并行/全局队列，开启多个线程异步执行》，《异步+主队列，在主线程串行执行》
- (void)asyncBlock:(dispatch_queue_t)queue {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"async---begin");
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    NSLog(@"async---end");
}



- (void)asynGolbal {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSLog(@"1");
        [self performSelector:@selector(printLog) withObject:nil afterDelay:0];
//        [self performSelector:@selector(printLog) withObject:nil];
        NSLog(@"3");
    });
}
- (void)printLog {
    NSLog(@"2");
}

/*
 1、^{}会被分派到GCD底层线程池，中一个线程执行，
 2、这些线程默认没有开始runloop的
 3、performSelector:withObject:afterDelay:
 需要提交到runloop的逻辑，所以performSelector要想执行，所属的线程必须有runloop，哪怕是afterDelay:0
 4、performSelector:withObject:不需要提交到runloop,会打印2
 */


#pragma mark - 线程间通信
// 3、异步处理数据，主线程刷新UI
- (void)communication {
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        // 异步处理数据
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
        // 回到主线程
        dispatch_async(mainQueue, ^{
            // 刷新UI
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
}

#pragma mark - barrier栅栏方法
// 4、栅栏方法 dispatch_barrier_async
- (void)barrier {
    // 只能使用 并发队列，使用globalQueue，不起作用
//    dispatch_queue_t queue = dispatch_queue_create("concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    // 如果你传的是一个串行队列或者全局并发队列，这个函数等同于dispatch_async函数。globalQueue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 开启新的线程3，把^{}放入DISPATCH_QUEUE_CONCURRENT队列，
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:3];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
     // 又开启一个新的线程6，把^{}放入DISPATCH_QUEUE_CONCURRENT队列，
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:3];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_barrier_async(queue, ^{
        // 追加任务 barrier
        [NSThread sleepForTimeInterval:3];
        NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务4
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
}
// 多读单写
- (void)mutliReadWrite {
    UserCenter * usercenter = [[UserCenter alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 120; i++) {
            NSString *key = [[NSString alloc] initWithFormat:@"%d",i];
            [usercenter setObject:@(i) forKey:key];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 10; i < 50; i++) {
            NSString *key = [[NSString alloc] initWithFormat:@"%d",i];
            NSLog(@"读取-%@",[usercenter objectForKey:key]);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 50; i < 100; i++) {
            NSString *key = [[NSString alloc] initWithFormat:@"%d",i];
            NSLog(@"读取-%@",[usercenter objectForKey:key]);
        }
    });

}

#pragma mark - 延迟执行
// 5、延时执行方法 dispatch_after
- (void)after {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
    });
}
#pragma mark - 定时执行
// 6、设置定时器
- (void)time {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    //2.设置定时器(起始时间|间隔时间|精准度)
    /*
     第一个参数:定时器对象
     第二个参数:起始时间,DISPATCH_TIME_NOW 从现在开始计时
     第三个参数:间隔时间 2.0 GCD中时间单位为纳秒
     第四个参数:精准度 绝对精准0
     */
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //3.设置定时器执行的任务
    static NSInteger i = 20;
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"timer---%ld",(long)i);
        i--;
        if (i <= 0) dispatch_cancel(timer);
    });
    //4.启动执行
    dispatch_resume(timer);
}

#pragma mark - 执行一次
// 7、一次性代码（只执行一次）dispatch_once
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行1次的代码(这里面默认是线程安全的)
    });
}

#pragma mark - 执行多次
// 8、快速迭代方法 dispatch_apply
- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    NSLog(@"apply---end");
}

#pragma mark - 组执行
// 9、dispatch_group_async 、dispatch_group_wait、dispatch_group_enter(进入组)、dispatch_group_leave（离开组）、dispatch_group_notify(组执行完毕的通知)
- (void)group {
    // 创建任务组
    dispatch_group_t group =  dispatch_group_create();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // group 中异步执行
    dispatch_group_async(group, globalQueue, ^{
//        [NSThread sleepForTimeInterval:2];
        NSLog(@"A");
        dispatch_async(dispatch_get_main_queue(), ^{ NSLog(@"A主线程刷新"); });
    });
    
    dispatch_group_enter(group);
    dispatch_async(globalQueue, ^{
//        [NSThread sleepForTimeInterval:2];
        NSLog(@"B");
        /* 会阻塞主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"B---刷新主线程");
            dispatch_group_leave(group);
        });
         */
        dispatch_group_leave(group);
    });

    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, globalQueue, ^{
        // 等前面的异步任务A、任务B、都执行完毕后，回到主线程执行下边任务
        NSLog(@"groupEnd主线程");
    });
    NSLog(@"D");
}
// A B D执行结束  A-刷新主线程  group---end


#pragma mark - 组应用

- (void)usingGroup0 {
    __block NSInteger number = 0;
        
    dispatch_group_t group = dispatch_group_create();
    
    // A耗时操作
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);
        NSLog(@"A耗时操作");
        number += 2222;
    });
    
    // B网络请求
    dispatch_group_enter(group);
    [self sendRequestWithCompletion:^(id response) {
        number += [response integerValue];
        NSLog(@"B耗时操作");
        dispatch_group_leave(group);
    }];
    
    // C网络请求
    dispatch_group_enter(group);
    [self sendRequestWithCompletion:^(id response) {
        number += [response integerValue];
        NSLog(@"C耗时操作");
        dispatch_group_leave(group);
    }];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"%zd", number);
    });
}

- (void)sendRequestWithCompletion:(void (^)(id response))completion {
    //模拟一个网络请求
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(@1111);
        });
    });
}

// 9、
/*
 A、B、C、D、E、F 五个任务
 A、B、C并发执行， A、B-->D ; B、C-->E ; D、E-->F
 */
- (void)usingGroup {
    dispatch_group_t AB = dispatch_group_create(); // A、B-->D
    dispatch_group_t BC = dispatch_group_create(); // B、C-->E
    dispatch_group_t DE = dispatch_group_create(); // D、E-->F
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_enter(AB);
    dispatch_async(globalQueue, ^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"--A--");
        }
        dispatch_group_leave(AB);
    });
    dispatch_group_enter(AB);
    dispatch_group_enter(BC);
    dispatch_async(globalQueue, ^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"--B--");
        }
        dispatch_group_leave(AB);
        dispatch_group_leave(BC);
    });
    dispatch_group_enter(BC);
    dispatch_async(globalQueue, ^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"--C--");
        }
        dispatch_group_leave(BC);
    });
    dispatch_group_enter(DE);
    // D依赖AB执行完毕，即AB的通知，代表AB执行完毕.AB->D
    dispatch_group_notify(AB, globalQueue, ^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"--D--");
        }
        dispatch_group_leave(DE);
    });
    
    dispatch_group_enter(DE);
    // E依赖BC执行完毕，即BC的通知，代表AB执行完毕.BC-->E
    dispatch_group_notify(BC, globalQueue, ^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"--E--");
        }
        dispatch_group_leave(DE);
    });
    
    // F依赖DE执行完毕，即DE的通知，代表AB执行完毕.DE-->F
    dispatch_group_notify(DE, globalQueue, ^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"--F--");
        }
    });
}

#pragma mark - 信号量
// 10、dispatch_semaphore_t 、dispatch_semaphore_wait、dispatch_semaphore_signal
- (void)semaphoreSync {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block int number = 0;
    dispatch_async(queue, ^{
        // 追加任务1
        [NSThread sleepForTimeInterval:4];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        number = 100;
        dispatch_semaphore_signal(semaphore);
    });

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"semaphoreSync end..");
}

#pragma mark - semaphore 线程安全
/**
 * 非线程安全：不使用 semaphore
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    
    self.ticketSurplusCount = 50;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    // 开启一个线程 买票
    dispatch_async(queue1, ^{
        [weakSelf saleTicketNotSafe];
    });
    // 开启一个线程 买票
    dispatch_async(queue2, ^{
        [weakSelf saleTicketNotSafe];
    });
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        if (self.ticketSurplusCount > 0) {  //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

/**
 * 线程安全：使用 semaphore 加锁
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */
- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    semaphoreLock = dispatch_semaphore_create(1);
    
    self.ticketSurplusCount = 50;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafe];
    });
}

// 售卖火车票(线程安全)
- (void)saleTicketSafe {
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        if (self.ticketSurplusCount > 0) {  //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            // 相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
            break;
        }
        // 相当于解锁
        dispatch_semaphore_signal(semaphoreLock);
    }
}

#pragma mark - 多个网络请求完成后，在执行

//模拟一个网络请求方法 get/post/put...etc
- (void)httpRequest:(NSString *)method param:(NSDictionary *)param completion:(void(^)(id response))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *commend = [param objectForKey:@"key"];
        NSLog(@"request:%@ run in thread:%@", commend, [NSThread currentThread]);
        NSTimeInterval sleepInterval = arc4random() % 10;
        [NSThread sleepForTimeInterval:sleepInterval];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"requset:%@ done!", commend);
            block(nil);
        });
    });
     
}

// 使用EnterLeave网络请求

- (void)testUsingGroupEnterLeave{
    NSArray *commandArray = @[@"requestcommand1", @"requestcommand2", @"requestcommand3", @"requestcommand4", @"requestcommand5"];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [commandArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        dispatch_async(queue, ^{
            NSLog(@"%@ in group thread:%@", obj, [NSThread currentThread]);
            [self AFhttpRequest:nil param:@{@"key" : obj} completion:^(id response) {
                dispatch_group_leave(group);
            }];
        });
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"all http request done!");
    });
    NSLog(@"testUsingGroupEnterLeave  finished!!!");
}

//AF模拟一个网络请求方法 get
- (void)AFhttpRequest:(NSString *)method param:(NSDictionary *)param completion:(void(^)(id response))block{
    NSString * url_str = [NSString stringWithFormat:@"https://api.androidhive.info/volley/person_object.json"];
    NSString *commend = [param objectForKey:@"key"];
    [[AFHTTPSessionManager manager] GET:url_str parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"requset:%@ done!", commend);
        block(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"AFGet --\n %@",error);
    }];
}

- (void)testUsingGroupAsync{
    NSArray *commandArray = @[@"requestcommand1", @"requestcommand2", @"requestcommand3", @"requestcommand4", @"requestcommand5"];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [commandArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_async(group, queue, ^{
            NSLog(@"%@ in group thread:%@", obj, [NSThread currentThread]);
            // 使用AFNetWorking发送网路请求
            [self AFhttpRequest:nil param:@{@"key" : obj} completion:^(id response) {
                
            }];
        });
    }];
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"all http request done!");
    });
    NSLog(@"testUsingGroup  finished!!!");
}

- (void)testUsingSemaphore{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSArray *commandArray = @[@"requestcommand1", @"requestcommand2", @"requestcommand3", @"requestcommand4", @"requestcommand5"];
    NSInteger commandCount = [commandArray count];
    //代表http访问返回的数量
    //这里模仿的http请求block块都是在同一线程（主线程）执行返回的，所以对这个变量的访问不存在资源竞争问题，故不需要枷锁处理
    //如果网络请求在不同线程返回，要对这个变量进行枷锁处理，不然很会有资源竞争危险
    __block NSInteger httpFinishCount = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //demo testUsingSemaphore方法是在主线程调用的，不直接调用遍历执行，而是嵌套了一个异步，是为了避免主线程阻塞
        NSLog(@"start all http dispatch in thread: %@", [NSThread currentThread]);
        [commandArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self httpRequest:nil param:@{@"key" : obj} completion:^(id response) {
                //全部请求返回才触发signal
                if (++httpFinishCount == commandCount) {
                    dispatch_semaphore_signal(sem);
                }
            }];
        }];
        //如果全部请求没有返回则该线程会一直阻塞
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        NSLog(@"all http request done! end thread: %@", [NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"UI update in main thread!");
        });
    });
}

- (void)question1 {
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    dispatch_async(queue, ^{
        NSLog(@"2");
        dispatch_async(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

/*
 答案：1、5、2、4、3
 分析：队列是并行队列，两次调用异步函数（dispatch_async），都会开启新的线程执行任务，并且不会堵塞当前线程。

 首先打印“1”，遇到异步函数不处理，然后打印“5”。
 第一层异步函数内执行逻辑与外部类似，打印“2”和“4”。
 最后执行第二次异步函数，打印“3”
 */


- (void)question2 {
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"1");
    });
    dispatch_async(queue, ^{
        NSLog(@"2");
    });
    
    dispatch_sync(queue, ^{ // 堵塞
        NSLog(@"3");
    });
    // **********************
    NSLog(@"0");
    dispatch_async(queue, ^{
        NSLog(@"7");
    });
    dispatch_async(queue, ^{
        NSLog(@"8");
    });
    dispatch_async(queue, ^{
        NSLog(@"9");
    });
    // A: 1230789
    // B: 1237890
    // C: 3120798
    // D: 2137890
}
/*
 答案：AC( - 3 - 0789 : 12 会在 — 任意位置)
 分析：
 并行队列添加相关任务，其中“3”是同步函数，会堵塞
 （堵塞的代码行在同步函数代码行结束的位置，也就是当前代码NSLog(@"3");下一行的“});”）当前线程。
 “0”在主线程中执行，其他的都是异步函数，所以“0”后面的异步函数肯定都会在“0”之后执行。
 因此本题答案是“3”在“0”之前，并且“7”、“8”、“9”在“0”之后。
 因此答案是AC。注意：“1”和“2”的位置不确定，这个取决于任务的时间复杂度，可以打开“1”中的sleep，打印查看一下结果，“1”会在“9”之后打印。
 */

- (void)question3 {
    // 串行队列
    dispatch_queue_t queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    // 异步函数
    dispatch_async(queue, ^{
        NSLog(@"2");
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}
/*
 答案：1、5、2、崩溃（EXC_BAD_INSTRUCTION）
 分析：
 在主线程队列中（串行队列），依次加入“1”、异步函数（dispatch_async）代码块、“5”
 异步函数开启子线程，不阻塞主线程，所以先打印“1”和“5”。
 子线程中，由于是串行队列，所以会把“2”、同步函数dispatch_sync、“4”这三个“任务”依次加入到queue中。
 子线程开始串行执行任务，打印“2”
 队列下一个任务是同步函数，会阻塞当前队列，然后把“3”加入到队列中，此时会产生死锁，此时队列情况：==dispatch_sync的block - “4” - “3”==
 同步函数需要“3”执行完，自己才能执行结束。
 由于“3”是在“4”后面加入到队列，所以“3”要等待“4”执行完成。
 “4”在同步函数后面加入到队列，所以得等待同步函数执行结束。
 等待情况：dispatch_sync - “3” - “4” - dispatch_sync，是互相等待的状态，因此出现了死锁。
 */

- (void)question4 {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t s = dispatch_semaphore_create(1);
    __block int a = 0; // 此处注意要加__block
    while (a < 5) {
        // 因为开启了子线程，所以在子线程执行(a++)之前，就会结束while一次循环，a保持<5的状态，所以会开启n个子线程
        dispatch_async(queue, ^{
            a++;
            NSLog(@"%@",[NSThread currentThread]);
            dispatch_semaphore_signal(s);
        });
        dispatch_semaphore_wait(s, DISPATCH_TIME_FOREVER);
    }
    NSLog(@"a = %d",a);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(1);
        NSLog(@"out a = %d", a);
    });
}


@end

