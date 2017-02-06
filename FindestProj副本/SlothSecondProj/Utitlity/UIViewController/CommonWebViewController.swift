//
//  CommonWebViewController.swift
//  MinmetalsMeetingProj
//
//  Created by 焱 孙 on 16/4/20.
//  Copyright © 2016年 visionet. All rights reserved.
//

import UIKit

@objc public class CommonWebViewController: CommonViewController,UIWebViewDelegate {
    
    public var strPageType = ""
    public var strURL = ""
    
    @IBOutlet weak var webViewHtml: UIWebView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initView()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        self.title = "页面载入中"
        
        //设置Cookie
        if let url = NSURL(string: strURL)
        {
            let request = NSMutableURLRequest(URL: url)
            if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies
            {
                request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
            }
            webViewHtml.loadRequest(request)
        }
    }
    
    override public func backForePage() {
        if webViewHtml.canGoBack {
            webViewHtml.goBack()
        } else {
            if strPageType == "BarcodeScanPage" {
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                super.backForePage()
            }
        }
    }
    
    //UIWebViewDelegate
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked || navigationType == .Reload || navigationType == .Other {
//            if let strURL = request.URL?.absoluteString {
//                
//            }
        }
        
        return true
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
    }
}
