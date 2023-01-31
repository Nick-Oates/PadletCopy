//
//  NSTableCellViewWithCheckbox.h
//  PadletCopyTable
//
//  Created by Nick Oates on 22/12/2022.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTableCellViewWithCheckbox : NSTableCellView
    @property (weak) IBOutlet NSButton *checkbox;
@end

NS_ASSUME_NONNULL_END
