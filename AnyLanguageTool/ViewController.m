//
//  ViewController.m
//  AnyLanguageTool
//
//  Created by easy on 2018/8/9.
//  Copyright © 2018年 Lang. All rights reserved.
//

#import "ViewController.h"
#import "StringsFileManager.h"
#import "LangCellView.h"

@interface ViewController()<NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTextField *dirTextFiled;
@property (weak) IBOutlet NSTextField *searchKeyWord;
@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.selectionHighlightStyle = -1;
    
    [StringsFileManager setRefreshDataHandle:^(NSString *rootPath) {
        _dirTextFiled.stringValue = rootPath.stringByResolvingSymlinksInPath;
        [_tableView reloadData];
    }];
}



- (IBAction)selectDirectory:(NSButton *)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = NO;
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = YES;
    panel.allowedFileTypes = [NSArray arrayWithObjects: @"strings", nil];
    panel.allowsOtherFileTypes = YES;
    [panel setPrompt: @"打开"];
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        
        if (result == NSFileHandlingPanelOKButton) {
            
            NSURL *pathURL = panel.URLs.firstObject;
            // 解析路径
            NSString *filePath = [pathURL path];
            [StringsFileManager setRootPath:filePath];
        }
    }];
}

#pragma mark - Table
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return [StringsFileManager manager].allLanguage.count;
}
//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//    NSString *rowData = [NSString stringWithFormat:@"%@ - %ld",tableColumn.title,(long)row];
//    return rowData;
//}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    LangCellView *cell = [tableView makeViewWithIdentifier:@"LangCell" owner:nil];
    
    StringsFileManager *manager = [StringsFileManager manager];
    NSString *langName = manager.allLanguage[row];
    cell.langName.stringValue = langName;
    cell.valueTextField.placeholderString = langName;
    NSString *key = _searchKeyWord.stringValue;
    NSString *value = [StringsFileManager findTextValueForKey:key langIndex:row];
    if (value.length >0) {
        cell.valueTextField.stringValue = value;
    } else {
        cell.valueTextField.stringValue = @"";
    }
    return cell;
}

//- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//    NSString *strIdt = @"123";
//}

#pragma mark -- 行高
-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 44;
}

//设置鼠标悬停在cell上显示的提示文本
- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation{

    NSString *key = _searchKeyWord.stringValue;
    NSString *value = [StringsFileManager findTextValueForKey:key langIndex:row];

    return value;
}
//当列表长度无法展示完整某行数据时 当鼠标悬停在此行上 是否扩展显示
- (BOOL)tableView:(NSTableView *)tableView shouldShowCellExpansionForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    return YES;
}

#pragma mark - 交互

- (IBAction)searchAction:(NSButton *)sender {
    [_tableView reloadData];
}

- (IBAction)deleteAction:(NSButton *)sender {
    NSString *key = _searchKeyWord.stringValue;
    [StringsFileManager deleteTextForKey:key];
    [_tableView reloadData];

}

- (IBAction)updateAction:(NSButton *)sender {
    NSString *key = _searchKeyWord.stringValue;

    StringsFileManager *manager = [StringsFileManager manager];
    for (NSInteger idx = 0; idx <manager.allFileModel.count; idx++) {
        LangCellView *cell = [_tableView viewAtColumn:0 row:idx makeIfNecessary:YES];
        NSString *value = cell.valueTextField.stringValue;
        [StringsFileManager updateText:value forKey:key atIndex:idx];
    }
    
    [_tableView reloadData];
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


@end
