//
//  Dot.m
//  Dots
//
//  Created by LING HAO on 11/5/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import "Dot.h"

@implementation Dot

- (NSString *)description {
    return [NSString stringWithFormat:@"(%d, %d)", (int)self.point.x, (int)self.point.y];
}

@end
