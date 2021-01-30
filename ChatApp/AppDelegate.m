//
//  AppDelegate.m
//  ChatApp
//
//  Created by macserver on 3/7/18.
//  Copyright © 2018 macserver. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import <Firebase.h>

@import UserNotifications;

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

//@import Firebase;


NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    //for notification count setting
           NSLog(@"msg applicationWillEnterForeground");
       #if defined(__IPHONE_10_0) && _IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE_10_0
           [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification * >*  _Nonnull notifications) {
              // NSLog(@"msg getDeliveredNotificationsWithCompletionHandler count %lu", [notifications count]);
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                    application.applicationIconBadgeNumber = [notifications count];
               });
              
       //        for (UNNotification* notification in notifications) {
       //            // do something with object
       //            NSLog(@"msg noti %@", notification.request);
       //        }
               
           }];
           #endif
           //for notification count setting
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"notiBacground"];
    [[NSUserDefaults standardUserDefaults]synchronize];
     //********************** Keyboard Manager ******************************
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:YES];
   
    // Use Firebase library to configure APIs
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
  
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkView"];
    
    if ([UNUserNotificationCenter class] != nil)
    {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             // ...
         }];
    }
    else
    {
//        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
//        UIUserNotificationType allNotificationTypes =
//        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
//        UIUserNotificationSettings *settings =
//        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
//        [application registerUserNotificationSettings:settings];
    }
      [application registerForRemoteNotifications];
    
    
 
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
   // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Print full message.
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Print full message.
    NSLog(@"%@", userInfo);
    NSDictionary *dict = [userInfo valueForKey:@"aps"];
    NSDictionary *alert = [dict valueForKey:@"alert"];
    NSString *body = [alert valueForKey:@"body"];
    [[NSUserDefaults standardUserDefaults] setObject:body forKey:@"notiBacground"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    completionHandler(UIBackgroundFetchResultNewData);
    
    if (application.applicationState == UIApplicationStateActive)
    {
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"checkView"] isEqualToString:@"NO"])
        {
            UIAlertView *alertt  = [[UIAlertView alloc] initWithTitle:[alert valueForKey:@"title"] message:[alert valueForKey:@"body"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertt show];
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"checkView"];
    }
}
// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSDictionary *dict = [userInfo valueForKey:@"aps"];
    NSDictionary *alert = [dict valueForKey:@"alert"];
   
     if([[[NSUserDefaults standardUserDefaults] valueForKey:@"checkView"] isEqualToString:@"NO"])
     {
         UIAlertView *alertt  = [[UIAlertView alloc] initWithTitle:[alert valueForKey:@"title"] message:[alert valueForKey:@"body"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alertt show];
         
     }
    NSLog(@"%@", userInfo);    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler
{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
//    if (userInfo[kGCMMessageIDKey])
//    {
//        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
//    }
    
    NSLog(@"%@", userInfo);
    
    completionHandler();
}

// [END ios_10_message_handling]

// [START refresh_token]

//for notification count setting
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"msg applicationWillEnterForeground");
#if defined(__IPHONE_10_0) && _IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE_10_0
    [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification * >*  _Nonnull notifications) {
      //  NSLog(@"msg getDeliveredNotificationsWithCompletionHandler count %lu", [notifications count]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            application.applicationIconBadgeNumber = [notifications count];
        });
        
//        for (UNNotification* notification in notifications) {
//            // do something with object
//            NSLog(@"msg noti %@", notification.request);
//        }
        
    }];
#endif
}
//for notification count setting

- (void)messaging:(FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken
{
    NSLog(@"FCM registration token: %@", fcmToken);
    [[NSUserDefaults standardUserDefaults] setObject:fcmToken forKey:@"fcmToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken
{
    NSLog(@"FCM registration token: %@", fcmToken);
  
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage
{
    NSLog(@"Received data message: %@", remoteMessage.appData);
}
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeUnknown];
    
    [self connectToFcm];
    NSLog(@"APNs device token retrieved: %@", deviceToken);
      // With swizzling disabled you must set the APNs device token here.
    // [FIRMessaging messaging].APNSToken = deviceToken;
}

- (void)connectToFcm
{
    
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error)
     {
        if (error != nil)
        {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}
@end

