//
//  LoginViewController.h
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITextField *txfEmail;
@property (strong, nonatomic) IBOutlet UITextField *txfPassword;


- (IBAction)actionLogin:(id)sender;
- (IBAction)actionForgotPassword:(id)sender;



@end
