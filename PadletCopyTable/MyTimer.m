//
//  MyTimer.m
//  PadletCopyTable
//
//  Created by Nick Oates on 05/01/2023.
//

#import "MyTimer.h"

@implementation MyTimer
+(NSTimer *)timerWithInterval: (NSTimeInterval) ti
                       target: (id) aTarget
                 selectorName: (NSString*) selString {
    return [NSTimer scheduledTimerWithTimeInterval: ti
                                            target: aTarget
                                          selector: NSSelectorFromString(selString)
                                          userInfo: nil
                                            repeats: YES];
}
@end
