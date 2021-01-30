//
//  SettingsViewController.h
//  ChatApp
//
//  Created by macserver on 3/8/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *notificationView;

- (IBAction)logOut_Action:(id)sender;

- (IBAction)back_Action:(id)sender;

- (IBAction)textMessageController_Action:(id)sender;
- (IBAction)phoneCallController_Action:(id)sender;
- (IBAction)settingController_Action:(id)sender;
- (IBAction)ChangePassword_Action:(id)sender;


@property (weak, nonatomic) IBOutlet UISwitch *notiFicationSwitch_outlet;



@end
