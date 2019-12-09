//
//  HHYViewController.m
//  JSBridgeLearn
//
//  Created by 1211054926@qq.com on 12/09/2019.
//  Copyright (c) 2019 1211054926@qq.com. All rights reserved.
//

#import "HHYViewController.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

@interface HHYViewController ()<WKUIDelegate>
@property (nonatomic,strong)WebViewJavascriptBridge *bridge;
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation HHYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 2.加载网页
    NSString *indexPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:indexPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [NSURL fileURLWithPath:indexPath];
    [self.webView loadHTMLString:appHtml baseURL:baseUrl];
    self.webView.UIDelegate = self;
    // 3.开启日志
    [WebViewJavascriptBridge enableLogging];

    // 4.给webView建立JS和OC的沟通桥梁
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];

//     JS调用OC的API:访问相册
    __weak typeof(self)wself = self;
    [self.bridge registerHandler:@"openCamera" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"需要%@图片", data[@"count"]);
        
        UIImagePickerController *imageVC = [[UIImagePickerController alloc] init];
        imageVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [wself presentViewController:imageVC animated:YES completion:nil];
        responseCallback(@"欢迎关注hehuoya.com");
    }];
    
    [self.bridge registerHandler:@"showSheet" handler:^(id data, WVJBResponseCallback responseCallback) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"sheet弹窗" message:@"欢迎关注hehuoya.com" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [vc addAction:cancelAction];
        [vc addAction:okAction];
        [wself presentViewController:vc animated:YES completion:nil];
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

/*  获取用户信息  */
- (IBAction)getUserinfo {
    // 调用JS中的API
    [self.bridge callHandler:@"getUserInfo" data:@{@"userId":@"800099"} responseCallback:^(id responseData) {
        NSString *userInfo = [NSString stringWithFormat:@"%@,姓名:%@,年龄:%@", responseData[@"userID"], responseData[@"userName"], responseData[@"age"]];
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"从网页端获取的用户信息" message:userInfo preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [vc addAction:cancelAction];
        [vc addAction:okAction];
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

/* 弹框显示消息 */
- (IBAction)showInfo {
    // 调用JS中的API
//    [self.bridge callHandler:@"alertMessage" data:@"调用了js中的Alert弹窗!" responseCallback:^(id responseData) {
//       
//        
//    }];
    [self.bridge callHandler:@"alertMessage" data:@"调用了js中的Alert弹窗!" responseCallback:^(id responseData) {
        
     }];
}

/* 控制界面动态跳转 */
- (IBAction)pushToNewWebSite {
    // 调用JS中的API
    [self.bridge callHandler:@"pushToNewWebSite" data:@{@"url":@"http://hehuoya.com"} responseCallback:^(id responseData) {
        
    }];
}

/* 刷新界面 */
- (IBAction)reloadWebPage {
    [self.webView reload];
}

/* 插入新图片 */
- (IBAction)insertImgToWebPage {
    
    NSDictionary *dict = @{
                           @"url" : @"https://gss3.bdstatic.com/84oSdTum2Q5BphGlnYG/timg?wapp&quality=80&size=b150_150&subsize=20480&cut_x=0&cut_w=0&cut_y=0&cut_h=0&sec=1369815402&srctrace&di=257008a4c8e854a56271db285e4cb1ef&wh_rate=null&src=http%3A%2F%2Fimgsrc.baidu.com%2Fforum%2Fpic%2Fitem%2F960a304e251f95ca19d446cac6177f3e670952ad.jpg",
                           };
    // 调用JS中的API
    [self.bridge callHandler:@"insertImgToWebPage" data:dict responseCallback:^(id responseData) {
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// WKWebView的javascript alert 不弹的解决方案
//WKUIDelegate支持alert弹出框，confirm选择框，TextInput输入框，如果不实现此代理中相应的方法，直接点击是没有特别反应的。
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
 
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
