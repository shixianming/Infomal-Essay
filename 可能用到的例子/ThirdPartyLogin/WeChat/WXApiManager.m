//
//  WXApiManager.m
//  
//
//  Created by Chloe Audrey on 2021/5/24.
//

#import "WXApiManager.h"

@implementation WXApiManager
+ (instancetype) shareManager
{
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

//与Unity交互
- (void)onWXLoginAuthorizedCallback:(const char *)msg
{
    UnitySendMessage("LoginPanelStandalone", "OnWXLoginAuthorizedCallback", msg);
}

//向微信注册
- (void)registerWXApp
{
    if (alreadyRegisterWX == FALSE)
    {
        NSString *appid = @"";
        NSString *universalLink = @"";
        [WXApi registerApp:appid universalLink:universalLink];
        alreadyRegisterWX = TRUE;
    }
}

-(void)onReq:(BaseReq *)req
{
    
}

-(void)onResp:(BaseReq *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        int errCode = authResp.errCode;
        NSString * resultInfo;
        switch (errCode)
        {
            case 0:
                resultInfo = [NSString stringWithFormat:@"code=%@", authResp.code];
                break;
            case -2:
                resultInfo = @"用户取消";
                break;
            case -4:
                resultInfo = @"用户拒绝授权";
                break;
            case -5:
                resultInfo = @"unSupported";
                break;
            default:
                resultInfo = @"unKnown";
                break;
        }
        const char *result = [resultInfo cStringUsingEncoding:NSUTF8StringEncoding];
        [self onWXLoginAuthorizedCallback:result];
    }
}
@end

#if defined(_cplusplus)
extern "C" {
#endif
    void openWXLoginAuthorized(){
//        微信日志
//        [WXApi startLogByLevel:1 logBlock:^(NSString * _Nonnull log) {
//            NSLog(@"log %@",log);
//        }];
//        向微信注册
//        NSString *appid = @"wx3425e85aa5fd8e35";
//        NSString *universalLink = @"https://14nue.share2dlink.com/";
//        [WXApi registerApp:appid universalLink:universalLink];
        [[WXApiManager shareManager] registerWXApp];
        
//        微信自检
//        [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
//            NSLog(@"%@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
//        }];
        
        if ([WXApi isWXAppInstalled] == false) {
            [[WXApiManager shareManager] onWXLoginAuthorizedCallback:"WXAPP is not installed"];
        }
        
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"none";
        [WXApi sendReq:req completion:NULL];
    }
#if defined(_cplusplus)
}
#endif
