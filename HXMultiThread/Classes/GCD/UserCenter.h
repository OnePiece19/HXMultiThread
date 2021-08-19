//
//  UserCenter.h
//  GCD
//
//  Created by HX on 2020/5/28.
//  Copyright © 2020 GCD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCenter : NSObject

// 读取操作
- (id)objectForKey:(NSString *)key;
// 写操作
- (void)setObject:(id)obj forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
