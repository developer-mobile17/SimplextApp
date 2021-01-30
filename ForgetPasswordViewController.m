//
//  ForgetPasswordViewController.m
//  ChatApp
//
//  Created by macserver on 3/21/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface ForgetPasswordViewController ()
{
    MBProgressHUD *hud;
}


@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    
    NSAttributedString * Email = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
     self.emailTxt_outlet.attributedPlaceholder = Email;
     

    self.emailTxt_outlet.layer.borderWidth=1;
    self.emailTxt_outlet.layer.borderColor =[[UIColor whiteColor] CGColor];
    self.emailTxt_outlet.clipsToBounds=YES;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Back Action Method
- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Send Action Method
- (IBAction)send_Action:(id)sender
{
    if ([self.emailTxt_outlet.text length]== 0)
    {
        [self showMessage:@"Please Enter Email id"
                withTitle:@""];
    }
    if (![self validateEmail:self.emailTxt_outlet.text])
    {
        [self showMessage:@"Please Enter Valid Email id"
                withTitle:@""];
    }
    else
    {
        //  Call Forget Webservice
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
            [self forgetPassword_API];
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


#pragma mark - Forget Password Method
-(void)forgetPassword_API
{
    NSString *email = self.emailTxt_outlet.text;
    
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/user/resetpassword"];
    
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
    NSLog(@"ForgetPassword----- = %@", json);
    
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
        [self showMessage:[json valueForKey:@"message"] withTitle:@""];
    }
    else
    {
        [self stopHud];
//        
//        TextMessageViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"TextMessageViewController"];
//        [self.navigationController pushViewController:home animated:YES];
        
        [self showMessage:@"Sucessfully Send" withTitle:@""];
    }
}


#pragma mark - Stop Hud Method
-(void)stopHud
{
    [hud hide:true];
    [hud removeFromSuperview];
}


@end
