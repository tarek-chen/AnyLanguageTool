//
//  StringsFileManager.h
//  AnyLanguageTool
//
//  Created by easy on 2018/8/9.
//  Copyright © 2018年 Lang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringsFileModel.h"

typedef void(^DirectoryAnalysisBlock)(NSString *rootPath);
@interface StringsFileManager : NSObject

@property (nonatomic, strong) NSMutableArray *allFileModel;
@property (nonatomic, strong) NSMutableArray *allLanguage;
@property (nonatomic, copy) DirectoryAnalysisBlock block;

+ (instancetype)manager;

/// 设定选择目录
+ (void)setRootPath:(NSString *)rootPath;

/// 修改指定目录下的strings文件
+ (void)updateText:(NSString *)value forKey:(NSString *)key filePath:(NSString *)path;
/// 修改指定的语言列表下标的strings文件
+ (void)updateText:(NSString *)value forKey:(NSString *)key atIndex:(NSInteger)index;
/// 删除所有文件中指定的key-value
+ (void)deleteTextForKey:(NSString *)key;
/// 查指定key对应语言的文案
+ (NSString *)findTextValueForKey:(NSString *)key langIndex:(NSInteger)index;


/// 解析完成后刷新数据
+ (void)setRefreshDataHandle:(DirectoryAnalysisBlock)block;

@end
