//
//  DotsView.m
//  Dots
//
//  Created by LING HAO on 11/5/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import "DotsView.h"
#import "Box.h"
#import "DotsLayer.h"
#import <AVFoundation/AVFoundation.h>

@interface DotsView() <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *dotArray;
@property (nonatomic, strong) NSMutableArray *lineArray;
@property (nonatomic, strong) NSMutableArray *boxArray;

@property (nonatomic, strong) Line *currentLine;

@property (nonatomic, strong) DotsLayer *dotsLayer;
@property (nonatomic, strong) CAShapeLayer *lineLayer;

@property (assign) SystemSoundID cheerSound;
@property (assign) SystemSoundID awwSound;


@end

@implementation DotsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
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
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        //tapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:tapRecognizer];

        [self configureAudio];
        
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.backgroundColor = [[UIColor clearColor] CGColor];
        _lineLayer.strokeColor = [[UIColor whiteColor] CGColor];
        _lineLayer.lineWidth = 8.0f;
        _lineLayer.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:_lineLayer];

        _dotsLayer = [[DotsLayer alloc] initWithDotArray:self.dotArray];
        _dotsLayer.backgroundColor = [[UIColor clearColor] CGColor];
        _dotsLayer.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        [self.layer addSublayer:_dotsLayer];
        [_dotsLayer setNeedsDisplay];
        
        [self newGame];
    }
    return self;
}

- (void) configureAudio
{
    NSString *cheerPath = [[NSBundle mainBundle]
                            pathForResource:@"Yay1" ofType:@"mp3"];
    NSURL *cheerURL = [NSURL fileURLWithPath:cheerPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)cheerURL, &_cheerSound);

    NSString *awwPath = [[NSBundle mainBundle]
                            pathForResource:@"Aww1" ofType:@"mp3"];
    NSURL *awwURL = [NSURL fileURLWithPath:awwPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)awwURL, &_awwSound);
}

- (void) tap: (UIGestureRecognizer *)gr
{
    NSLog(@"Recognized tap");
    
    if (gr.state == UIGestureRecognizerStateEnded) {
        NSLog(@"ended");
        CGPoint point = [gr locationInView:self];
        [self tapAtPoint:point];
    } else if (gr.state == UIGestureRecognizerStateBegan) {
        NSLog(@"began");
    } else if (gr.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"recognized");
    } else if (gr.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"cancelled");
    } else if (gr.state == UIGestureRecognizerStateFailed) {
        NSLog(@"failed");
    }
}

- (void) animateLine: (Line *)line
{
    UIBezierPath *fromPath = [UIBezierPath bezierPath];
    [fromPath moveToPoint: line.endpoint2.location];
    [fromPath addLineToPoint:line.endpoint1.location];

    UIBezierPath *toPath = [UIBezierPath bezierPath];
    [toPath moveToPoint: line.endpoint2.location];
    [toPath addLineToPoint:line.endpoint2.location];
    
    CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnim.fromValue = (id)fromPath.CGPath;
    pathAnim.toValue = (id)toPath.CGPath;
    pathAnim.duration = 0.5;
    [_lineLayer addAnimation:pathAnim forKey:@"pathAnimation"];
    
    [_lineLayer setNeedsDisplay];
}

- (void) computerPlay:(NSTimer*)timer
{
    NSLog(@"computerPlay %@", timer);
    Line *newLine = [self selectALine];
    if (newLine != nil && newLine.lineType == LineTypeEmpty) {
        [self animateLine:newLine];
        newLine.lineType = LineTypePlayer2;
        if ([self checkAndSetBoxComplete:newLine playerType:PlayerType2]) {
            [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(computerPlay:)
                                           userInfo:nil
                                            repeats:NO];
            if ([self gameOver]) {
                [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(checkGameOver:)
                                               userInfo:nil
                                                repeats:NO];
            }
        }
        [self setNeedsDisplay];
    }
}

- (void)checkGameOver: (NSTimer *)timer
{
    if ([self gameOver]) {
        if ([self player1Won]) {
            AudioServicesPlaySystemSound(self.cheerSound);
            NSLog(@"You won!!");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Good job!!" message:@"Start a new game?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            AudioServicesPlaySystemSound(self.awwSound);
            NSLog(@"I won!!");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"The computer won." message:@"Start a new game?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
}


- (void) tapAtPoint: (CGPoint)point
{
//    Line *line = [self findLineAtLocation:point];
    Line *line = [self currentLine];
    if (line != nil && line.lineType == LineTypeEmpty) {
        line.lineType = LineTypePlayer1;
        BOOL completed = false;
        if ([self checkAndSetBoxComplete:line playerType:PlayerType1]) {
            completed = true;
            [self checkGameOver:nil];
        }
        [self setNeedsDisplay];
        
        if (!completed) {
            // player2 aka computer
            [self computerPlay: nil];
        }
        
    }
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

- (BOOL) checkAndSetBoxComplete:(Line *)line playerType: (enum PlayerType)type {
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
    
    CABasicAnimation *stepAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    int x = (self.layer.frame.size.width / 2.0);
    stepAnim.fromValue = [NSValue valueWithCGPoint:CGPointMake(x, -(self.layer.frame.size.height / 2.0))];
    stepAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(x, (self.layer.frame.size.height / 2.0))];
    stepAnim.duration = 1.0;
    [_dotsLayer addAnimation:stepAnim forKey:@"strokeEndAnimation"];

    [self setNeedsDisplay];
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [self newGame];
    }
}

#pragma touches
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionBegan");
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionCancelled");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionEnded");
    
    [self newGame];
}

