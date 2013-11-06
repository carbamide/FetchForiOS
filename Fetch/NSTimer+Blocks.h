//
//  NSTimer+Blocks.h
//
//  Created by Jiva DeVoe on 1/14/11.
//  Copyright 2011 Random Ideas, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Block Extensions for NSTimer
 */
@interface NSTimer (Blocks)

/**
 *  Block based scheduled timer
 *
 *  @param inTimeInterval Time to wait
 *  @param inBlock        Block to execute
 *  @param inRepeats      Should the timer repeat?
 *
 *  @return NSTimer object
 */
+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

/**
 *  Block based timer
 *
 *  @param inTimeInterval Time to wait
 *  @param inBlock        Block to execute
 *  @param inRepeats      Should the timer repeat?
 *
 *  @return NSTimer object
 */
+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;
@end
