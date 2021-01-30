//
//  PhoneCallsTableViewCell.h
//  ChatApp
//
//  Created by macserver on 3/8/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneCallsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contactNumberOutlet;
@property (weak, nonatomic) IBOutlet UILabel *messageOutlet;
@property (weak, nonatomic) IBOutlet UILabel *timeOutlet;
@property (weak, nonatomic) IBOutlet UILabel *dateOutlet;

@property (weak, nonatomic) IBOutlet UIButton *info_outlet;
@property (weak, nonatomic) IBOutlet UIButton *call_outlet;



@end
