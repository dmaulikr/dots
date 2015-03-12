//
//  Box.m
//  Dots
//
//  Created by LING HAO on 11/5/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import "Box.h"

@implementation Box

- (BOOL) boxContainsLine: (Line *)line {
    if (line == self.top) {
        return true;
    } else if (line == self.right) {
        return true;
    } else if (line == self.bottom) {
        return true;
    } else if (line == self.left) {
        return true;
    }
    return false;
}

- (void) checkAndSetComplete: (enum PlayerType)playerType {
    if ((self.top.lineType != LineTypeEmpty) && (self.right.lineType != LineTypeEmpty) && (self.bottom.lineType != LineTypeEmpty) && (self.left.lineType != LineTypeEmpty)) {
        if (playerType == PlayerType1) {
            self.boxType = BoxTypePlayer1;
        } else if (playerType == PlayerType2) {
            self.boxType = BoxTypePlayer2;

        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Box type %u at top %@", self.boxType, self.top];
}

@end
