//
//  PhoneCallsViewController.m
//  ChatApp
//
//  Created by macserver on 3/8/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "PhoneCallsViewController.h"
#import "PhoneCallsTableViewCell.h"
#import "DialOutBoundCallViewController.h"
#import "TextMessageViewController.h"
#import "PhoneCallsViewController.h"
#import "SettingsViewController.h"
#import "InputNameViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

@interface PhoneCallsViewController ()
{
    MBProgressHUD *hud;
    NSMutableArray  *callArray,*CopymessageArray,*contact,*direction,*duration,*friedndlyname,*callidd,*phoneno,*statuss,*time,*finalSearchArray;
    BOOL bb;
    NSArray *searchResults;
}

@end

@implementation PhoneCallsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     bb=NO;
    
     CopymessageArray= [[NSMutableArray alloc] init];
    finalSearchArray= [[NSMutableArray alloc]init];
    callArray = [[NSMutableArray alloc] init];
    contact = [[NSMutableArray alloc] init];
    direction = [[NSMutableArray alloc] init];
    duration = [[NSMutableArray alloc] init];
    friedndlyname = [[NSMutableArray alloc] init];
    callidd = [[NSMutableArray alloc] init];
    phoneno = [[NSMutableArray alloc] init];
    statuss = [[NSMutableArray alloc] init];
    time = [[NSMutableArray alloc] init];
    //[self phoneCallMethod];
    
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"View Did Appear Called");
    [self phoneCallMethod];
}


#pragma mark - phoneCallMethod 
-(void)phoneCallMethod
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
        hud = [[MBProgressHUD alloc]init];
        hud.labelFont = [UIFont systemFontOfSize:10];
        hud.labelText = @"Loading...";
        [hud show:YES];
        [self.view addSubview:hud];
        [self performSelector:@selector(phoneCallLogs_API) withObject:nil afterDelay:0.1];
        // [self phoneCallLogs_API];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (bb == YES)
    {
        return [searchResults count];
        
    } else
    {
      return [callArray count];    //count number of row from counting array hear cataGorry is An Array
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"Cell";
    PhoneCallsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
   
    if (bb==YES)
    {
        NSString *name = [searchResults objectAtIndex:indexPath.row];
       cell.self.contactNumberOutlet.text = name;
        
        
        int po= (int)indexPath.row;
        
        
        for (int p=po; p<[CopymessageArray count]; p++)
        {
            if ([name isEqualToString:[[CopymessageArray objectAtIndex:p] valueForKey:@"contact"]]  || [name isEqualToString:[[CopymessageArray objectAtIndex:p ] valueForKey:@"phoneno"]])
            {
                cell.self.messageOutlet.text= [[CopymessageArray objectAtIndex:p] valueForKey:@"status"];
                
             
                if(![[[CopymessageArray objectAtIndex:p] valueForKey:@"contact"] isEqualToString:@""])
                {
                    [contact addObject:[[CopymessageArray objectAtIndex:p] valueForKey:@"contact"]];
                }
                else
                {
                    [contact addObject:[[CopymessageArray objectAtIndex:p] valueForKey:@"phoneno"]];
                }
             
                
                NSString *timeDateString  = [[CopymessageArray objectAtIndex:p] valueForKey:@"time"];
                NSArray *timeDate=   [timeDateString componentsSeparatedByString:@" "];
                NSString *timeFormat  =[timeDate objectAtIndex:1];
                NSString *ampm  =[timeDate objectAtIndex:2];
                NSString *finaleTime  = [NSString stringWithFormat:@"%@ %@", timeFormat, ampm];
                
              
                
                cell.self.timeOutlet.text= finaleTime;
                cell.self.dateOutlet.text = [timeDate objectAtIndex:0];
                
                [CopymessageArray removeObjectAtIndex:p];
                
                break;
            }
        }
       
        
  
        
        //Assign Tag Value
        cell.self.info_outlet.tag=indexPath.row;
          cell.self.call_outlet.tag=indexPath.row;
        [cell.self.info_outlet addTarget:self action:@selector(infoAction:)
                        forControlEvents:UIControlEventTouchUpInside];
        
        [cell.self.call_outlet addTarget:self action:@selector(callAction:)
                        forControlEvents:UIControlEventTouchUpInside];

    }
    else
    {
        
        NSString *name = [[callArray objectAtIndex:indexPath.row] valueForKey:@"contact"];
        NSString *phoneNumber = [[callArray objectAtIndex:indexPath.row] valueForKey:@"phoneno"];
        
        if(![ name isEqualToString:@""])
        {
            cell.self.contactNumberOutlet.text = name;
        }
        else if (![phoneNumber isEqualToString:@""])
        {
            cell.self.contactNumberOutlet.text = phoneNumber;
        }
        
        NSString *timeDateString  = [[callArray objectAtIndex:indexPath.row] valueForKey:@"time"];
        NSArray *timeDate=   [timeDateString componentsSeparatedByString:@" "];
        
        if([[[callArray objectAtIndex:indexPath.row] valueForKey:@"status"] isEqualToString:@"Missed"])
        {
            cell.self.messageOutlet.textColor = [UIColor redColor];
            cell.self.messageOutlet.text= [[callArray objectAtIndex:indexPath.row] valueForKey:@"status"];
        }
        else
        {
            cell.self.messageOutlet.text= [[callArray objectAtIndex:indexPath.row] valueForKey:@"status"];
        }
        
        cell.self.dateOutlet.text =[timeDate objectAtIndex:0];
        
        NSString *timeFormat  =[timeDate objectAtIndex:1];
        NSString *ampm  =[timeDate objectAtIndex:2];
        NSString *finaleTime  = [NSString stringWithFormat:@"%@ %@", timeFormat, ampm];
        
        cell.self.timeOutlet.text= finaleTime;
        
        //Assign Tag Value
        cell.self.info_outlet.tag=indexPath.row;
         cell.self.call_outlet.tag=indexPath.row;
        [cell.self.info_outlet addTarget:self action:@selector(infoAction:)
                        forControlEvents:UIControlEventTouchUpInside];
        [cell.self.call_outlet addTarget:self action:@selector(callAction:)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (bb==YES)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
      //  NSString *clientName = [searchResults objectAtIndex:indexPath.row];
        
//        InputNameViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InputNameViewController"];
//        [self.navigationController pushViewController:home animated:YES];
    }
    else
    {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        InputNameViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InputNameViewController"];
//        [self.navigationController pushViewController:home animated:YES];        
    }
}


#pragma mark: UISearchBar 
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    if (@available(iOS 13, *))
    {
        searchBar.searchTextField.textColor=[UIColor blackColor];
    } else {
        // iOS 10 or older code
    }
   
               
    if ([searchText length] == 0) {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
    }
    //Remove all objects first.
    if([searchResults count]>0)
    {
        [CopymessageArray removeAllObjects];
        searchResults=nil;
    }
    if ([searchText isEqualToString:@""])
    {
        bb=NO;
        [CopymessageArray removeAllObjects];
        [self.tableView reloadData];
       
    }
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([searchText rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        if (![searchText isEqualToString:@""])
        {
            bb=YES;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", searchText];
            
            searchResults = [[callArray valueForKey:@"phoneno"] filteredArrayUsingPredicate:predicate];
            
        }
        if (CopymessageArray.count ==0)
        {
            [CopymessageArray addObjectsFromArray:callArray];
        }
    }
    else
    {
        if (![searchText isEqualToString:@""])
        {
            bb=YES;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", searchText];
            searchResults = [[callArray valueForKey:@"contact"] filteredArrayUsingPredicate:predicate];
        }
        
        if (CopymessageArray.count ==0)
        {
            [CopymessageArray addObjectsFromArray:callArray];
        }
    }
    [self.tableView reloadData];
}
- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
#pragma mark - UISearchBar cancel Button
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar resignFirstResponder];
    // Do the search...
}

