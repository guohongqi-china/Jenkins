//
//  CommunityDetailViewController.swift
//  FindestProj
//
//  Created by 焱 孙 on 16/6/28.
//  Copyright © 2016年 visionet. All rights reserved.
//

import UIKit

class CommunityDetailViewController: CommonViewController, UIAlertViewDelegate {
    
    var strOrgID: String?
    var isFromURLScheme = false
    
    @IBOutlet weak var imgViewBK: UIImageView!
    @IBOutlet weak var imgViewHeader: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnAttention: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func backForePage() {
        if isFromURLScheme {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func initView() {
        self.title = "圈子详情"
        self.fd_interactivePopDisabled = true
        if isFromURLScheme {
            isNeedBackItem = false
            self.navigationItem.leftBarButtonItem = self.leftBtnItemWithTitle("取消")
        }
        
        imgViewBK.image = UIImage(named: "community_detail_bk")?.stretchableImageWithLeftCapWidth(100, topCapHeight: 50)
        
        imgViewHeader.layer.shadowColor = COLOR_SWIFT(148, 145, 145, 1.0).CGColor;         //设置阴影的颜色
        imgViewHeader.layer.shadowOffset = CGSizeMake(0, 5);                   //设置阴影的偏移量（x,y），也可以设置成负数
        imgViewHeader.layer.shadowOpacity = 0.5;//设置阴影的不透明度
        imgViewHeader.layer.shadowRadius = 10.0;//设置阴影的模糊半径（blur radius）
    }
    
    func initData() {
        guard let strOrgID = strOrgID else {
            return
        }
        
        Common.showProgressView("", view: self.view, modal: false)
        CommunityService.getCommunityDetail(strOrgID, result: { retInfo in
            Common.hideProgressView(self.view)
            if retInfo.bSuccess {
                //刷新界面数据
                if let community = retInfo.data as? CommunityVo {
                    self.imgViewHeader.sd_setImageWithURL(NSURL(string: community.strHeaderUrl), placeholderImage: UIImage(named: "app_logo"))
                    self.lblTitle.text = community.strName
                    self.lblDesc.text = community.strDesc
                    
                    if community.isFollow {
                        //已关注
                        self.btnAttention.layer.borderColor = Constants.colorTheme.CGColor
                        self.btnAttention.setTitle("已关注", forState: .Normal)
                        self.btnAttention.setTitleColor(Constants.colorTheme, forState: .Normal)
                        self.btnAttention.backgroundColor = COLOR_SWIFT(246, 245, 245, 1.0)
                        self.btnAttention.enabled = false
                        
                    } else {
                        //未关注
                        self.btnAttention.layer.borderColor = UIColor.clearColor().CGColor
                        self.btnAttention.setTitle("关注", forState: .Normal)
                        self.btnAttention.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                        self.btnAttention.setTitleColor(COLOR_SWIFT(136, 136, 136, 1.0), forState: .Highlighted)
                        self.btnAttention.setImage(UIImage(named: "add_attention_icon"), forState: .Normal)
                        self.btnAttention.setBackgroundImage(Common.getImageWithColor(COLOR_SWIFT(45, 150, 208, 1.0)), forState: .Normal)
                        Common.setButtonImageLeftTitleRight(self.btnAttention, spacing: 7)
                    }
                }
            } else {
                Common.tipAlert(retInfo.strErrorMsg)
            }
        })
    }
    
    @IBAction func attentionAction(sender: AnyObject) {
        let alertView = UIAlertView(title: "提示", message: "您确定要关注和切换到这个圈子？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alertView.show()
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 && strOrgID != nil {
            Common.showProgressView(nil, view: self.view, modal: false)
            CommunityService.switchCommunity(strOrgID!, result: { (retInfo) in
                Common.hideProgressView(self.view)
                if retInfo.bSuccess {
                    //切换圈子成功，重新登录
                    if self.isFromURLScheme {
                        self.dismissViewControllerAnimated(false, completion: nil)
                    } else {
                        self.navigationController?.popToRootViewControllerAnimated(false)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("NOTIFY_BACKTOHOME", object: "ReLoginNotify")
                } else {
                    Common.tipAlert(retInfo.strErrorMsg)
                }
            })
        }
    }
}
