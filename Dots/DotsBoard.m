//
//  DotsBoard.m
//  Dots
//
//  Created by LING HAO on 11/18/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import "DotsBoard.h"
#import "Box.h"

@interface DotsBoard()

@property (nonatomic, strong) NSMutableArray *dotArray;
@property (nonatomic, strong) NSMutableArray *lineArray;
@property (nonatomic, strong) NSMutableArray *boxArray;


@end

@implementation DotsBoard

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        
        self.dotArray = [[NSMutableArray alloc]init];
        self.lineArray = [[NSMutableArray alloc]init];
        self.boxArray = [[NSMutableArray alloc]init];
        
        int xCount = 4;
        int yCount = 4;
        float size = (frame.size.width - 80) / (xCount - 1);
        float y = 80;
        for (int i = 0; i < xCount; i++) {
            float x = 40;
            for (int j = 0; j < yCount; j++) {
                
                Dot *dot = [[Dot alloc]init];
                dot.location = CGPointMake(x, y);
                dot.point = CGPointMake(j, i);
                [self.dotArray addObject:dot];
                
                x += size;
            }
            y += size;
        }
        
        for (int i = 0; i < xCount; i++) {
            for (int j = 0; j < yCount; j++) {
                if (i < (xCount - 1)) {
                    [self createLineFrom:CGPointMake(i, j) To:CGPointMake(i+1, j)];
                }
                if (j < (yCount - 1)) {
                    [self createLineFrom:CGPointMake(i, j) To:CGPointMake(i, j+1)];
                }
            }
        }
        
        for (int i = 0; i < xCount; i++) {
            for (int j = 0; j < yCount; j++) {
                if (i < (xCount - 1) && j < (yCount -1)) {
                    [self createBoxFrom:CGPointMake(i, j)];
                }
            }
        }
        
//        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
//        //tapRecognizer.delaysTouchesBegan = YES;
//        [self addGestureRecognizer:tapRecognizer];
//        
//        [self configureAudio];
    }
    return self;
}

- (Dot *) findDot:(CGPoint)point {
    for (Dot *dot in self.dotArray) {
        if (CGPointEqualToPoint(dot.point, point)) {
            return dot;
        }
    }
    return nil;
}

- (Line *) findLine:(CGPoint)p1 To: (CGPoint)p2 {
    for (Line *line in self.lineArray) {
        if (CGPointEqualToPoint(p1, line.endpoint1.point) && CGPointEqualToPoint(p2, line.endpoint2.point)) {
            return line;
        }
    }
    return nil;
}

- (Line *) findLineAtLocation:(CGPoint)point {
    for (Line *line in self.lineArray) {
        CGRect rect = [line getTouchRect];
        if (CGRectContainsPoint(rect, point)) {
            return line;
        }
    }
    return nil;
}

- (void) createLineFrom:(CGPoint)p1 To: (CGPoint)p2 {
    Line *line = [[Line alloc]initWithEndpoint1:[self findDot:p1] endpoint2:[self findDot:p2]];
    [self.lineArray addObject:line];
}

- (void) createBoxFrom:(CGPoint)point {
    Box *box = [[Box alloc]init];
    CGPoint p1 = point;
    CGPoint p2 = CGPointMake(point.x + 1, point.y);
    CGPoint p3 = CGPointMake(point.x + 1, point.y + 1);
    CGPoint p4 = CGPointMake(point.x, point.y + 1);
    box.top = [self findLine:p1 To:p2];
    box.right = [self findLine:p2 To:p3];
    box.bottom = [self findLine:p4 To:p3];
    box.left = [self findLine:p1 To:p4];
    [self.boxArray addObject:box];
}

- (BOOL) checkBoxComplete:(Line *)line playerType: (enum PlayerType)type {
    int completeCount = 0;
    for (Box *box in self.boxArray) {
        if (box.boxType == BoxTypeEmpty && [box boxContainsLine:line]) {
            [box checkAndSetComplete:type];
            if (box.boxType != BoxTypeEmpty) {
                completeCount++;
            }
        }
    }
    return completeCount > 0;
}

