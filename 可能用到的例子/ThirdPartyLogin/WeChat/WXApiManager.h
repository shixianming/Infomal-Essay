//
//  WXApiManager.h
//  
//
//  Created by Chloe Audrey on 2021/5/24.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXApiManager : NSObject
{
    BOOL alreadyRegisterWX;
}
+ (instancetype)shareManager;
- (void)onWXLoginAuthorizedCallback:(const char *)msg;
- (void)registerWXApp;
@end

NS_ASSUME_NONNULL_END
