//
//  Type4VC.m
//  SOSimpleChatDemo
//
//  Created by Artur Mkrtchyan on 7/21/14.
//  Copyright (c) 2014 SocialOjbects Software. All rights reserved.
//

#import "Type4VC.h"
#import "ContentManager.h"
#import "Message.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "InputNameViewController.h"


@interface Type4VC ()

@property (strong, nonatomic) NSMutableArray *dataSource;



@end

@implementation Type4VC
{
    AppDelegate*appdelegate;
    MBProgressHUD *hud;
    NSMutableArray *messages,*tempArray;
    NSString *msgId;
    NSString *contactName;
    
}

@synthesize strPropertyId,loadingimage,strPropertyName,myImage,partnerImage;


#pragma mark  viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    messages  =[[NSMutableArray alloc]init];
    tempArray  =[[NSMutableArray alloc]init];
    contactName = [[NSUserDefaults standardUserDefaults] valueForKey:@"contactName"];
    msgId = [[NSUserDefaults standardUserDefaults] valueForKey:@"msgId"];
    [labelChatWith  setText:contactName];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"back"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"CallGetMessahgeApiBack"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //callConversationMethod
    [self callConversationMethod];
    

}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark  callConversationMethod
-(void)callConversationMethod
{
    //  Call Conversation Webservice
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        [self showMessage:@"No Internet Connection"
                withTitle:@""];
    }
    else
    {
                hud = [[MBProgressHUD alloc]init];
                hud.labelFont = [UIFont systemFontOfSize:10];
                hud.labelText = @"Loading...";
                [hud show:YES];
                [self.view addSubview:hud];
        [self performSelector:@selector(conversations_API) withObject:nil afterDelay:0.1];
    }
    [self performSelector:@selector(refreshConversation) withObject:nil afterDelay:10.0];
}

-(void)refreshConversation
{
    if([[[ NSUserDefaults standardUserDefaults] valueForKey:@"back"] isEqualToString:@"NO"])
    {
    }
    else
    {
        NSLog(@"Refresh Conversation");
        [self performSelectorInBackground:@selector(conversations_API) withObject:nil];
        [self performSelector:@selector(refreshConversation) withObject:nil afterDelay:10.0];
    }
}

#pragma mark  callForNotification
-(void)callForNotification
{
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"checkView"] isEqualToString:@"YES"])
    {
        //Call conversation api
        [self performSelector:@selector(conversations_API) withObject:nil afterDelay:0.5];
    }
    else
    {
       // [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkView"];
    }
     [self performSelector:@selector(callForNotification) withObject:nil afterDelay:0.5];
}

#pragma mark - Alert Method
-(void)showMessage:(NSString*)message withTitle:(NSString *)title
{
    UIAlertController * alert =[UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^( UIAlertAction *action )
                               {
                                   // do something when click button
                               }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark viewWillDisappear
-(void)viewWillDisappear:(BOOL)animated
{
    //  [super viewDidDisappear:YES];
    
    [super viewWillDisappear:YES];
    
    if ([myTimer isValid]) {
        [myTimer invalidate];
    }
}

#pragma mark  loadingPanelStart
-(void)loadingPanelStart
{
    loadingimage=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-20, 260, 50, 50)];
    loadingimage.layer.cornerRadius=25;
    loadingimage.clipsToBounds=YES;
    
    loadingimage.image=[UIImage imageNamed:@"1-logo.png"];
    
    [self.view addSubview:loadingimage];
    
    [loadingimage bringSubviewToFront:self.view];
    loadingimage.hidden=NO;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
    rotation.duration = 1.1; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [loadingimage.layer addAnimation:rotation forKey:@"Spin"];
}

#pragma mark  loadingPanelStop