- (BOOL) gameOver {
    for (Box *box in self.boxArray) {
        if (box.boxType == BoxTypeEmpty) {
            return false;
        }
    }
    return true;
}

- (BOOL) player1Won {
    int count1 = 0;
    int count2 = 0;
    for (Box *box in self.boxArray) {
        if (box.boxType == BoxTypePlayer1) {
            count1++;
        } else if (box.boxType == BoxTypePlayer2) {
            count2++;
        }
    }
    return count1 >= count2;
}

- (Line *) selectALine {
    NSMutableArray *one = [[NSMutableArray alloc]init];
    NSMutableArray *two = [[NSMutableArray alloc]init];
    NSMutableArray *three = [[NSMutableArray alloc]init];
    NSMutableArray *four = [[NSMutableArray alloc]init];
    for (Box *box in self.boxArray) {
        int emptyLines = 0;
        if (box.top.lineType == LineTypeEmpty) {
            emptyLines += 1;
        }
        if (box.right.lineType == LineTypeEmpty) {
            emptyLines += 1;
        }
        if (box.bottom.lineType == LineTypeEmpty) {
            emptyLines += 1;
        }
        if (box.left.lineType == LineTypeEmpty) {
            emptyLines += 1;
        }
        switch (emptyLines) {
            case 1:
                if (box.top.lineType == LineTypeEmpty) {
                    [one addObject:box.top];
                }
                if (box.right.lineType == LineTypeEmpty) {
                    [one addObject:box.right];
                }
                if (box.bottom.lineType == LineTypeEmpty) {
                    [one addObject:box.bottom];
                }
                if (box.left.lineType == LineTypeEmpty) {
                    [one addObject:box.left];
                }
                break;
            case 2:
                if (box.top.lineType == LineTypeEmpty) {
                    [two addObject:box.top];
                }
                if (box.right.lineType == LineTypeEmpty) {
                    [two addObject:box.right];
                }
                if (box.bottom.lineType == LineTypeEmpty) {
                    [two addObject:box.bottom];
                }
                if (box.left.lineType == LineTypeEmpty) {
                    [two addObject:box.left];
                }
                break;
            case 3:
                if (box.top.lineType == LineTypeEmpty) {
                    [three addObject:box.top];
                }
                if (box.right.lineType == LineTypeEmpty) {
                    [three addObject:box.right];
                }
                if (box.bottom.lineType == LineTypeEmpty) {
                    [three addObject:box.bottom];
                }
                if (box.left.lineType == LineTypeEmpty) {
                    [three addObject:box.left];
                }
                break;
            case 4:
                if (box.top.lineType == LineTypeEmpty) {
                    [four addObject:box.top];
                }
                if (box.right.lineType == LineTypeEmpty) {
                    [four addObject:box.right];
                }
                if (box.bottom.lineType == LineTypeEmpty) {
                    [four addObject:box.bottom];
                }
                if (box.left.lineType == LineTypeEmpty) {
                    [four addObject:box.left];
                }
                break;
        }
    }
    NSUInteger count = [one count];
    if (count >= 1) {
        NSUInteger index = arc4random_uniform((unsigned)count);
        return [one objectAtIndex:index];
    }
    count = [four count];
    if (count >= 1) {
        NSUInteger index = arc4random_uniform((unsigned)count);
        return [four objectAtIndex:index];
    }
    count = [three count];
    if (count >= 1) {
        NSUInteger index = arc4random_uniform((unsigned)count);
        return [three objectAtIndex:index];
    }
    count = [two count];
    if (count >= 1) {
        NSUInteger index = arc4random_uniform((unsigned)count);
        return [two objectAtIndex:index];
    }
    return nil;
}

- (void) newGame {
    for (Line *line in self.lineArray) {
        line.lineType = LineTypeEmpty;
    }
    
    for (Box *box in self.boxArray) {
        box.boxType = BoxTypeEmpty;
    }
    
//    [self setNeedsDisplay];
}


@end
