//
//  SettingsViewController.m
//  ChatApp
//
//  Created by macserver on 3/8/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "SettingsViewController.h"
#import "TextMessageViewController.h"
#import "PhoneCallsViewController.h"
#import "LoginViewController.h"
#import "ChangePasswordViewController.h"


@interface SettingsViewController ()
{
    NSString *userId,*notiState;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.notificationView.layer.borderWidth = 1;
    self.notificationView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.notificationView.clipsToBounds=YES;
    
    userId =[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    notiState = @"Y";
    [self performSelector:@selector(NotificationSetting_API) withObject:nil afterDelay:0.1];
    
    //Notification Switch
    [self.notiFicationSwitch_outlet addTarget:self
                      action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Switch Method
- (void)stateChanged:(UISwitch *)switchState
{
    if ([switchState isOn])
    {
        notiState = @"Y";
        [self performSelector:@selector(NotificationSetting_API) withObject:nil afterDelay:0.1];
    
        NSLog(@"The Switch is On");
    } else
    {
        notiState = @"N";
         [self performSelector:@selector(NotificationSetting_API) withObject:nil afterDelay:0.1];
        NSLog(@"The Switch is OFF");
    }
}

#pragma mark - Logout-Action
- (IBAction)logOut_Action:(id)sender
{
    [self logOut_API];
}


#pragma mark - Logout-API Method
-(void)logOut_API
{
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/user/logout"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    //id
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[userId dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSLog(@"Login_API----- = %@", json);
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
        [self showMessage:[json valueForKey:@"message"] withTitle:@"Failed"];
    }
    else
    {
//        LoginViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        [self.navigationController pushViewController:home animated:YES];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
       // [self showMessage:@"Logout Succesfully!" withTitle:@""];
    }
}

#pragma mark - Chagne Password Method
- (IBAction)ChangePassword_Action:(id)sender
{
    ChangePasswordViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
    [self.navigationController pushViewController:home animated:YES];
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


#pragma mark - back Action
- (IBAction)back_Action:(id)sender
{
   // [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NotificationSetting_API
-(void)NotificationSetting_API
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/user/updatesettings"];
    
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
    
    
    //Notification State
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"notification\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[notiState dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSLog(@"NotificationSetting_API----- = %@", json);
    
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
        // [self showMessage:@"Invalid Email or Password" withTitle:@""];
    }
    else
    {
       // [self stopHud];
        
        //Store Twin Number
       // assignedtwinumberArray = [json valueForKey:@"numbers"];
//       / if(assignedtwinumberArray.count>0)
//        {
//            NSString *twinNumber  = [[assignedtwinumberArray objectAtIndex:0] valueForKey:@"number"];
//            
//            [[NSUserDefaults standardUserDefaults] setObject:twinNumber forKey:@"twinNumber"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        else
//        {
            //[self assignTwilliowNumber_Api];
        //}
        
        // [self showMessage:@"Login Sucess" withTitle:@""];
    }
}



@end