-(void)loadingPanelStop
{
    [loadingimage.layer removeAnimationForKey:@"Spin"];
    loadingimage.hidden=YES;
    
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
    {
        // Start interaction with application
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

-(IBAction)actionBack:(id)sender
{
    if([[[ NSUserDefaults standardUserDefaults] valueForKey:@"back"] isEqualToString:@"YES"])
    {
       
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"back"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)loadMessages
{
    self.dataSource = [[[ContentManager sharedManager] generateConversation] mutableCopy];
}

-(void)loadMessagesCustom:(NSArray*)aryM
{
    self.dataSource=[[[ContentManager sharedManager]generateConversationNew:aryM] mutableCopy];    
}

#pragma mark - SOMessaging data source
- (NSMutableArray *)messages
{
    return self.dataSource;
}

- (NSTimeInterval)intervalForMessagesGrouping
{
    // Return 0 for disableing grouping
    return 60 ;
   // return 0;
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    
    Message *message = self.dataSource[index];
    // Adjusting content for 3pt. (In this demo the width of bubble's tail is 3pt)
    if (!message.fromMe)
    {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
        cell.textView.textColor = [UIColor blackColor];
        
    } else
    {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.userImageView.layer.cornerRadius = self.userImageSize.width/2;
    
    // Fix user image position on top or bottom.
    cell.userImageView.autoresizingMask = message.fromMe ? UIViewAutoresizingFlexibleTopMargin : UIViewAutoresizingFlexibleBottomMargin;
   
    // Setting user images
    cell.userImage = message.fromMe ? [UIImage imageNamed:@"logo.png"]: [UIImage imageNamed:@"for_Seller.png"];
    [self generateUsernameLabelForCell:cell];
}

#pragma mark generateUsernameLabelForCell

- (void)generateUsernameLabelForCell:(SOMessageCell *)cell
{
    static NSInteger labelTag = 666;

    Message *message = (Message *)cell.message;
    UILabel *label = (UILabel *)[cell.containerView viewWithTag:labelTag];
    if (!label)
    {
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:8];
        label.textColor = [UIColor grayColor];
        label.tag = labelTag;
       // label.numberOfLines=4;
        [cell.containerView addSubview:label];
    }
    label.text = message.fromMe ? @"Me" : strPropertyName;
    [label sizeToFit];

    CGRect frame = label.frame;
    
    CGFloat topMargin = 2.0f;
    if (message.fromMe)
    {
        frame.origin.x = cell.userImageView.frame.origin.x + cell.userImageView.frame.size.width/2 - frame.size.width/2;
        frame.origin.y = cell.containerView.frame.size.height + topMargin;

    } else
    {
        frame.origin.x = cell.userImageView.frame.origin.x + cell.userImageView.frame.size.width/2 - frame.size.width/2;
        
        frame.origin.y = cell.userImageView.frame.origin.y + cell.userImageView.frame.size.height + topMargin;
        
//        if (frame.origin.x<0) {
//            frame.origin.x = 7;
//            frame.origin.y=25;
//            frame.size.width=35;
//            frame.size.height=60;
//        }

        
       // NSLog(@"label frame==%@",NSStringFromCGRect(frame));
    }
    label.frame = frame;
    
}
- (CGFloat)messageMaxWidth
{
    return 140;
}

- (CGSize)userImageSize
{
    return CGSizeMake(40, 40);
}

- (CGFloat)messageMinHeight
{
    return 0;
}

#pragma mark didselectuserimage

-(void)didselectuserimage:(BOOL)user inMessageCell:(SOMessageCell *)cell
{
      Message *message = (Message *)cell.message;     
     if (message.fromMe)
     {
         NSLog(@"ME");
     }
    
     else
     {
         NSLog(@"Other");
         
         if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_type"]]isEqualToString:@"U"])
         {
//             otherCustomerProfileViewController*otherCustomerProfile=[self.storyboard instantiateViewControllerWithIdentifier:@"otherCustomerProfileViewController"];
//             
//             otherCustomerProfile.customerID=strPropertyId;
//             
//             [self.navigationController pushViewController:otherCustomerProfile animated:YES];
         }
         else
         {
//             FollowsUserProfileViewController*FollowsVW=[self.storyboard instantiateViewControllerWithIdentifier:@"FollowsUserProfileViewController"];
//             FollowsVW.classtype=@"Type4ToFollow";
//             FollowsVW.userId=strPropertyId;
//             [self.navigationController pushViewController:FollowsVW animated:YES];
         }
     }
}


#pragma mark - SOMessaging delegate

- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell
{
    // Show selected media in fullscreen
    [super didSelectMedia:media inMessageCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message
{
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
    {
        return;
    }
    
    Message *msg = [[Message alloc] init];
    msg.text = message;
    msg.fromMe = YES;
    msg.textID=@"u";    
    
    [self sendMessage:msg];
   
    
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    [self.view endEditing:TRUE];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please Select"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *buttonPhoto = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            //code to run once button is pressed
                                                            
                                                               [self  takePhoto];
                                                            
                                                        }];
    UIAlertAction *buttonLibrary = [UIAlertAction actionWithTitle:@"Choose from library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
         [self chooseFromLibrary];
        //code to run once button is pressed
    }];
    
    UIAlertAction *buttoncancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:buttonLibrary];
    [alert addAction:buttonPhoto];
    [alert addAction:buttoncancel];
    [self presentViewController:alert animated:YES completion:nil];
    
    // Take a photo/video or choose from gallery
}


-(IBAction)actionTakePhoto:(id)sender
{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please Select"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *buttonPhoto = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                //code to run once button is pressed
                                                                
                                                                [self  takePhoto];
                                                                
                                                            }];
        UIAlertAction *buttonLibrary = [UIAlertAction actionWithTitle:@"Choose from library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self chooseFromLibrary];
            //code to run once button is pressed
        }];
        
        
        
        UIAlertAction *buttoncancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
        }];
        
        [alert addAction:buttonLibrary];
        [alert addAction:buttonPhoto];
        [alert addAction:buttoncancel];
        [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark OpenCamera

- (void)takePhoto
{
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Device has no camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
}

#pragma mark open Gallery
-(void)chooseFromLibrary
{
    [[[UIApplication sharedApplication]keyWindow]endEditing:YES];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark imagePickerDelegates

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    UIImage *chosenImage = [editingInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        if ( [myTimer isValid])
        {
            [myTimer invalidate];
        }
        
        //Set Frame of the Image
//        UIGraphicsBeginImageContext(CGSizeMake(480,320));
//        UIGraphicsGetCurrentContext();
//        [[editingInfo objectForKey:@"UIImagePickerControllerOriginalImage"] drawInRect: CGRectMake(0, 0, 480, 320)];
//        UIImage  *smallImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
        NSData* pictureData =UIImageJPEGRepresentation(chosenImage,0);
        
        [[NSUserDefaults standardUserDefaults]setObject:pictureData forKey:@"imagedata1"];
        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        
            Message *msg=[[Message alloc]init];
            msg.type=SOMessageTypePhoto;
        
            msg.media=pictureData;
            msg.fromMe=YES;
//
            msg.textID=@"i";
           
           [self sendMessage:msg];
        
        
        

      //  [self loadingPanelStart];
////        
//        NSString *strImage=[self imageToNSString:chosenImage];
//        
//        strImage = [strImage stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
//        BOOL isNetworkAvailable = (BOOL)[appdelegate toCheckNetworkStatus];
//        
//        if(isNetworkAvailable == YES)
//        {
//           [self performSelectorInBackground:@selector(callWebServiceToSendMessageWothPictureCustom:) withObject:strImage];
//        
//        }
//        else
//        {
//            
//            [self loadingPanelStop];
//        }
        
        
        /// [self performSelectorInBackground:@selector(callWebServiceToSendMessageWothPictureCustom) withObject:nil];
       }];
}
#pragma mark imagePickerCancel delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (![myTimer isValid]) {
//            BOOL isNetworkAvailable = (BOOL)[appdelegate toCheckNetworkStatus];
//            
//            if(isNetworkAvailable == YES)
//            {
//               
//            }
//            else
//            {
//               
//                [self loadingPanelStop];
//            }
            
            myTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target: self selector: @selector(asynccallAfterFiveSecond) userInfo: nil repeats: YES];
          
        }
        
    }];

}