#pragma touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    
    CGPoint location = [t locationInView:self];
    Line *line = [self findLineAtLocation:location];
    if (line != nil) {
        self.currentLine = line;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    BOOL redraw = NO;
    
    CGPoint location = [t locationInView:self];
    Line *line = [self findLineAtLocation:location];
    if (line.lineType == LineTypePlayer1 || line.lineType == LineTypePlayer2) {
        line = nil;
    }
    
    if (line != nil) {
        if (![line isEqual:self.currentLine]) {
            self.currentLine = line;
            redraw = YES;
            NSLog(@"currentLine at: %f, %f", location.x, location.y);
        }
    } else {
        if (self.currentLine != nil) {
            self.currentLine = nil;
            redraw = YES;
            NSLog(@"empty currentline");
        }
    }
    
    if (redraw) {
        [self setNeedsDisplay];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled");
    self.currentLine = nil;
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    UITouch *t = [touches anyObject];
    CGPoint point = [t locationInView:self];
    [self tapAtPoint:point];

    self.currentLine = nil;

    [self setNeedsDisplay];
}

#pragma drawRect

- (void) strokeDot:(Dot *)dot {
    // Ebony Clay #22313F
    const UIColor *dotColor = [UIColor colorWithRed:34.0/255.0f green:49.0/255.0f blue:63.0/255.0f alpha:1.0f];
    [dotColor setFill];
    [[UIColor darkGrayColor] setStroke];
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 2;
    bp.lineCapStyle = kCGLineCapSquare;
    
    [bp addArcWithCenter:dot.location radius:5.0 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [bp fill];

    [bp addArcWithCenter:dot.location radius:6.0 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [bp stroke];
}

- (void) strokeLine:(Line *)line {
    
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 8;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint: line.endpoint1.location];
    [bp addLineToPoint:line.endpoint2.location];
    [bp stroke];
}

- (void) strokeBox:(Box *)box {
    UIBezierPath *bp = [UIBezierPath bezierPath];
    
    [bp moveToPoint: box.top.endpoint1.location];
    [bp addLineToPoint:box.top.endpoint2.location];
    [bp addLineToPoint:box.right.endpoint2.location];
    [bp addLineToPoint:box.left.endpoint2.location];
    [bp addLineToPoint:box.left.endpoint1.location];
    [bp fill];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    NSLog(@"drawRect");
    for (Box *box in self.boxArray) {
        if (box.boxType == BoxTypePlayer1) {
            // Piction Blue #22A7F0
            const UIColor *boxColor1 = [UIColor colorWithRed:34.0/255.0f green:168.0/255.0f blue:240.0/255.0f alpha:1.0f];
            [boxColor1 set];
            [self strokeBox:box];
        } else if (box.boxType == BoxTypePlayer2){
            // Fire Bush #EB9532
            const UIColor *boxColor2 = [UIColor colorWithRed:235.0/255.0f green:149.0/255.0f blue:50.0/255.0f alpha:1.0f];
            [boxColor2 set];
            [self strokeBox:box];
        }
    }
    
    for (Line *line in self.lineArray) {
        if (line.lineType == LineTypePlayer1) {
            // Jelly Bean #2574A9
            const UIColor *lineColor1 = [UIColor colorWithRed:37.0/255.0f green:116.0/255.0f blue:169.0/255.0f alpha:1];
            [lineColor1 set];
            [self strokeLine:line];
        } else if (line.lineType == LineTypePlayer2) {
            // Burnt Orange #D35400
            const UIColor *lineColor2 = [UIColor colorWithRed:211.0/255.0f green:84.0/255.0f blue:0.0f alpha:1];
            [lineColor2 set];
            [self strokeLine:line];
        }
    }
    
    // Ebony Clay #22313F
    const UIColor *currentLineColor = [UIColor colorWithRed:34.0/255.0f green:49.0/255.0f blue:63.0/255.0f alpha:1.0f];
    [currentLineColor set];
    if (self.currentLine != nil) {
        [self strokeLine:self.currentLine];
    }
    
}

@end
