//
//  CommunityViewController.swift
//  FindestProj
//
//  Created by 焱 孙 on 16/6/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

import UIKit

class CommunityViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {

    @IBOutlet weak var tableViewCommunity: UITableView!
    
    var aryCommunitiy = [CommunityVo]()
    var communitySelected: CommunityVo?
    var noSearchView: NoSearchView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initView()
        self.initData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        self.title = "圈子"
        
        tableViewCommunity.backgroundColor = SkinManage.colorNamed("Page_BK_Color");
        tableViewCommunity.separatorColor = SkinManage.colorNamed("Wire_Frame_Color");
        
        noSearchView = NoSearchView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight-NAV_BAR_HEIGHT), andDes:"您还没有关注任何圈子")
    }
    
    func initData() {
        Common.showProgressView(nil, view: self.view, modal: false)
        ServerProvider.getUserDetail(Common.getCurrentUserVo().strUserID) { retInfo in
            Common.hideProgressView(self.view)
            if retInfo.bSuccess {
                if let userVo = retInfo.data as? UserVo {
                    self.aryCommunitiy += userVo.aryCommunity as AnyObject as! [CommunityVo]
                    self.tableViewCommunity.reloadData()
                }
                
                if let noSearchView = self.noSearchView {
                    if self.aryCommunitiy.count == 0 {
                        self.view.addSubview(noSearchView)
                    } else {
                        noSearchView.removeFromSuperview()
                    }
                }
            } else {
                Common.tipAlert(retInfo.strErrorMsg)
            }
        }
    }
    
    //MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            //切换到这个圈子
            if let communityVo = communitySelected {
                Common.showProgressView("切换中...", view: self.view, modal: true)
                CommunityService.switchCommunity(communityVo.strID, result: { retInfo in
                    Common.hideProgressView(self.view)
                    if retInfo.bSuccess {
                        //切换圈子成功，重新登录
                        self.navigationController?.popViewControllerAnimated(true)
                        NSNotificationCenter.defaultCenter().postNotificationName("NOTIFY_BACKTOHOME", object: "ReLoginNotify")
                    } else {
                        Common.tipAlert(retInfo.strErrorMsg)
                    }
                })
            }
        }
    }
    
    func configureCommunityCell(cell: CommunityCell, indexPath: NSIndexPath) {
        cell.fd_enforceFrameLayout = false
        cell.setEntity(aryCommunitiy[indexPath.row])
    }

    //MARK: UITableViewDataSource UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryCommunitiy.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommunityCell", forIndexPath: indexPath) as! CommunityCell
        configureCommunityCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.fd_heightForCellWithIdentifier("CommunityCell", configuration: { cell in
            self.configureCommunityCell(cell as! CommunityCell, indexPath: indexPath)
        })
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let communityVo = aryCommunitiy[indexPath.row]
        if !communityVo.bSelected {
            communitySelected = communityVo
            let alertView = UIAlertView(title: "提示", message: "您确定要切换到这个圈子？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alertView.show()
        }
    }
}
