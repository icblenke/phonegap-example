#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"

@interface PushNotification : PhoneGapCommand {
    NSString *registerSuccessCallback;
    NSString *registerErrorCallback;
    NSDictionary *notificationMessage;
    
    BOOL ready;
}

@property (nonatomic, retain) NSDictionary *notificationMessage;
@property (nonatomic, retain) NSString *registerSuccessCallback;
@property (nonatomic, retain) NSString *registerErrorCallback;

- (void)registerAPN:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)startNotify:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)setNotificationMessage:(NSDictionary *)notification;
- (void)notificationReceived;

@end
