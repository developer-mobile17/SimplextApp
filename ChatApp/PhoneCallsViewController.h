//
//  PhoneCallsViewController.h
//  ChatApp
//
//  Created by macserver on 3/8/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneCallsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

- (IBAction)back_Action:(id)sender;
- (IBAction)phoneCallTopBar_Action:(id)sender;
- (IBAction)textMessageController_Action:(id)sender;
- (IBAction)phoneCallController_Action:(id)sender;
- (IBAction)settingController_Action:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end
