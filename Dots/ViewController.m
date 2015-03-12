//
//  ViewController.m
//  Dots
//
//  Created by LING HAO on 11/5/14.
//  Copyright (c) 2014 Blue Bambosa. All rights reserved.
//

#import "ViewController.h"
#import "DotsView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    self.view = [[DotsView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
}


@end
