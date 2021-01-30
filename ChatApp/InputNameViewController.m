//
//  InputNameViewController.m
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "InputNameViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "TextMessageViewController.h"


@interface InputNameViewController ()
{
    NSString *userid;
    NSString *phone;
    NSString *twinumber;
    MBProgressHUD *hud;
}

@end

@implementation InputNameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    
    NSAttributedString * firstname = [[NSAttributedString alloc] initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
       self.firstName.attributedPlaceholder = firstname;
    
    NSAttributedString * lastName = [[NSAttributedString alloc] initWithString:@"last Name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
          self.lastName.attributedPlaceholder = lastName;
    
    
    
    self.firstName.layer.borderWidth=1;
    self.firstName.layer.borderColor =[[UIColor whiteColor] CGColor];
    self.firstName.clipsToBounds=YES;
    
    self.lastName.layer.borderWidth=1;
    self.lastName.layer.borderColor =[[UIColor whiteColor] CGColor];
    self.lastName.clipsToBounds=YES;
    
    userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    phone =[[NSUserDefaults standardUserDefaults] valueForKey:@"phoneNumber"];
    twinumber =[[NSUserDefaults standardUserDefaults] valueForKey:@"twinNumber"];
    
    
    if(![ phone isEqualToString:@""])
    {
        //Replace Special charcter
        phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
        phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
        
         self.contactNumberOutlet.text = phone;
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


#pragma mark - Save Method
- (IBAction)saveAction:(id)sender
{
    if([self.firstName.text isEqualToString:@""] || [self.lastName.text isEqualToString:@""])
    {
        [self showMessage:@"Enter information..!" withTitle:@""];
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
            hud = [[MBProgressHUD alloc]init];
            hud.labelFont = [UIFont systemFontOfSize:10];
            hud.labelText = @"Loading...";
            [hud show:YES];
            [self.view addSubview:hud];
            [self performSelector:@selector(AddNames_API) withObject:nil afterDelay:0.1];
             //[self AddNames_API];
        }
    }
}


#pragma mark - Back Method
- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Login-API Method
-(void)AddNames_API
{
    NSString *firstName = self.firstName.text;
    NSString *lastName = self.lastName.text;
 
   // twinumber  = [self replaceSpecialCharsFromString : twinumber];
    
    
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/contact/add"];
    
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
    
    //name
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"name\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[firstName dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //lname
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lname\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[lastName dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //phone
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"phone\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[phone dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //twinumber
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"twinumber\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
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
    
    NSLog(@"Add Contact----- = %@", json);
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
         [self stopHud];
        [self showMessage:[json valueForKey:@"message"] withTitle:@""];
    }
    else
    {
        [self stopHud];

        self.firstName.text = @"";
        self.lastName.text = @"";
        
        TextMessageViewController *controller  = [self.storyboard instantiateViewControllerWithIdentifier:@"TextMessageViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        
       //[self showMessage:@"Sucess" withTitle:@""];
    }
}

#pragma mark - Repalce Special Characeter Method
-(NSString*)replaceSpecialCharsFromString:(NSString*)str
{
//    str = [str stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
//    str = [str stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"];
//    str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"(" withString:@"%28"];
//    str = [str stringByReplacingOccurrencesOfString:@")" withString:@"%29"];
//    str = [str stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@":" withString:@":%3A"];
//    str = [str stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
//    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//    str = [str stringByReplacingOccurrencesOfString:@"$" withString:@"%24"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
//    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
//    str = [str stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
//    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@"%5B"];
//    str = [str stringByReplacingOccurrencesOfString:@"]" withString:@"%5D"];
//    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    
    return str;
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

#pragma mark - Stop Hud Method
-(void)stopHud
{
    [hud hide:true];
    [hud removeFromSuperview];
}


@end
