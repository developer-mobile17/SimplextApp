//
//  LoginViewController.m
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved.
//com.simplextdigital.iosapp

#import "LoginViewController.h"
#import "TextMessageViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "ForgetPasswordViewController.h"
#import "ChangePasswordViewController.h"
#import "TermsCondiotionViewController.h"
#import "MainTabVC.h"
#import "Type4VC.h"
#import "IQKeyboardManager.h"

@interface LoginViewController ()
{
    MBProgressHUD *hud;
}

@end

@implementation LoginViewController

- (void)viewDidLoad
{
     [super viewDidLoad];
    
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    
    NSAttributedString * Email = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.txfEmail.attributedPlaceholder = Email;
    
    NSAttributedString * Password = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
       self.txfPassword.attributedPlaceholder = Password;
    
    
    
    self.txfEmail.layer.borderWidth=1;
    self.txfEmail.layer.borderColor =[[UIColor whiteColor] CGColor];
    self.txfEmail.clipsToBounds=YES;
    
    self.txfPassword.layer.borderWidth=1;
    self.txfPassword.layer.borderColor =[[UIColor whiteColor] CGColor];
    self.txfPassword.clipsToBounds=YES;
    
    
    //Check if user Id exist
     
    NSString *uid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
//    if([uid isEqualToString:@""] || [uid isEqualToString:@"null"] || [uid isEqualToString:@"<nil>"] || [uid isKindOfClass:[NSNull class]])
    
    if(uid.length == 0)
    {
        
    }
    else
    {
        MainTabVC *home = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabVC"];
        [self.navigationController pushViewController:home animated:YES];
        
        
    }
}
- (IBAction)TermsConditionBut:(id)sender
{
    TermsCondiotionViewController *TermsCondiotionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsCondiotionViewController"];
    [self.navigationController pushViewController:TermsCondiotionViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

#pragma mark - UITextFiled Delegates 
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextView Method
-(IBAction)dismissKeyboardOnTap:(id)sender
{
    [[self view] endEditing:YES];
    [self animateTextField:self.txfPassword up:YES];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -100; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:self.txfPassword up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:self.txfPassword up:NO];
}

#pragma mark - Login Method
- (IBAction)actionLogin:(id)sender
{
        if ([self.txfEmail.text length]== 0)
        {
            [self showMessage:@"Please Enter Email id"
                    withTitle:@""];
        }
    if (![self validateEmail:self.txfEmail.text])
    {
        [self showMessage:@"Please Enter Valid Email id"
                withTitle:@""];
    }
        else if ([self.txfPassword.text length]== 0)
        {
            [self showMessage:@"Please Enter Password"
                    withTitle:@""];
        }
        else
        {
            //  Call Login Webservice
            if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
            {
                //connection unavailable
                [self showMessage:@"No Internet Connection"
                        withTitle:@""];
            }
            else
            {
                //connection available
                NSString *fcmToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"fcmToken"];
                NSLog(@"Login FCM %@", fcmToken);
                if(fcmToken.length == 0)
                {
                    [self showMessage:@"Please wait while token is registering."
                            withTitle:@"Registering Token"];
                }
                else
                {
                    hud = [[MBProgressHUD alloc]init];
                    hud.labelFont = [UIFont systemFontOfSize:10];
                    hud.labelText = @"Loading...";
                    [hud show:YES];
                    [self.view addSubview:hud];
                    
                    [self performSelector:@selector(login_API) withObject:nil afterDelay:0.1];
                    //[self login_API];
                }
            }
        }
    
//    MainTabVC *home = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabVC"];
//   [self.navigationController pushViewController:home animated:YES];
}


#pragma mark - Forget Method
- (IBAction)actionForgotPassword:(id)sender
{    
    ForgetPasswordViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgetPasswordViewController"];
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


#pragma mark - Email check Method
-(BOOL) validateEmail: (NSString *) email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}


#pragma mark - Login-API Method
-(void)login_API
{
    NSString *email = self.txfEmail.text;
    NSString *pass = self.txfPassword.text;
    
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/user/login"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    //email
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[email dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //pwd
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pwd\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[pass dataUsingEncoding:NSUTF8StringEncoding]];
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
         [self stopHud];
         [self showMessage:[json valueForKey:@"message"] withTitle:@""];
    }
    else
    {
        [self stopHud];
        
        [[NSUserDefaults standardUserDefaults] setObject:[json valueForKey:@"id"] forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSelector:@selector(registerFCM_API) withObject:nil afterDelay:1.0];
    
        MainTabVC *home = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabVC"];
        [self.navigationController pushViewController:home animated:YES];
    }
}


#pragma mark - Register FCM Method
-(void)registerFCM_API
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    NSString *fcmToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"fcmToken"];
    NSLog(@"Login FCM %@", fcmToken);
    
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/user/updatefcmtoken"];
    
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
    
    //token
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"token\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[fcmToken dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSLog(@"Fcm Registration ----- = %@", json);
    
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
       // [self stopHud];
        //[self showMessage:@"Invalid Email or Password" withTitle:@""];
    }
    else
    {
         //  [self stopHud];
        NSLog(@"Token registred");
        // [self showMessage:@"Login Sucess" withTitle:@""];
    }
}


#pragma mark - Stop Hud Method
-(void)stopHud
{
    [hud hide:true];
    [hud removeFromSuperview];
}


@end
