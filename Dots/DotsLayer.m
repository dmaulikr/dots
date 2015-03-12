//
//  DotsLayer.m
//  Dots
//
//  Created by LING HAO on 11/20/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import "DotsLayer.h"
#import "Dot.h"

@implementation DotsLayer

- (id)initWithDotArray:(NSMutableArray *) dotArray {
    NSLog(@"init with dotarray");
    self = [super init];
    if (self) {
        self.dotArray = dotArray;
    }
    return self;
}

- (id)initWithLayer:(id)layer {
    NSLog(@"init with layer");
    self = [super init];
    if (self) {
        if ([self isKindOfClass:[DotsLayer class]]) {
            DotsLayer *copyFrom = layer;
            self.frame = copyFrom.frame;
        }
    }
    return self;
}

- (id)init {
    NSLog(@"init dots layer");
    self = [super init];
    if (self) {
    }
    return self;
}

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

-(void)drawInContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    
    for (Dot *dot in self.dotArray) {
        [self strokeDot:dot];
    }

    UIGraphicsPopContext();
}

@end
