//
//  TermsCondiotionViewController.m
//  ChatApp
//
//  Created by Bliss Mac on 8/28/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "TermsCondiotionViewController.h"
#import "MBProgressHUD.h"

@interface TermsCondiotionViewController ()<UIWebViewDelegate>

- (IBAction)BackBut:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *TermsWebView;

@end

@implementation TermsCondiotionViewController
{
    MBProgressHUD *hud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hud = [[MBProgressHUD alloc]init];
    hud.labelFont = [UIFont systemFontOfSize:10];
    hud.labelText = @"Loading...";
    [hud show:YES];
    [self.view addSubview:hud];
    
    NSString *urlAddress = @"https://www.simplextdigital.com/pages/terms.html";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.TermsWebView loadRequest:requestObj];

    // Do any additional setup after loading the view.
}

#pragma Mark: UIWebView Delegate Method 

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [hud hide:true];
    [hud removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)BackBut:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
