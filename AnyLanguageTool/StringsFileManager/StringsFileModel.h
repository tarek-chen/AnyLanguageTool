//
//  StringsFileModel.h
//  AnyLanguageTool
//
//  Created by easy on 2018/8/9.
//  Copyright © 2018年 Lang. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kDirSuffix = @"lproj";

@interface StringsFileModel : NSObject

@property (nonatomic, strong) NSString *path;
/// 所有文字对信息
@property (nonatomic, strong) NSString *lang;

@property (nonatomic, strong) dispatch_semaphore_t lock;

@property (nonatomic, strong) NSMutableDictionary *allValueDic;

/// 增、改
- (void)setTextValue:(NSString *)value forKey:(NSString *)key;
/// 删
- (void)deleteTextForKey:(NSString *)key;

@end
