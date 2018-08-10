//
//  LangCellView.h
//  AnyLanguageTool
//
//  Created by easy on 2018/8/10.
//  Copyright © 2018年 Lang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LangCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *langName;

@property (weak) IBOutlet NSTextField *valueTextField;

@end