#pragma mark - info Action
-(void)infoAction:(UIButton*)sender
{
    NSInteger i = [sender tag];
     NSString *phoneNumber = [phoneno objectAtIndex:i];
    
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:@"phoneNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    InputNameViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InputNameViewController"];
    [self.navigationController pushViewController:home animated:YES];
}


#pragma mark - call Action
-(void)callAction:(UIButton*)sender
{
    NSInteger i = [sender tag];
    NSString *phoneNumber = [phoneno objectAtIndex:i];
    
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:@"callNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DialOutBoundCallViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"DialOutBoundCallViewController"];
    [self.navigationController pushViewController:home animated:YES];
}

#pragma mark - back Action
- (IBAction)back_Action:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DialOutBound View Action

- (IBAction)phoneCallTopBar_Action:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"callNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark - phoneCallLogs_API Method
-(void)phoneCallLogs_API
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
  
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/voice/calllog"];
    
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
    NSLog(@"PhoneCall API----- = %@", json);
//    if(json.count == 0)
//    {
//        //Phone Call Method
//        // [self phoneCallMethod];
//    }
//    else
//    {    
        NSString *status = [json valueForKey:@"status"];
        if([status isEqualToString:@"failed" ])
        {
            [self stopHud];
            [self showMessage:[json valueForKey:@"message"] withTitle:@""];
        }
        else
        {
            [self stopHud];
        
            callArray  =[json valueForKey:@"calls"];
            phoneno = [callArray valueForKey:@"phonenou"];
            
            [self.tableView reloadData];
            
           
        
        // [self showMessage:@"Login Sucess" withTitle:@""];
       }
    //}
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
