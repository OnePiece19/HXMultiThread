//
//  UserCenter.m
//  GCD
//
//  Created by HX on 2020/5/28.
//  Copyright © 2020 GCD. All rights reserved.
//

#import "UserCenter.h"

@interface UserCenter ()
{
    // 定义并发队列
    dispatch_queue_t concurrentQueue;
    // 用户数据中心，可能多个线程需要数据访问
    NSMutableDictionary *_userCenterDic;
}

@end

/// 多读单写模型
@implementation UserCenter

- (instancetype)init {
    self = [super init];
    if (self) {
        // 通过DISPATCH_QUEUE_CONCURRENT创建一个并发队列
        concurrentQueue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
        // 创建数据容器
        _userCenterDic = [NSMutableDictionary dictionary];
    }
    return self;
}
// 读：多个线程同时调用，可以立刻返回结果
- (id)objectForKey:(NSString *)key {
    __block id obj;
    // 同步 + 并发，读取指定数据，立刻返回结果
    dispatch_sync(concurrentQueue, ^{
        obj = [_userCenterDic objectForKey:key];
    });
    return obj;
}

// 写：
- (void)setObject:(id)obj forKey:(NSString *)key {
    // 异步栅栏调用设置数据
    dispatch_barrier_async(concurrentQueue, ^{
        [self->_userCenterDic setObject:obj forKey:key];
    });
}

@end
