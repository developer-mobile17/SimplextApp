//
//  TextMessageViewController.m
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved. ,
//

#import "TextMessageViewController.h"
#import "TextMessageTableViewCell.h"
#import "PhoneCallsViewController.h"
#import "SettingsViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "Type4VC.h"


@interface TextMessageViewController ()
{
    NSMutableArray  *messageArray,*CopymessageArray,*messageBody,*contact,*friendlyname, *from,*messageId,*image,*readstatus,*time, *twinumberArray, *assignedtwinumberArray, *finalSearchArray,*tempArray;
    MBProgressHUD *hud;
    NSArray *searchResults;
    BOOL bb, newMsgChk,CheckbuttonPress;
    float heighttemp;
    NSString *userid;
    NSString *twinNumber;
    NSString *msg;
    NSString *phoneNo;
    NSString *dateString;
}

@end

@implementation TextMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bb=NO;
    newMsgChk=NO;
    
    if (@available(iOS 13, *))
    {
        _searchBar.searchTextField.textColor=[UIColor blackColor];
    } else {
        // iOS 10 or older code
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"CallGetMessahgeApiBack"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.viewSendMessage_Outlet.hidden=TRUE;
    
    tempArray= [[NSMutableArray alloc]init];
    finalSearchArray= [[NSMutableArray alloc]init];
    searchResults = [[NSArray alloc]init];
    messageArray = [[NSMutableArray alloc] init];
    CopymessageArray= [[NSMutableArray alloc] init];
    contact = [[NSMutableArray alloc] init];
    messageBody = [[NSMutableArray alloc] init];
    from = [[NSMutableArray alloc] init];
    friendlyname = [[NSMutableArray alloc] init];
    messageId = [[NSMutableArray alloc] init];
    readstatus = [[NSMutableArray alloc] init];
    image = [[NSMutableArray alloc] init];
    time = [[NSMutableArray alloc] init];
    twinumberArray = [[NSMutableArray alloc] init];
    assignedtwinumberArray = [[NSMutableArray alloc] init];
    
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
    
    hud = [[MBProgressHUD alloc]init];
    hud.labelFont = [UIFont systemFontOfSize:10];
    hud.labelText = @"Loading...";
    [hud show:YES];

    [self.view addSubview:hud];
    
    //getCurrentdatetime
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *currentDate = [NSDate date];
    dateString = [formatter stringFromDate:currentDate];
    // currenttime
    
    [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"LastDateParameterForNewMsgAPI"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSelector:@selector(textMessageMethod) withObject:nil afterDelay:0.3];
}

-(void)viewDidAppear:(BOOL)animated
{
    CheckbuttonPress = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"inboxMessage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"View Did Appear Called");
    
//   CheckbuttonPress = NO;
//   [self textMessageMethod];
//   [self performSelector:@selector(textMessageMethod) withObject:nil afterDelay:0.3];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CallGetMessahgeApiBack"] isEqualToString:@"YES"])
    {
        [self performSelector:@selector(checknewMessage) withObject:nil afterDelay:0.2];
    }
}

#pragma mark - textMessageMethod
-(void)textMessageMethod
{
    //  Call  Webservice
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        [self showMessage:@"No Internet Connection"
                    withTitle:@""];
    }
    else
    {
      
      //  [self performSelectorInBackground:@selector(inboxTextMessage_API) withObject:nil];
       // [self performSelectorInBackground:@selector(assignTwilliowNumber_Api) withObject:nil];
      
        [self performSelector:@selector(inboxTextMessage_API) withObject:nil afterDelay:0.1];
        [self performSelector:@selector(assignTwilliowNumber_Api) withObject:nil afterDelay:0.2];
    }
      [self performSelector:@selector(checknewMessage) withObject:nil afterDelay:12.0];
}

