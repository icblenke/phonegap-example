#import "PushNotification.h"


@implementation PushNotification

@synthesize notificationMessage;
@synthesize registerSuccessCallback;
@synthesize registerErrorCallback;

- (void)dealloc {
    [notificationMessage release];
    [registerSuccessCallback release];
    [registerErrorCallback release];
    [super dealloc];
}

- (void)registerAPN:(NSMutableArray *)arguments 
           withDict:(NSMutableDictionary *)options {
    NSLog(@"registerAPN:%@\nwithDict:%@", arguments, options);
    
    NSUInteger argc = [arguments count];
    if (argc > 0 && [[arguments objectAtIndex:0] length] > 0)
        self.registerSuccessCallback = [arguments objectAtIndex:0];
    if (argc > 1 && [[arguments objectAtIndex:1] length] > 0)
        self.registerErrorCallback = [arguments objectAtIndex:1];
    
    UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeNone;
    if ([options objectForKey:@"badge"]) {
        notificationTypes |= UIRemoteNotificationTypeBadge;
    }
    if ([options objectForKey:@"sound"]) {
        notificationTypes |= UIRemoteNotificationTypeSound;
    }
    if ([options objectForKey:@"alert"]) {
        notificationTypes |= UIRemoteNotificationTypeAlert;
    }
    
    if (notificationTypes == UIRemoteNotificationTypeNone)
        NSLog(@"PushNotification.registerAPN: Push notification type is set to none");

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
}

- (void)startNotify:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSLog(@"startNotify:%@\nwithDict:%@", arguments, options);

    ready = YES;
    // Check if there is cached notification before JS PushNotification messageCallback is set
    if (notificationMessage) {
        [self notificationReceived];
    }
}

- (void)isEnabled:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    NSString *jsStatement = [NSString stringWithFormat:@"navigator.pushNotification.isEnabled = %d;", type != UIRemoteNotificationTypeNone];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                        stringByReplacingOccurrencesOfString:@">" withString:@""] 
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%@", token);
    
    if (registerSuccessCallback) {
        NSString *jsStatement = [NSString stringWithFormat:@"%@({deviceToken:'%@'});",
                                 registerSuccessCallback, token];
        [super writeJavascript:jsStatement];
    }
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@", error);

    if (registerErrorCallback) {
        NSString *jsStatement = [NSString stringWithFormat:@"%@({error:'%@'});",
                                 registerErrorCallback, error];
        [super writeJavascript:jsStatement];
    }
}

- (void)setNotificationMessage:(NSDictionary *)notification {
    NSLog(@"setNotificationMessage:%@", notification);
    
    [notification retain];
    [notificationMessage release];
    notificationMessage = notification;
    
    if (notificationMessage) {
        [self notificationReceived];
    }
}

- (void)notificationReceived {
    if (ready) {
        NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
        if ([notificationMessage objectForKey:@"alert"]) {
            [jsonStr appendFormat:@"alert:'%@',", [notificationMessage objectForKey:@"alert"]];
        }
        if ([notificationMessage objectForKey:@"badge"]) {
            [jsonStr appendFormat:@"badge:%d,", [[notificationMessage objectForKey:@"badge"] intValue]];
        }
        if ([notificationMessage objectForKey:@"sound"]) {
            [jsonStr appendFormat:@"sound:'%@',", [notificationMessage objectForKey:@"sound"]];
        }
        [jsonStr appendString:@"}"];
        
        NSString *jsStatement = [NSString stringWithFormat:@"navigator.pushNotification.notificationCallback(%@);", jsonStr];
        [super writeJavascript:jsStatement];
        NSLog(@"run JS: %@", jsStatement);
        self.notificationMessage = nil;
    }
}

@end
