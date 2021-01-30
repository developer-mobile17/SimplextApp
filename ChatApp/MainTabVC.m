//
//  MainTabVC.m
//  ChatApp
//
//  Created by macserver on 3/22/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "MainTabVC.h"

@interface MainTabVC ()

@end

@implementation MainTabVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  // [[UITabBar appearance] setBackgroundColor:[UIColor redColor]];
    
  // [[UITabBar appearance] setBackgroundColor:[UIColor colorWithRed:19.0/255.0 green:96.0/255.0 blue:156.0/255.0 alpha:1.0]];
  // [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.5]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
