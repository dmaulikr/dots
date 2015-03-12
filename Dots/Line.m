//
//  Line.m
//  Dots
//
//  Created by LING HAO on 11/5/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import "Line.h"
#import <UIKit/UIKit.h>

@interface Line()

@property (nonatomic, readonly) CGRect touchRect;

@end

@implementation Line

const int MARGIN;

- (instancetype)initWithEndpoint1:(Dot *)dot1 endpoint2: (Dot *)dot2 {
    self = [super init];
    if (self) {
        self.endpoint1 = dot1;
        self.endpoint2 = dot2;
    }
    return self;
}

- (CGRect) getTouchRect {
    const int OFFSET = 5;
    int MARGIN;
    if (CGRectIsEmpty(_touchRect)) {
        if (self.endpoint1.location.x == self.endpoint2.location.x) {
            MARGIN = (self.endpoint2.location.y - self.endpoint1.location.y) / 3;
            _touchRect = CGRectMake(self.endpoint1.location.x - MARGIN, self.endpoint1.location.y + OFFSET, MARGIN * 2, self.endpoint2.location.y - self.endpoint1.location.y - OFFSET - OFFSET);
        } else {
            MARGIN = (self.endpoint2.location.x - self.endpoint1.location.x) / 3;
            _touchRect = CGRectMake(self.endpoint1.location.x + OFFSET, self.endpoint1.location.y - MARGIN, self.endpoint2.location.x - self.endpoint1.location.x - OFFSET - OFFSET, MARGIN * 2);
        }
    }
    return _touchRect;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Line at %@, %@", self.endpoint1, self. endpoint2];
}

@end
