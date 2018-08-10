//
//  StringsFileManager.m
//  AnyLanguageTool
//
//  Created by easy on 2018/8/9.
//  Copyright © 2018年 Lang. All rights reserved.
//

#import "StringsFileManager.h"

@implementation StringsFileManager

static StringsFileManager *_manager = nil;
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [StringsFileManager new];
    });
    return _manager;
}

+ (void)setRootPath:(NSString *)rootPath {
    [[self manager] getFilesWithPath:rootPath];
}
#pragma mark - 目录解析
// 解析包含所有lproj目录的文件夹
- (void)getFilesWithPath:(NSString *)filePath {
    
    // 选择的路径已包含 *.lproj
    if ([filePath containsString:kDirSuffix]) {

        NSString *lprojFatherPath = [self getFatherPathWithLprojPath:filePath];
        [self getAllStringsFilesPathWithLprojPath:lprojFatherPath];
    } else {
        // 未知的lproj路径，需遍历查找到 xxx/x.lproj格式的路径
        NSDirectoryEnumerator *dirEnumer =[[NSFileManager defaultManager] enumeratorAtPath:filePath];
        for (NSString *subPath in dirEnumer.allObjects) {
            if ([subPath.pathExtension isEqualToString:kDirSuffix]) {
                // subPath: Demo/Base.lproj,需要去除
                NSString *lprojPath = [filePath stringByAppendingString:subPath];
                NSString *fatherPath = [self getFatherPathWithLprojPath:lprojPath];
                [self getAllStringsFilesPathWithLprojPath:fatherPath];
                break;
            }
        }
    }
}

/// 根据 *.lproj目录的完整路径解析其上级目录
- (NSString *)getFatherPathWithLprojPath:(NSString *)filePath {
    
    NSArray *pathLevels = filePath.pathComponents;
    NSString *targetPath = @"";
    for (NSString *levelName in pathLevels) {
        if ([levelName containsString:kDirSuffix]) {
            break;
        } else if (![levelName isEqualToString:@"/"]) {
            targetPath = [NSString stringWithFormat:@"%@/%@", targetPath, levelName];
        }
    }
    return targetPath;
}


// 列举该路径下的所有子路径,获取所有 .strings文件路径
- (void)getAllStringsFilesPathWithLprojPath:(NSString *)path {
    
    NSDirectoryEnumerator *dirEnumer =[[NSFileManager defaultManager] enumeratorAtPath:path];
    // 列举目录内容
    _allFileModel = @[].mutableCopy;
    _allLanguage = @[].mutableCopy;
    for (NSString *subPath in dirEnumer.allObjects) {
        if ([subPath.pathExtension isEqualToString:kDirSuffix]) {
            // strings文件完整路径，生成fileModel
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@/Localizable.strings", path, subPath];
            StringsFileModel *model = [StringsFileModel new];
            model.path = fullPath;
            [_allFileModel addObject:model];
            // 语种目录名
            NSString *dirName = [subPath substringToIndex:[subPath rangeOfString:@".lproj"].location];
            [_allLanguage addObject:dirName];
        }
    }
    
    // 回调外界
    if (_block) {
        _block(path);
    }
}

#pragma mark - 增删改操作
// 根据strings文件目录增改
+ (void)updateText:(NSString *)value forKey:(NSString *)key filePath:(NSString *)path {
    StringsFileManager *manager = [self manager];
    if (NSNotFound != [manager.allLanguage indexOfObject:path]) {
        NSInteger idx = [manager.allLanguage indexOfObject:path];
        [self updateText:value forKey:key atIndex:idx];
    }
}
// 根据语言列表下标增改
+ (void)updateText:(NSString *)value forKey:(NSString *)key atIndex:(NSInteger)index {
    StringsFileManager *manager = [self manager];
    if (index < manager.allFileModel.count) {
        StringsFileModel *model = manager.allFileModel[index];
        [model setTextValue:value forKey:key];
    }
}

// 删
+ (void)deleteTextForKey:(NSString *)key {
    [[[self manager] allFileModel] makeObjectsPerformSelector:@selector(deleteTextForKey:) withObject:key];
}

// 查
+ (NSString *)findTextValueForKey:(NSString *)key langIndex:(NSInteger)index {
    StringsFileManager *manager = [self manager];
    if (manager.allFileModel.count >index) {
        StringsFileModel *model = [[self manager] allFileModel][index];
        NSString *value = model.allValueDic[key];
        return value;
    }
    return @"";
}

+ (void)setRefreshDataHandle:(DirectoryAnalysisBlock)block {
    if (block) {
        StringsFileManager *manager = [self manager];
        manager.block = [block copy];
    }
}

@end
