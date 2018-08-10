//
//  StringsFileModel.m
//  AnyLanguageTool
//
//  Created by easy on 2018/8/9.
//  Copyright © 2018年 Lang. All rights reserved.
//

#import "StringsFileModel.h"

@implementation StringsFileModel

- (dispatch_semaphore_t)lock {
    if (!_lock) {
        _lock = dispatch_semaphore_create(1);
    }
    return _lock;
}

- (void)setPath:(NSString *)path {
    if (_path != path) {
        _path = path;
        // 解析文件
        [self getFileContent];
        // 拆解出所有键值对
        [self getComponents];
    }
}

// 解析文件
- (void)getFileContent {
   
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:[NSURL URLWithString:_path] error:nil];
    NSString *fileContext = [[NSString alloc] initWithData:fileHandle.readDataToEndOfFile encoding:NSUTF8StringEncoding];
    _lang = fileContext;
}

// 解析所有字对和range
- (void)getComponents {
    
    NSString *symbol = @"\" = \"";
    NSRange rangeStart = [_lang rangeOfString:@"*/"];
    if (_lang.length <1 || rangeStart.location == NSNotFound) {
        return;
    }
    NSInteger startIndex = rangeStart.location+2;
    NSString *tmpLang = [_lang substringFromIndex:startIndex];
    tmpLang = [tmpLang stringByReplacingOccurrencesOfString:symbol withString:@"#"];
    tmpLang = [tmpLang stringByReplacingOccurrencesOfString:@";" withString:@"#"];
    tmpLang = [tmpLang stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    tmpLang = [tmpLang stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    tmpLang = [tmpLang stringByReplacingOccurrencesOfString:@";" withString:@""];
    if ([tmpLang hasSuffix:@"#"]) {
        tmpLang = [tmpLang substringToIndex:tmpLang.length -1];
    }
    
    NSArray *components;
    if (self.lang.length >0) {
        components = [tmpLang componentsSeparatedByString:@"#"];
    }
    
    if (components.count <2) {
        return;
    }
    
    _allValueDic = @{}.mutableCopy;
    NSInteger idx = 0;
    do {
        
        NSString *key = components[idx];
        NSString *value = components[idx+1];
        _allValueDic[key] = value;
        idx += 2;
    } while (idx+1 <components.count);
}

#pragma mark - 编辑
#pragma mark -- 增、改
- (void)setTextValue:(NSString *)value forKey:(NSString *)key {
    
    if (!value.length) {
        value = @"";
    }
    if (!key.length) {
        key = @"";
    }
    // key已存在，覆盖写入
    if ([_allValueDic.allKeys containsObject:key]) {
        NSString *oldValue = _allValueDic[key];
        if (![oldValue isEqualToString:value]) {
            _lang = [_lang stringByReplacingOccurrencesOfString:oldValue withString:value];
        } else {
            return;
        }
    } else {
        // 新增key
        _lang = [NSString stringWithFormat:@"%@\n\"%@\" = \"%@\";", _lang, key, value];
    }
    [_allValueDic setValue:value forKey:key];
    [self writeLangToFile];
}

#pragma mark -- 删
- (void)deleteTextForKey:(NSString *)key {
    NSString *value = _allValueDic[key];
    if (value.length <1) {
        value = @"";
    }
    NSString *text = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n", key, value];
    if (![_lang containsString:text]) {
        text = [text substringToIndex:text.length-1];
    }
    _lang = [_lang stringByReplacingOccurrencesOfString:text withString:@""];
    [_allValueDic removeObjectForKey:key];
    [self writeLangToFile];
}

#pragma mark -- 写文件
//  根据path属性将lang写入文件
- (void)writeLangToFile {
    // 锁
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);

    NSError *error = nil;
    BOOL isSuccess = [_lang writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!isSuccess) {
        NSLog(@"\n写入失败：%@\n", _path);
    }
    dispatch_semaphore_signal(self.lock);
}

@end
