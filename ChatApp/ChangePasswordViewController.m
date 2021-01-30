//
//  ChangePasswordViewController.m
//  ChatApp
//
//  Created by macserver on 3/21/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface ChangePasswordViewController ()
{
    MBProgressHUD *hud;
    NSString *newPassword;
    NSString *confirmPassword;
}
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    
    
    NSAttributedString * Email = [[NSAttributedString alloc] initWithString:@"Current Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.txtCurrentPassword.attributedPlaceholder = Email;
    
    NSAttributedString * Password = [[NSAttributedString alloc] initWithString:@"New Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
       self.txtNewPassword.attributedPlaceholder = Password;
    
    NSAttributedString * ConfirmPassword = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
          self.confirmPassword.attributedPlaceholder = ConfirmPassword;
    
   
    
    self.txtCurrentPassword.layer.borderWidth=1;
    self.txtCurrentPassword.layer.borderColor =[[UIColor whiteColor] CGColor];
    self.txtCurrentPassword.clipsToBounds=YES;
    
    self.txtNewPassword.layer.borderWidth=1;
    self.txtNewPassword.layer.borderColor =[[UIColor whiteColor] CGColor];
    self.txtNewPassword.clipsToBounds=YES;
    
    self.confirmPassword.layer.borderWidth=1;
    self.confirmPassword.layer.borderColor =[[UIColor whiteColor] CGColor];
    self.confirmPassword.clipsToBounds=YES;

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


#pragma mark - Back Method
- (IBAction)back_Action:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Send Method
- (IBAction)send_Action:(id)sender
{
    newPassword = self.txtNewPassword.text;
    confirmPassword = self.confirmPassword.text;

    
    if ([self.txtCurrentPassword.text length]== 0)
    {
        [self showMessage:@"Please Enter Current Password"
                withTitle:@""];
    }
    else if ([self.txtNewPassword.text length]== 0)
    {
        [self showMessage:@"Please Enter New Password"
                withTitle:@""];
    }
    else if ([self.confirmPassword.text length]== 0)
    {
        [self showMessage:@"Please Enter Confirm Password"
                withTitle:@""];
    }
    else if (![confirmPassword isEqualToString:newPassword])
    {
        [self showMessage:@"New and Confirm Password does not match!"
                withTitle:@""];
    }
    else
    {
        //  Call Chagne Password Webservice
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
        {
            //connection unavailable
            [self showMessage:@"No Internet Connection"
                    withTitle:@""];
        }
        else
        {
            //connection available
            hud = [[MBProgressHUD alloc]init];
            hud.labelFont = [UIFont systemFontOfSize:10];
            hud.labelText = @"Loading...";
            [hud show:YES];
            [self.view addSubview:hud];
            [self chagnePassword_API];
        }
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


#pragma mark - Email check Method
-(BOOL) validateEmail: (NSString *) email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}
#pragma mark - Change Password-API Method
-(void)chagnePassword_API
{
    NSString *currentPassword = self.txtCurrentPassword.text;
     newPassword = self.txtNewPassword.text;
    NSString *userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/user/changepasword"];
    
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
    [body appendData:[userid dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //pwd current pasword
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pwd\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[currentPassword dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //pwd new pasword
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"newpwd\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[newPassword dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSLog(@"ChagnePassword APi----- = %@", json);
    
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
        [self stopHud];
        [self showMessage:[json valueForKey:@"message"] withTitle:@""];
    }
    else
    {
        [self stopHud];
        
//        [[NSUserDefaults standardUserDefaults] setObject:[json valueForKey:@"id"] forKey:@"userId"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        TextMessageViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"TextMessageViewController"];
//        [self.navigationController pushViewController:home animated:YES];
        
         [self showMessage:@" Sucessfully Changed" withTitle:@""];
    }
}

#pragma mark - Stop Hud Method
-(void)stopHud
{
    [hud hide:true];
    [hud removeFromSuperview];
}


@end
