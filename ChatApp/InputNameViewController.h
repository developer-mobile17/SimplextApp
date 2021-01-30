//
//  InputNameViewController.h
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputNameViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UILabel *contactNumberOutlet;


- (IBAction)saveAction:(id)sender;
- (IBAction)backAction:(id)sender;

@end
