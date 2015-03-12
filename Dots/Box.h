//
//  Box.h
//  Dots
//
//  Created by LING HAO on 11/5/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Line.h"

enum BoxType {
    BoxTypeEmpty,
    BoxTypePlayer1,
    BoxTypePlayer2
};

@interface Box : NSObject

@property (nonatomic) Line *top;
@property (nonatomic) Line *right;
@property (nonatomic) Line *bottom;
@property (nonatomic) Line *left;

@property (nonatomic) enum BoxType boxType;

- (BOOL) boxContainsLine: (Line *)line;

- (void) checkAndSetComplete: (enum PlayerType)playerType;

@end
