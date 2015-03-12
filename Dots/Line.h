//
//  Line.h
//  Dots
//
//  Created by LING HAO on 11/5/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dot.h"

enum PlayerType {
    PlayerType1,
    PlayerType2
};

enum LineType {
    LineTypeEmpty,
    LineTypePlayer1,
    LineTypePlayer2
};

@interface Line : NSObject

@property (nonatomic) Dot *endpoint1;
@property (nonatomic) Dot *endpoint2;
@property (nonatomic) enum LineType lineType;


- (instancetype)initWithEndpoint1:(Dot *)dot1 endpoint2: (Dot *)dot2;

- (CGRect) getTouchRect;

@end
