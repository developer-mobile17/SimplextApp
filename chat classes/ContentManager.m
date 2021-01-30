//
//  ContentManager.m
//  SOSimpleChatDemo
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//

#import "ContentManager.h"
#import "Message.h"
#import "SOMessageType.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"


@implementation ContentManager

+ (ContentManager *)sharedManager
{
    static ContentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (NSArray *)generateConversation
{
    NSMutableArray *result = [NSMutableArray new];
    NSArray *data = [NSArray arrayWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Conversation" ofType:@"plist"]]];
    
    for (NSDictionary *msg in data)
    {
        Message *message = [[Message alloc] init];
        message.fromMe = [msg[@"fromMe"] boolValue];
        message.text = msg[@"message"];
        message.type = [self messageTypeFromString:msg[@"type"]];
        message.date = [NSDate date];
        
        int index = (int)[data indexOfObject:msg];
        if (index > 0) {
            Message *prevMesage = result.lastObject;
            message.date = [NSDate dateWithTimeInterval:((index % 2) ? 2 * 24 * 60 * 60 : 120) sinceDate:prevMesage.date];
        }
        
        if (message.type == SOMessageTypePhoto)
        {
            message.media = UIImageJPEGRepresentation([UIImage imageNamed:msg[@"image"]], 1);
        } else if (message.type == SOMessageTypeVideo)
        {
            message.media = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:msg[@"video"] ofType:@"mp4"]];
            message.thumbnail = [UIImage imageNamed:msg[@"thumbnail"]];
        }
        [result addObject:message];
    }
    return result;
}


#pragma "RepalceSpecialCharwithString"
-(NSString*)replaceSpecialStringFromChar:(NSString*)str
{
    
//    str = [str stringByReplacingOccurrencesOfString:@"%21" withString:@"!"];
//    str = [str stringByReplacingOccurrencesOfString:@"%2A" withString:@"*"];
//    str = [str stringByReplacingOccurrencesOfString:@"%27" withString:@"'"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"%28" withString:@"("];
//    str = [str stringByReplacingOccurrencesOfString:@"%29" withString:@")"];
//    str = [str stringByReplacingOccurrencesOfString:@"%3B" withString:@";"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
//    str = [str stringByReplacingOccurrencesOfString:@"ileje" withString:@"@"];
//    str = [str stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
//    str = [str stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
//    str = [str stringByReplacingOccurrencesOfString:@"%24" withString:@"$"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
//    str = [str stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
//    str = [str stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"];
//    
//    str = [str stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
//    str = [str stringByReplacingOccurrencesOfString:@"%5B" withString:@"["];
//    str = [str stringByReplacingOccurrencesOfString:@"%5D" withString:@"]"];
//    str = [str stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    
    return str;
}


- (NSArray *)generateConversationNew:(NSArray*)aryNew
{
    NSMutableArray *result = [NSMutableArray new];
    NSArray *data = aryNew;
    for (NSDictionary *msg in data)
    {
       // direction
        NSString *strId=msg[@"direction"];
        
        Message *message = [[Message alloc] init];
        if ([strId isEqualToString:@"S"])
        {//Sent
            message.fromMe=TRUE;
        }
        else
        {
            //Recieved
            message.fromMe=FALSE;
        }
        
        NSString *body =  msg[@"body"];
        NSString *img =  msg[@"image"];
        
        if( body.length > 0)
        {
            // ****Emoji decode
//            body = [body stringByReplacingOccurrencesOfString:@"@@@" withString:@"\\"];
//            const char *jsonString = [body UTF8String];
//            NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
//            body = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
//            body = [body stringByReplacingOccurrencesOfString:@"@40" withString:@""];
//            
//            // ****Emoji decode
//            body = [body stringByReplacingOccurrencesOfString:@"@@" withString:@"%"];
//            body =  [self replaceSpecialStringFromChar:body];
//            // message.text = msg[@"body"];
            
            message.text = body;
             message.type = [self messageTypeFromStringCustom:@"text"];
           // NSLog(@"BOdy Here");
        }
        
        if( img.length > 0)
        {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",msg[@"image"]]];
                NSData *data = [NSData dataWithContentsOfURL:url];
                if ( data == nil )
                {
                    return;
                    
                }
              //  dispatch_async(dispatch_get_main_queue(), ^{
                    // UIImage *Img=[UIImage imageNamed:@"def_profile.png"];
                    message.media =data;
                  message.type = [self messageTypeFromStringCustom:@"image"];
                    message.thumbnail=[UIImage imageWithData:data];
                
//

//                SDWebImageManager *manager = [SDWebImageManager sharedManager];
//                [manager loadImageWithURL:url options:SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL)
//                {
//                    
//                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL)
//                 {
//                    
//                   message.thumbnail = image;
//                    
//                }];
                
                
               // });
            });
           
           // NSLog(@"image Here");
        }
        
       // message.textID=msg[@"msg_id"];
        //message.type=SOMessageTypeText;
        //message.type = [self messageTypeFromStringCustom:msg[@"type"]];
        
       // message.type = [self messageTypeFromStringCustom:@"text"];
        NSString *finalDate = msg[@"time"];
       
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSDate *date = [dateFormatter dateFromString:finalDate];
       // NSLog(@"Date %@", date);
        
        // Write the date back out using the same format
      //  NSLog(@"Month %@",[dateFormatter stringFromDate:date]);
       message.date = date;
       
        if (message.type == SOMessageTypePhoto)
        {
            message.imageUrl=msg[@"image"];
            
//            dispatch_async(dispatch_get_global_queue(0,0), ^{
//                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",msg[@"image"]]];
//                NSData *data = [NSData dataWithContentsOfURL:url];
//                if ( data == nil )
//                {
//                    return ;
//                    
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                   // UIImage *Img=[UIImage imageNamed:@"def_profile.png"];
//                    message.media =data;
//                    
//                    message.thumbnail=[UIImage imageWithData:data];
//
//                });
//            });
          
        } else if (message.type == SOMessageTypeVideo)
        {
            message.media = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:msg[@"video"] ofType:@"mp4"]];
            message.thumbnail = [UIImage imageNamed:msg[@"thumbnail"]];
        }
        [result addObject:message];
    }
    return result;
}

- (SOMessageType)messageTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"SOMessageTypeText"])
    {
        return SOMessageTypeText;
    } else if ([string isEqualToString:@"SOMessageTypePhoto"])
    {
        return SOMessageTypePhoto;
    } else if ([string isEqualToString:@"SOMessageTypeVideo"])
    {
        return SOMessageTypeVideo;
    }
    return SOMessageTypeOther;
}

- (SOMessageType)messageTypeFromStringCustom:(NSString *)string
{
    if ([string isEqualToString:@"text"])
    {
        return SOMessageTypeText;
    } else if ([string isEqualToString:@"image"])
    {
        return SOMessageTypePhoto;
    } else if ([string isEqualToString:@"video"])
    {
        return SOMessageTypeVideo;
    }
    return SOMessageTypeOther;
}

@end