#pragma mark convert image to string

- (NSString *)imageToNSString:(UIImage *)image
{
    //    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    //
    //    NSString* imgInBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    //
    //    return imgInBase64;
    
    NSData *data = UIImagePNGRepresentation(image);
    return  [data base64EncodedStringWithOptions:kNilOptions];
}


#pragma mark - Conversations-API Method
-(void)conversations_API
{
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/message/conversations"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    //messageid
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"messageid\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[msgId dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    
    //returnd data response from the server
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error;
    NSString *jsonString = [[NSString alloc] initWithData:returnData encoding:NSStringEncodingConversionAllowLossy];
    NSLog(@"jsonString = %@", jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
  //  NSLog(@"Conversation----- = %@", json);
    
    if(json.count == 0)
    {
//       // [self callConversationMethod];
//         [self stopHud];
//        UIAlertController * alert = [UIAlertController
//                                     alertControllerWithTitle:@""
//                                     message:@"No data available! Please Try Again"
//                                     preferredStyle:UIAlertControllerStyleAlert];
//        
//        //Add Buttons
//        
//        UIAlertAction* yesButton = [UIAlertAction
//                                    actionWithTitle:@"Retry"
//                                    style:UIAlertActionStyleDefault
//                                    handler:^(UIAlertAction * action) {
//                                        //Handle your yes please button action here
//                                        [self callConversationMethod];
//                                    }];
//        
//        UIAlertAction* noButton = [UIAlertAction
//                                   actionWithTitle:@"Cancel"
//                                   style:UIAlertActionStyleDefault
//                                   handler:^(UIAlertAction * action)
//                                   {
//                                       //Handle no, thanks button
//                                       [self dismissViewControllerAnimated:YES completion:nil];
//                                      
//                                   }];
//        
//        //Add your buttons to alert controller        
//        [alert addAction:yesButton];
//        [alert addAction:noButton];
//        
//        [self presentViewController:alert animated:YES completion:nil];
//        
    }
    else
    {
    
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
         [self stopHud];
        [self showMessage:[json valueForKey:@"message"] withTitle:@""];
    }
    else
    {
        [self stopHud];
        messages = [json valueForKey:@"messages"];
        
        if(tempArray.count == 0)
        {
            [tempArray addObjectsFromArray:messages];
            [self loadMessagesCustom:messages];
            [self viewWillAppear:TRUE];
            [self performSelector:@selector(customScrollToLastRow) withObject:nil afterDelay:3.0];
        }
        else
        {
            if(tempArray.count == messages.count)
            {
                
            }
            else
            {
                if(tempArray.count>0)
                {
                    [tempArray removeAllObjects];
                    [tempArray addObjectsFromArray:messages];
                }
               
                [self loadMessagesCustom:messages];
                [self viewWillAppear:TRUE];
                [self performSelector:@selector(customScrollToLastRow) withObject:nil afterDelay:4.0];
            }
        }
    }
  }
}


