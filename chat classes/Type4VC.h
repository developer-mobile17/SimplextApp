//
//  Type4VC.h
//  SOSimpleChatDemo
//
//  Created by Artur Mkrtchyan on 7/21/14.
//  Copyright (c) 2014 SocialOjbects Software. All rights reserved.
//

#import "SOMessagingViewController.h"

@interface Type4VC : SOMessagingViewController<UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>{
    IBOutlet UILabel *labelChatWith;
    
    NSTimer* myTimer;
    
    NSMutableString *strMessageId;

}

-(IBAction)actionBack:(id)sender;
@property(nonatomic,retain)NSString *strPropertyId;
@property(nonatomic,retain)NSString *strPropertyName;
@property (strong, nonatomic) IBOutlet UIImageView *loadingimage;
@property (strong, nonatomic) UIImage *myImage;
@property (strong, nonatomic) UIImage *partnerImage;
@property (weak, nonatomic) IBOutlet UIButton *info_Outlet;

- (IBAction)info_Action:(id)sender;

@end
