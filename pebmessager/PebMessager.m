//
//  PebMessager.m
//  pebmessager
//
//  Created by Moises Anthony Aranas on 3/16/14.
//  Copyright (c) 2014 moises. All rights reserved.
//

#import "PebMessager.h"
#import <objc/objc-class.h>

@interface NSUserNotificationCenter (PebMessage)
- (void)pebMessage_deliverNotification:(id)arg1;
@end

@implementation NSUserNotificationCenter (PebMessage)
- (void)pebMessage_deliverNotification:(id)arg1 {
    NSUserNotification *userNotification = (NSUserNotification*)arg1;
    NSString *sender = [userNotification.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (!sender) {
        sender = @"PebMessage";
    }
    NSString *body = [userNotification.subtitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (!body) {
        body = [userNotification.informativeText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSString *baseURLString = [NSString stringWithFormat:@"http://localhost:3334/sms/sender/%@/body/%@", sender, body];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:baseURLString]];
    [urlRequest setHTTPMethod:@"GET"];
    NSURLResponse* response = nil;
    NSError* error = nil;
    [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    [self pebMessage_deliverNotification:arg1];
}
@end

@implementation PebMessager

/**
 * A special method called by SIMBL once the application has started and all classes are initialized.
 */
+ (void) load
{
    // ... do whatever
    NSLog(@"Hooking into notifications for the app.");
    Class theClass = NSClassFromString(@"_NSConcreteUserNotificationCenter");
    if (theClass)
    {
        NSLog(@"Trying to inject...");
        SEL origSel = @selector(deliverNotification:);
        SEL overSel = @selector(pebMessage_deliverNotification:);
        
        Method orig = class_getInstanceMethod(theClass, origSel);
        Method over = class_getInstanceMethod(theClass, overSel);
        if (class_addMethod(theClass, origSel, method_getImplementation(over), method_getTypeEncoding(over))) {
            class_replaceMethod(theClass, overSel, method_getImplementation(orig), method_getTypeEncoding(orig));
        } else {
            method_exchangeImplementations(orig, over);
        }
        NSLog(@"Done.");
    }
}

@end