#pragma mark customScrollToLastRow
-(void)customScrollToLastRow
{
     [self stopHud];
    NSInteger section = [self numberOfSectionsInTableView:self.tableView] - 1;
    NSInteger row     = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
    
    if (row >= 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark - Stop Hud Method
-(void)stopHud
{
    [hud hide:true];
    [hud removeFromSuperview];
}

#pragma mark callWebServiceToGetMessagesDetails
-(void)callWebServiceToGetMessagesDetails
{
     NSString *post =[NSString stringWithFormat:@"ticketId=%@",@"1"];
    NSLog(@"post Get Messages =====%@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSError *error;

    if (error)
        NSLog(@"Failure to serialize JSON object %@", error);

    
    NSString *urlString =@"https://mazuma.hk/maz/ticketing/userTicketAnswers/4309022f4fa09a0bb15d31f21f32a887/dhimansatish%40hotmail.com";
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPBody:postData];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse*response, NSData* data, NSError *connectionError)
     {
         if (data)
         {
             NSArray* aryReply = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             NSLog(@"arrayReply for get  Messages Detail=====%@",aryReply);
             
             if ([aryReply count]>0)
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                     [self loadingPanelStop];
                                    
                                    int check=(int)[[aryReply valueForKey:@"status"]integerValue];
                                    
                                    if (check==1)
                                    {
                                           NSArray *aryDetail=[aryReply valueForKey:@"msg"];
      
                                            [self loadMessagesCustom:aryDetail];
                                        
                                        
               [self performSelector:@selector(customScrollToLastRow) withObject:nil afterDelay:0.5];
                                        
        myTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target: self selector: @selector(asynccallAfterFiveSecond) userInfo: nil repeats: YES];
                                        
                                    }
                                    else
                                    {
                                        
                                        NSString *strMessage=[aryReply valueForKey:@"message"];
                                        
                                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"C2C" message:strMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [alert show];
                                        
                                    }
                                    
                                });
              }
             
             else
             {
                   [self loadingPanelStop];
             }
             
         }
         
         else
         {
             //   [self loadingPanelStop];
             // Tell user there's no internet or data failed
         }
     }];
    
}

