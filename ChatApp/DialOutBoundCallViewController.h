//
//  DialOutBoundCallViewController.h
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialOutBoundCallViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *contactnumberOutlet;

- (IBAction)back_Action:(id)sender;
- (IBAction)phoneCallTopBar_Action:(id)sender;
- (IBAction)textMessageController_Action:(id)sender;
- (IBAction)phoneCallController_Action:(id)sender;
- (IBAction)settingController_Action:(id)sender;
- (IBAction)dialNow_Action:(id)sender;



@end
