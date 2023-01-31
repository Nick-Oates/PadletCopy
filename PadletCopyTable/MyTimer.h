//
//  MyTimer.h
//  PadletCopyTable
//
//  Created by Nick Oates on 05/01/2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyTimer : NSTimer {
    MyTimer *theTimer;
}

+(NSTimer *)timerWithInterval: (NSTimeInterval) ti
                       target: (id) aTarget
                 selectorName: (NSString*) selString;
@end

NS_ASSUME_NONNULL_END