#pragma mark  asynccallAfterFiveSecond

-(void)asynccallAfterFiveSecond
{
    
//    NSString *post =[NSString stringWithFormat:@"user_id=%@&access_token=%@&sender_id=%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"user_id"],[[NSUserDefaults standardUserDefaults]valueForKey:@"access_token"],strPropertyId];
//    
//    NSLog(@"post Get Reply Message =====%@",post);
//    
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    
//    
//    NSError *error;
//    //    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary
//    //                                                       options:0
//    //                                                         error:&error];
//    if (error)
//        NSLog(@"Failure to serialize JSON object %@", error);
//    
//    
//    NSURL *url = [NSURL URLWithString:GetReplYMessage];
//    
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                       timeoutInterval:60.0];
//    
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    
//    [request setHTTPBody:postData];
//    
//    
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:
//     ^(NSURLResponse*response, NSData* data, NSError *connectionError)
//     {
//         if (data)
//         {
//             //                          NSString *strResponse=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//             //
//             //                          NSLog(@"strResponse===%@",strResponse);
//             
//             NSArray* aryReply = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//             
//             NSLog(@"arrayReply for get   Reply Messages Detail=====%@",aryReply);
//             
//             if ([aryReply count]>0)
//             {
//                 
//                 
//                 dispatch_async(dispatch_get_main_queue(), ^
//                {
//                    
//                //    [self loadingPanelStop];
//                    
//                    int check=(int)[[aryReply valueForKey:@"status"]integerValue];
//                    
//                    if (check==1)
//        {
//            
//            
//            
//            
//            NSArray *aryDetail=[aryReply valueForKey:@"details"];
//            if ([aryDetail count]>0)
//            {
//                
//                if ([self.dataSource count]==0) {
//                    
//                    
//                    NSString *strCompare=[[aryDetail objectAtIndex:0]valueForKey:@"msg_id"];
//
//                    
//                    NSString *strMyId=[[NSUserDefaults standardUserDefaults]valueForKey:@"user_id"];
//                    NSString *strId=[[aryDetail valueForKey:@"from_id"]objectAtIndex:0];
//                    
//                    
//                    
//                    //                    if ([strId isEqualToString:strMyId]) {
//                    //
//                    //                         // [strMessageId setString:strCompare];
//                    //
//                    //
//                    //                    }
//                    //                    else{
//                    
//                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                    
//                    
//                    
//                    Message *msg = [[Message alloc] init];
//                    msg.text = [[aryDetail valueForKey:@"message"]objectAtIndex:0];
//                    msg.textID=strCompare;
//                    [strMessageId setString:strCompare];
//                    msg.type = [self messageTypeFromStringCustom:[[aryDetail valueForKey:@"type"]objectAtIndex:0]];
//                    
//                    NSString *finalDate =[[aryDetail valueForKey:@"created_at"]objectAtIndex:0];
//                    NSDate *date = [dateFormatter dateFromString:finalDate];
//                    msg.date = date;
//                    
//                    
//                    
//                    
//                    if (msg.type == SOMessageTypePhoto) {
//                        
//                        msg.imageUrl=[[aryDetail valueForKey:@"message"]objectAtIndex:0];
//                        
//                        
//                        
//                        dispatch_async(dispatch_get_global_queue(0,0), ^{
//                            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[aryDetail valueForKey:@"message"]objectAtIndex:0]]];
//                            NSData *data = [NSData dataWithContentsOfURL:url];
//                            if ( data == nil ){
//                                return ;
//                                
//                            }
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                //   UIImage *Img=[UIImage imageNamed:@"def_profile.png"];
//                                msg.media =data;
//                                
//                                //   message.thumbnail=[UIImage imageWithData:data];
//                                
//                            });
//                        });
//                        
//                    }
//                    
//                    
//                    
//                    //                        if (msg.type == SOMessageTypePhoto) {
//                    //
//                    //                            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[aryDetail valueForKey:@"message"]objectAtIndex:0]]];
//                    //                            NSData *data = [NSData dataWithContentsOfURL:url];
//                    //                            msg.media =data;
//                    //                        }
//                    
//                    
//                    
//                    if ([strId isEqualToString:strMyId]) {
//                        msg.fromMe=TRUE;
//                        [self sendMessage:msg];
//                        
//                    }
//                    else{
//                        msg.fromMe=FALSE;
//                        [self receiveMessage:msg];
//                        
//                    }
//                }
//                else{
//                    Message *messaheCustom=[self.dataSource lastObject];
//                    
//                    
//                    
//                    NSLog(@"ary== last object=%@",messaheCustom.textID);
//                    
//                    [strMessageId setString:messaheCustom.textID];
//                    
//                    NSString *strCompare=[[aryDetail objectAtIndex:0]valueForKey:@"msg_id"];
//                    
//                    if ([strCompare isEqualToString:strMessageId]) {
//                        
//                    }
//                    
//                    else{
//                        
//                        
//                        NSString *strMyId=[[NSUserDefaults standardUserDefaults]valueForKey:@"user_id"];
//                        NSString *strId=[[aryDetail valueForKey:@"from_id"]objectAtIndex:0];
//                        
//                        
//                        
//                        //                    if ([strId isEqualToString:strMyId]) {
//                        //
//                        //                         // [strMessageId setString:strCompare];
//                        //
//                        //
//                        //                    }
//                        //                    else{
//                        
//                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                        
//                        
//                        
//                        Message *msg = [[Message alloc] init];
//                        msg.text = [[aryDetail valueForKey:@"message"]objectAtIndex:0];
//                        msg.textID=strCompare;
//                        [strMessageId setString:strCompare];
//                        msg.type = [self messageTypeFromStringCustom:[[aryDetail valueForKey:@"type"]objectAtIndex:0]];
//                        
//                        NSString *finalDate =[[aryDetail valueForKey:@"created_at"]objectAtIndex:0];
//                        NSDate *date = [dateFormatter dateFromString:finalDate];
//                        msg.date = date;
//                        
//                        
//                        
//                        
//                        if (msg.type == SOMessageTypePhoto) {
//                            
//                            msg.imageUrl=[[aryDetail valueForKey:@"message"]objectAtIndex:0];
//                            
//                            
//                            
//                            dispatch_async(dispatch_get_global_queue(0,0), ^{
//                                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[aryDetail valueForKey:@"message"]objectAtIndex:0]]];
//                                NSData *data = [NSData dataWithContentsOfURL:url];
//                                if ( data == nil ){
//                                    return ;
//                                    
//                                }
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    //   UIImage *Img=[UIImage imageNamed:@"def_profile.png"];
//                                    msg.media =data;
//                                    
//                                    //   message.thumbnail=[UIImage imageWithData:data];
//                                    
//                                });
//                            });
//                            
//                        }
//                        
//                        
//                        
//                        //                        if (msg.type == SOMessageTypePhoto) {
//                        //
//                        //                            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[aryDetail valueForKey:@"message"]objectAtIndex:0]]];
//                        //                            NSData *data = [NSData dataWithContentsOfURL:url];
//                        //                            msg.media =data;
//                        //                        }
//                        
//                        
//                        
//                        if ([strId isEqualToString:strMyId]) {
//                            msg.fromMe=TRUE;
//                            [self sendMessage:msg];
//                            
//                        }
//                        else{
//                            msg.fromMe=FALSE;
//                            [self receiveMessage:msg];
//                            
//                            
//                        }
//                        
//                        // }
//                        
//                    }
//                }
//                
//                
//               
//                
//                
//            }
//            
//    
//                        
//                    }
//                    else
//                    {
//                        
//                    
//                        
//                    }
//                    
//                });
//                 
//             }
//             
//             else{
//                 //  [self loadingPanelStop];
//             }
//             
//         }
//         
//         else
//         {
//             //   [self loadingPanelStop];
//             // Tell user there's no internet or data failed
//         }
//     }];

    
    
}

