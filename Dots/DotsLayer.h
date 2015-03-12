//
//  DotsLayer.h
//  Dots
//
//  Created by LING HAO on 11/20/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DotsLayer : CALayer

- (id)initWithDotArray:(NSMutableArray *) dotArray;

@property (nonatomic, weak) NSMutableArray *dotArray;

@end
