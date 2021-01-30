//
//  TextMessageViewController.h
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextMessageViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,UITextViewDelegate,UITextFieldDelegate>


- (IBAction)textMessageController_Action:(id)sender;
- (IBAction)phoneCallController_Action:(id)sender;
- (IBAction)settingController_Action:(id)sender;
- (IBAction)sendNewMessage_Action:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *viewSendMessage_Outlet;

@property (weak, nonatomic) IBOutlet UITextField *phoneNoNewMessage_outlet;
@property (weak, nonatomic) IBOutlet UITextView *txtNewMessage_outlet;
- (IBAction)sendMessage_Action:(id)sender;
- (IBAction)media_Action:(id)sender;
- (IBAction)closeDialouge_Action:(id)sender;


@end