- (SOMessageType)messageTypeFromStringCustom:(NSString *)string
{
    if ([string isEqualToString:@"text"]) {
        return SOMessageTypeText;
    } else if ([string isEqualToString:@"image"]) {
        return SOMessageTypePhoto;
    } else if ([string isEqualToString:@"video"]) {
        return SOMessageTypeVideo;
    }
    
    return SOMessageTypeOther;
}


#pragma mark  callWebServiceToSendMessage

-(void)callWebServiceToSendMessage:(NSString*)Txt
{
    
    NSString *post =[NSString stringWithFormat:@"ticketId=%@&message=%@&image=%@",@"1",Txt,@""];
    
    NSLog(@"post Send Messages =====%@",post);
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    
    NSError *error;
 
    if (error)
        NSLog(@"Failure to serialize JSON object %@", error);
    

    
    NSString *urlString =@"http://mazuma.hk/maz/ticketing/answerTicket/4309022f4fa09a0bb15d31f21f32a887/dhimansatish%40hotmail.com";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPBody:postData];
    
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse*response, NSData* data, NSError *connectionError)
     {
         if (data)
         {
             //                          NSString *strResponse=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             //
             //                          NSLog(@"strResponse===%@",strResponse);
             
             NSArray* aryReply = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             
             NSLog(@"arrayReply for get  Messages Detail=====%@",aryReply);
             
             if ([aryReply count]>0)
             {
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    
                                //    [self loadingPanelStop];
                                    
                                    int check=(int)[[aryReply valueForKey:@"status"]integerValue];
                                    
                                    if (check==1)
                                    {
                                        
                                        [self loadingPanelStop];
                                        
//                                        BOOL isNetworkAvailable = (BOOL)[appdelegate toCheckNetworkStatus];
//                                        
//                                        if(isNetworkAvailable == YES)
//                                        {
//                                          [self asynccallAfterFiveSecond];
//                                        }
//                                        else
//                                        {
//                                           [self loadingPanelStop];
//                                        }
                                        
                                    }
                                    else
                                    {
                                         [self loadingPanelStop];

                                    }
                                    
                                });
                 
             }
             else{
                 //  [self loadingPanelStop];
             }
             
         }
         
         else
         {
             //   [self loadingPanelStop];
             // Tell user there's no internet or data failed
         }
     }];
    
}

