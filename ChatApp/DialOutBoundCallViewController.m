//
//  DialOutBoundCallViewController.m
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "DialOutBoundCallViewController.h"
#import "PhoneCallsViewController.h"
#import "TextMessageViewController.h"
#import "PhoneCallsViewController.h"
#import "SettingsViewController.h"
#import "Reachability.h"


@interface DialOutBoundCallViewController ()
{
    NSString *callNumber;
}

@end

@implementation DialOutBoundCallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    
    NSAttributedString * Contact = [[NSAttributedString alloc] initWithString:@"Contact Number" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
       self.contactnumberOutlet.attributedPlaceholder = Contact;
    
  
 
    self.contactnumberOutlet.clipsToBounds=YES;
    
    callNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"callNumber"];
    
    if(![ callNumber isEqualToString:@""])
    {
        //Replace Special charcter
      
         callNumber = [callNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
         callNumber = [callNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
         callNumber = [callNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
         callNumber = [callNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        
         self.contactnumberOutlet.text = callNumber;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFiled Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - back Action
- (IBAction)back_Action:(id)sender
{
    self.contactnumberOutlet.text = @"";
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DialOutBound View Action

- (IBAction)phoneCallTopBar_Action:(id)sender
{
    DialOutBoundCallViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"DialOutBoundCallViewController"];
    [self.navigationController pushViewController:home animated:YES];
}

#pragma mark - Text Message Action
- (IBAction)textMessageController_Action:(id)sender
{
    TextMessageViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"TextMessageViewController"];
    [self.navigationController pushViewController:home animated:YES];
}


#pragma mark - Phone Call Action
- (IBAction)phoneCallController_Action:(id)sender
{
    PhoneCallsViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneCallsViewController"];
    [self.navigationController pushViewController:home animated:YES];
}

#pragma mark - Setting Action
- (IBAction)settingController_Action:(id)sender
{
    SettingsViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:home animated:YES];
}


#pragma mark - DialNow Action
- (IBAction)dialNow_Action:(id)sender
{
    //  Call Dial Webservice
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        [self showMessage:@"No Internet Connection"
                withTitle:@""];
    }
    else
    {
        if(![ callNumber isEqualToString:@""])
        {
            if([ callNumber hasPrefix:@"+1"])
            {
                [self makeNewCallVoice_API];
            }
            else
            {
                //[self showMessage:@"Please enter your country code"
                 //   withTitle:@""];
                //Concatenate +1 to phone number
                callNumber = [callNumber stringByAppendingString:@"+1"];
                [self makeNewCallVoice_API];
                callNumber =@"";
            }
        }
        else  if([ callNumber isEqualToString:@""])
        {
            callNumber = self.contactnumberOutlet.text;
            if(![callNumber isEqualToString:@""])
            {
                if([ callNumber hasPrefix:@"+1"])
                {
                    [self makeNewCallVoice_API];
                }
                else                                                            
                {
                    callNumber = [@"+1" stringByAppendingString:callNumber];
                    [self makeNewCallVoice_API];
                    callNumber =@"";
                }
            }
            else
              {
                   [self showMessage:@"Please enter phone number!"
                            withTitle:@""];
                         callNumber =@"";
            }
        }
    }
}

#pragma mark - makeNewCallVoice_API Method
-(void)makeNewCallVoice_API
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    NSString *phone =self.contactnumberOutlet.text;
    NSString *twinumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"twinNumber"];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/voice/call"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    //userid
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userid\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[userid dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //phone
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"phoneno\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[phone dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //twinumber
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition:   form-data; name=\"twinumber\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[twinumber dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSLog(@"Dial Call Out----- = %@", json);
    
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
        [self showMessage:[json valueForKey:@"message"] withTitle:@"Failed"];
    }
    else
    {
       // [self stopHud];
        
      //  [[NSUserDefaults standardUserDefaults] setObject:[json valueForKey:@"id"] forKey:@"userId"];
      //  [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        TextMessageViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"TextMessageViewController"];
//        [self.navigationController pushViewController:home animated:YES];
        
        // [self showMessage:@"Login Sucess" withTitle:@""];
    }
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


@end