-(void)checknewMessage
{
    if([[[ NSUserDefaults standardUserDefaults] valueForKey:@"inboxMessage"] isEqualToString:@"NO"])
    {
     
    }
    else
    {
        NSLog(@"Check New Message Called");
        NSString *notifiationBody  = [[NSUserDefaults standardUserDefaults] valueForKey:@"notiBacground"];
       // NSLog(@"Notificationc count %@", notifiationBody);
    
        if ([notifiationBody isEqualToString:@"no"])
        {
            // [self performSelector:@selector(inboxTextMessage_API) withObject:nil afterDelay:0.0];
             [self performSelectorInBackground:@selector(getNewTextMessage_API) withObject:nil];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"notiBacground"];
            [self performSelector:@selector(getNewTextMessage_API) withObject:nil afterDelay:0.0];
        }
          [self performSelector:@selector(checknewMessage) withObject:nil afterDelay:10.0];
      //  [self performSelectorInBackground:@selector(checknewMessage) withObject:nil];
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
        return [messageArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"Cell";
    TextMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (bb==YES)
    {
        NSString *name = [searchResults objectAtIndex:indexPath.row];
        cell.self.contactNumberOutlet.text = name;

        int po= (int)indexPath.row;
        for (int p=po; p<[CopymessageArray count]; p++)
        {
            if ([name isEqualToString:[[CopymessageArray objectAtIndex:p] valueForKey:@"contact"]]  || [name isEqualToString:[[CopymessageArray objectAtIndex:p ] valueForKey:@"from"]])
            {
                 cell.self.messageOutlet.text= [[CopymessageArray objectAtIndex:p] valueForKey:@"body"];
                
                [messageId addObject:[[CopymessageArray objectAtIndex:p] valueForKey:@"id"]];
                if(![[[CopymessageArray objectAtIndex:p] valueForKey:@"contact"] isEqualToString:@""])
                {
                    [contact addObject:[[CopymessageArray objectAtIndex:p] valueForKey:@"contact"]];
                }
                else
                {
                    [contact addObject:[[CopymessageArray objectAtIndex:
                                         p] valueForKey:@"from"]];
                }
                
                [from addObject:[[CopymessageArray objectAtIndex:p] valueForKey:@"fromu"]];
                
                NSLog(@"messageIdCellCell %@", messageId);
                NSLog(@"nameCellCell %@", contact);
                
                NSString *timeDateString  = [[CopymessageArray objectAtIndex:p] valueForKey:@"time"];
                NSArray *timeDate=   [timeDateString componentsSeparatedByString:@" "];
                NSString *timeFormat  =[timeDate objectAtIndex:1];
                NSString *ampm  =[timeDate objectAtIndex:2];
                NSString *finaleTime  = [NSString stringWithFormat:@"%@ %@", timeFormat, ampm];
                
                NSString *readUnreadStatus  =[[CopymessageArray objectAtIndex:indexPath.row] valueForKey:@"readstatus"];
                if([readUnreadStatus isEqualToString:@"U"])
                {
                    cell.self.dotBlueOutlet.hidden= NO;
                    cell.self.dotBlueOutlet.layer.cornerRadius = 4.5;
                    cell.self.dotBlueOutlet.clipsToBounds =YES;
                }
                else
                {
                    cell.self.dotBlueOutlet.hidden= YES;
                }
                
                cell.self.timeOutlet.text= finaleTime;
                cell.self.dateOutlet.text = [timeDate objectAtIndex:0];
                
                [CopymessageArray removeObjectAtIndex:p];
                
                break;
            }
        }
              }
    else
    {
        NSString *name = [[messageArray objectAtIndex:indexPath.row] valueForKey:@"contact"];
        NSString *fromm = [[messageArray objectAtIndex:indexPath.row] valueForKey:@"from"];
        
        if(![ name isEqualToString:@""])
        {
            cell.self.contactNumberOutlet.text = name;
        }
        else if (![fromm isEqualToString:@""])
        {
            cell.self.contactNumberOutlet.text = fromm;
        }
        
        NSString *timeDateString  = [[messageArray objectAtIndex:indexPath.row] valueForKey:@"time"];
        NSArray *timeDate=   [timeDateString componentsSeparatedByString:@" "];
        NSString *timeFormat  =[timeDate objectAtIndex:1];
        NSString *ampm  =[timeDate objectAtIndex:2];
        NSString *finaleTime  = [NSString stringWithFormat:@"%@ %@", timeFormat, ampm];
        
        NSString *readUnreadStatus  =[[messageArray objectAtIndex:indexPath.row] valueForKey:@"readstatus"];
        if([readUnreadStatus isEqualToString:@"U"])
        {
            cell.self.dotBlueOutlet.hidden= NO;
            cell.self.dotBlueOutlet.layer.cornerRadius = 4.5;
            cell.self.dotBlueOutlet.clipsToBounds =YES;
         }
        else
        {
            cell.self.dotBlueOutlet.hidden= YES;
        }
        
        // cell.textLabel.text=@"dd";
        cell.self.lblName.text= [[messageArray objectAtIndex:indexPath.row] valueForKey:@"agent"];
        cell.self.messageOutlet.text= [[messageArray objectAtIndex:indexPath.row] valueForKey:@"body"];
        cell.self.timeOutlet.text= finaleTime;
        cell.self.dateOutlet.text = [timeDate objectAtIndex:0];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected at index %ld", (long)indexPath.row);
    
    if (CheckbuttonPress == NO)
    {
        CheckbuttonPress = YES;
    
     if (bb==YES)
     {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSString *msgId = [messageId objectAtIndex:indexPath.row] ;
        NSString *contactName  = [contact objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:msgId forKey:@"msgId"];
        [[NSUserDefaults standardUserDefaults] setObject:contactName forKey:@"contactName"];
        [[NSUserDefaults standardUserDefaults] setObject:[from objectAtIndex:indexPath.row] forKey:@"contactNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"inboxMessage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        Type4VC *Type4VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Type4VC"];
        [self.navigationController pushViewController:Type4VC animated:YES];
    }
    else
    {
    //messageId        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSString *msgId  = [[messageArray objectAtIndex:indexPath.row] valueForKey:@"id"] ;
        NSString *contactName;
        if(![[[messageArray objectAtIndex:indexPath.row] valueForKey:@"contact"] isEqualToString:@""])
        {
             contactName  = [[messageArray objectAtIndex:indexPath.row] valueForKey:@"contact"] ;
        }
        else
        {
            contactName  = [[messageArray objectAtIndex:indexPath.row] valueForKey:@"from"] ;
        }
     
        [[NSUserDefaults standardUserDefaults] setObject:msgId forKey:@"msgId"];
        [[NSUserDefaults standardUserDefaults] setObject:[[messageArray objectAtIndex:indexPath.row] valueForKey:@"fromu"] forKey:@"contactNumber"];
        [[NSUserDefaults standardUserDefaults] setObject:contactName forKey:@"contactName"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"inboxMessage"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        Type4VC *Type4VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Type4VC"];
        [self.navigationController pushViewController:Type4VC animated:YES];
     }
   }
}
#pragma mark: UISearchBar 
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    if ([searchText length] == 0) {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
    }
    
    //Remove all objects first.
    if([searchResults count]>0)
    {
        [CopymessageArray removeAllObjects];
        [messageId removeAllObjects];
        [contact removeAllObjects];
        [from removeAllObjects];
        searchResults=nil;
    }
    if ([searchText isEqualToString:@""])
    {
        bb=NO;
        [CopymessageArray removeAllObjects];
        [messageId removeAllObjects];
        [contact removeAllObjects];
        [from removeAllObjects];
        [self.tableView reloadData];
    }
    
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([searchText rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        if (![searchText isEqualToString:@""])
        {
            bb=YES;
           
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", searchText];
           
            searchResults = [[messageArray valueForKey:@"from"] filteredArrayUsingPredicate:predicate];
 
        }
        if (CopymessageArray.count ==0)
        {
            [CopymessageArray addObjectsFromArray:messageArray];
        }
        
    }
    else
    {
        if (![searchText isEqualToString:@""])
        {
            bb=YES;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", searchText];
            searchResults = [[messageArray valueForKey:@"contact"] filteredArrayUsingPredicate:predicate];
        }
        if (CopymessageArray.count ==0)
        {
            [CopymessageArray addObjectsFromArray:messageArray];
        }
    }
         [self.tableView reloadData];
}
- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
#pragma mark: UISearchBar Cancel Button 
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar resignFirstResponder];
    // Do the search...
}
#pragma mark - Send New Message View Action
- (IBAction)sendNewMessage_Action:(id)sender
{
    self.viewSendMessage_Outlet.layer.cornerRadius =4;
    self.viewSendMessage_Outlet.clipsToBounds= YES;
    
    self.viewSendMessage_Outlet.hidden=FALSE;
    self.txtNewMessage_outlet.text = @"";
    self.phoneNoNewMessage_outlet.text = @"";

}

#pragma mark - inboxTextMessage_API Method
-(void)inboxTextMessage_API
{
    NSString *useridd = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/message/inbox"];
  
    
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
    [body appendData:[useridd dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    
    [request setHTTPBody:body];
    
    //returnd data response from the server
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error;
    NSString *jsonString = [[NSString alloc] initWithData:returnData encoding:NSStringEncodingConversionAllowLossy];
 // NSLog(@"jsonString = %@", jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
  //NSLog(@"inboxTextMessage_API----- = %@", json);
    if(json.count == 0)
      {
        //Call webService
        //[self textMessageMethod];
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
            messageArray = [json valueForKey:@"messages"];
            
            if(tempArray.count == 0)
            {
                [tempArray addObjectsFromArray:messageArray];
                dateString=[[tempArray objectAtIndex:0] valueForKey:@"timeo"];
                
                [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"LastDateParameterForNewMsgAPI"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.tableView reloadData];
            }
            else
            {
//                if(tempArray.count == messageArray.count)
//                {
//                    
//                }
//                else
//                {
                    [tempArray removeAllObjects];
                    [tempArray addObjectsFromArray:messageArray];
                    [self.tableView reloadData];
              
               // }
            }
        }
    }
}

#pragma mark - assignTwilliowNumber_Api-API Method
-(void)assignTwilliowNumber_Api
{
     NSString *useridd = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/user/assignednumbers"];
    
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
    [body appendData:[useridd dataUsingEncoding:NSUTF8StringEncoding]];
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
    NSLog(@"Twilliowassignednumbers----- = %@", json);
    
    NSString *status = [json valueForKey:@"status"];
    if([status isEqualToString:@"failed" ])
    {
        [self stopHud];
       // [self showMessage:@"Invalid Email or Password" withTitle:@""];
    }
    else
    {
        [self stopHud];
        //Store Twin Number
        assignedtwinumberArray = [json valueForKey:@"numbers"];
        if(assignedtwinumberArray.count>0)
        {
            NSString *twinNumberr  = [[assignedtwinumberArray objectAtIndex:0] valueForKey:@"number"];
        
            [[NSUserDefaults standardUserDefaults] setObject:twinNumberr forKey:@"twinNumber"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            //[self assignTwilliowNumber_Api];
        }
        // [self showMessage:@"Login Sucess" withTitle:@""];
    }
}
-(void)getNewTextMessage_API
{
    NSString *useridd = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
     //NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/message/inbox"];
    NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/inbox/inbox"];
    
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
    [body appendData:[useridd dataUsingEncoding:NSUTF8StringEncoding]];
   // [body appendData:[@"11" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
///    //getCurrentdatetime
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//    NSDate *currentDate = [NSDate date];
//    NSString *dateString = [formatter stringFromDate:currentDate];
//    // currenttime
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"time\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"LastDateParameterForNewMsgAPI"] dataUsingEncoding:NSUTF8StringEncoding]];
   //  [body appendData:[@"2019-02-10 21:00:00" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    
    //returnd data response from the server
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error;
    NSString *jsonString = [[NSString alloc] initWithData:returnData encoding:NSStringEncodingConversionAllowLossy];
   // NSLog(@"jsonString = %@", jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
 //   NSLog(@"NewMessage_API----- = %@", json);
    if(json.count == 0)
    {
        //Call webService
        //[self textMessageMethod];
    }
    else
    {
        NSString *status = [json valueForKey:@"status"];
       
        if([status isEqualToString:@"failed" ])
        {
         // [self stopHud];
            [self showMessage:[json valueForKey:@"message"] withTitle:@""];
        }
        else
        {
           //[self stopHud];
           //NSString *count = [NSString stringWithFormat:@"%@",[json valueForKey:@"status"]];
            
            //forlastmesgtimedateUpdate
            if ([[json valueForKey:@"lmessagetime"] isEqualToString:@""])
            {
                [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"LastDateParameterForNewMsgAPI"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:[json valueForKey:@"lmessagetime"] forKey:@"LastDateParameterForNewMsgAPI"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            //forlastmesgtimedateUpdate
            messageArray = [json valueForKey:@"messages"];

            if(messageArray.count == 0)
            {
                [messageArray addObjectsFromArray:tempArray];
               // [self.tableView reloadData];
             }
            else
            {
                // change value in dict in array just for testing
//                for (int test=0; test<messageArray.count; test++)
//                {
//                    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
//                    NSDictionary *oldDict = (NSDictionary *)[messageArray objectAtIndex:test];
//                    [newDict addEntriesFromDictionary:oldDict];
//                    [newDict setObject:@"U" forKey:@"readstatus"];
//                    [messageArray replaceObjectAtIndex:test withObject:newDict];
//
//                }
                 NSLog(@"%lu",(unsigned long)tempArray.count);
                for (int i=0; i<messageArray.count; i++)
                {
                    NSString*strr = [[messageArray objectAtIndex:i] valueForKey:@"id"];
                    
                    for (int t=0; t<tempArray.count; t++)
                    {
                         NSString*str = [[tempArray objectAtIndex:t] valueForKey:@"id"];
                        if ([strr isEqualToString:str])
                        {
                            [tempArray removeObjectAtIndex:t];
                        }
                    }
                }
               
                [messageArray addObjectsFromArray:tempArray];
                [tempArray removeAllObjects];
                [tempArray addObjectsFromArray:messageArray];
                NSLog(@"%lu",(unsigned long)tempArray.count);
                
                [self performSelectorOnMainThread:@selector(tbleReloadExist) withObject:nil waitUntilDone:YES];

            }
        }
    }
}
-(void)tbleReloadExist
{
    [self.tableView reloadData];
}
#pragma mark - sendNewMessage_Api
-(void)sendNewMessage_Api
{
    userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    twinNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"twinNumber"];
    msg  = self.txtNewMessage_outlet.text;
    phoneNo  = self.phoneNoNewMessage_outlet.text;
    
    if([phoneNo isEqualToString:@""])
    {
        [self stopHud];
        [self showMessage:@"Please enter phone number!"
                withTitle:@""];
    }
    else if([msg isEqualToString:@""])
    {
        [self stopHud];
        [self showMessage:@"Please enter message!"
                withTitle:@""];
    }
    else
    {
        if([ phoneNo hasPrefix:@"+1"])
        {
            [self sendNewMessageApi];
        }
        else
        {
            phoneNo = [@"+1" stringByAppendingString:phoneNo];
           [self sendNewMessageApi];
            phoneNo =@"";
        }
    }    
}

-(void)sendNewMessageApi
{
        NSString *urlString =[NSString stringWithFormat:@"%@",@"https://www.simplextdigital.com/app/api/message/send"];
        
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
        
        //twinumber
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"twinumber\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[twinNumber dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        //phoneno
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"phoneno\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[phoneNo dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
        //message
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        //vfile
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"vfile\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        
        //returnd data response from the server
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSError *error;
        NSString *jsonString = [[NSString alloc] initWithData:returnData encoding:NSStringEncodingConversionAllowLossy];
     // NSLog(@"jsonString = %@", jsonString);
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
   //   NSLog(@"sendMessage----- = %@", json);
        
        NSString *status = [json valueForKey:@"status"];
        if([status isEqualToString:@"failed" ])
        {
            [self stopHud];
            [self showMessage:[json valueForKey:@"message"] withTitle:@""];
        }
        else
        {
            [self stopHud];
            self.txtNewMessage_outlet.text = @"";
            self.phoneNoNewMessage_outlet.text = @"";
            self.viewSendMessage_Outlet.hidden=TRUE;
            
            // [self shodfwMessage:@"Login Sucess" withTitle:@""];
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

#pragma mark - Stop Hud Method
-(void)stopHud
{
    [hud hide:true];
    [hud removeFromSuperview];
}

#pragma mark - New Message View -- Send Action
- (IBAction)sendMessage_Action:(id)sender
{
    NSString *msg  = self.txtNewMessage_outlet.text;
    //  Call  Webservice
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
        [self performSelector:@selector(sendNewMessage_Api) withObject:nil afterDelay:0.1];
    }
}
#pragma mark - New Message View -- Media Action
- (IBAction)media_Action:(id)sender
{
}

#pragma mark - Close dialouge Action
- (IBAction)closeDialouge_Action:(id)sender
{
     self.viewSendMessage_Outlet.hidden=TRUE;
    [self.view endEditing:TRUE];
}

#pragma mark - UITextFiled Delegates
-(BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextView Delegates
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

@end