#pragma mark callWebServiceToSendMessageWothPictureCustom

-(void)callWebServiceToSendMessageWothPictureCustom
{
   
//  NSString *post =[NSString stringWithFormat:@"user_id=%@&access_token=%@&sender_id=%@&type=%@&image=%@&image_name=%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"user_id"],[[NSUserDefaults standardUserDefaults]valueForKey:@"access_token"],strPropertyId,@"image",strImageBase64,@"neew.png"];
//    
//    
//    NSLog(@"post Send Picture=== =====%@",post);
//    
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    
//    
//    NSError *error;
//    //    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary
//    //                                                       options:0
//    //                                                         error:&error];
//    if (error)
//        NSLog(@"Failure to serialize JSON object %@", error);
//    
//    
//    NSURL *url = [NSURL URLWithString:SendMessage];
//    
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                       timeoutInterval:60.0];
//    
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    
//    [request setHTTPBody:postData];
//    
//    
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:
//     ^(NSURLResponse*response, NSData* data, NSError *connectionError)
//     {
//         if (data)
//         {
//             //                          NSString *strResponse=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//             //
//             //                          NSLog(@"strResponse===%@",strResponse);
    
   
//    NSArray *postDataArr =[[webServicesSingulton sharedManager] sendChatimage:[[NSUserDefaults standardUserDefaults]objectForKey:@"idTicket"] :@"Issue" :[[NSUserDefaults standardUserDefaults]objectForKey:@"imagedata1"]];
    
