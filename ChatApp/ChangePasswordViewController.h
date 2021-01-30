//
//  ChangePasswordViewController.h
//  ChatApp
//
//  Created by macserver on 3/21/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController



- (IBAction)back_Action:(id)sender;
- (IBAction)send_Action:(id)sender;



@property (weak, nonatomic) IBOutlet UITextField *txtCurrentPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;



@end