//        NSArray *postDataArr =[[webServicesSingulton sharedManager] sendChatimage:@"1" :@"Issue" :@""];
//    //NSLog(@"%@",postDataArr);
//
//    
//             NSLog(@"arrayReply for Send  Picture=====%@",postDataArr);
//             
//             if ([postDataArr count]>0)
//             {
//                 
//                 dispatch_async(dispatch_get_main_queue(), ^
//                                {
//                                    int check = [[[postDataArr objectAtIndex:0] valueForKey:@"status"] intValue];
//                                 
//                                    
//                                    if (check==1)
//                                    {
//                                        [self loadingPanelStop];
//                                        
////                                        if (![myTimer isValid]) {
////                                            
//////                                            BOOL isNetworkAvailable = (BOOL)[appdelegate toCheckNetworkStatus];
//////                                            
//////                                            if(isNetworkAvailable == YES)
//////                                            {
//////                                                myTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target: self selector: @selector(asynccallAfterFiveSecond) userInfo: nil repeats: YES];
//////                                            }
//////                                            else
//////                                            {
//////                                               
//////                                                [self loadingPanelStop];
//////                                            }
////                                           
////                                        }
//                                     
//                                    }
//                                    else
//                                    {
//                                        [self loadingPanelStop];
//
////                                        if (![myTimer isValid]) {
////                                            
////                                            BOOL isNetworkAvailable = (BOOL)[appdelegate toCheckNetworkStatus];
////                                            
////                                            if(isNetworkAvailable == YES)
////                                            {
////                                                 myTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target: self selector: @selector(asynccallAfterFiveSecond) userInfo: nil repeats: YES];
////                                            }
////                                            else
////                                            {
////                                                
////                                                [self loadingPanelStop];
////                                            }
////                                           
////                                        }
////                                        
//                                        
//                                    }
//                                    
//                                });
//                 
//             }
//             
//             else
//             {
//                  [self loadingPanelStop];
//             }
    
//         }
//         
//         else
//         {
//            
//             // Tell user there's no internet or data failed
//         }
//     }];
    
}


#pragma mark - Info Action
- (IBAction)info_Action:(id)sender
{
    
    NSString *contactNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"contactNumber"];
    
    [[NSUserDefaults standardUserDefaults] setObject:contactNumber forKey:@"phoneNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    InputNameViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InputNameViewController"];
    [self.navigationController pushViewController:home animated:YES];

}
@end
