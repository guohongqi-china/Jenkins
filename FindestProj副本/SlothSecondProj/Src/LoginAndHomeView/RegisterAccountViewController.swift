//
//  RegisterAccountViewController.swift
//  FindestProj
//
//  Created by 焱 孙 on 16/6/16.
//  Copyright © 2016年 visionet. All rights reserved.
//

import UIKit

class RegisterAccountViewController: CommonViewController {
    
    @IBOutlet weak var txtAccount: UITextField!
    @IBOutlet weak var imgViewValidate: UIImageView!
    @IBOutlet weak var constraintIconH: NSLayoutConstraint!
    
    var commitButtonView: CommitButtonView?
    var registerVo: UserVo?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.bFirstAppear {
            txtAccount.becomeFirstResponder()
        }
    }

    func initView() {
        self.setTitleImage(UIImage(named: "nav_logo"))
        
        self.isNeedBackItem = false
        let leftItem = UIBarButtonItem(image: UIImage(named: "nav_back_normal"), style: .Plain, target: self, action: #selector(backForePage))
        leftItem.tintColor = Constants.colorTheme
        self.navigationItem.leftBarButtonItem = leftItem
        
        commitButtonView = CommitButtonView(leftTitle: nil, right: "下一步") { [unowned self] sender in
            Common.showProgressView("请稍后...", view: self.view, modal: false)
            ServerProvider.checkPhone(self.txtAccount.text) { retInfo in
                Common.hideProgressView(self.view)
                if retInfo.bSuccess {
                    if self.registerVo == nil {
                        self.registerVo = UserVo()
                    }
                    self.registerVo?.strLoginAccount = self.txtAccount.text;
                    
                    //检查账号是否存在
                    let strResult = retInfo.data as? String
                    if let result = strResult where result == "true"  {
                        let registerPwdViewController = UIStoryboard(name: "LoginModule", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("RegisterPwdViewController") as! RegisterPwdViewController
                        registerPwdViewController.registerVo = self.registerVo;
                        self.navigationController?.pushViewController(registerPwdViewController, animated: true)
                        
                        self.txtAccount.resignFirstResponder()
                    } else {
                        Common.tipAlert("该账号已存在")
                    }
                    
                } else {
                    Common.tipAlert(retInfo.strErrorMsg)
                }
            }
        }
        self.view.addSubview(commitButtonView!)
        
        commitButtonView?.snp_makeConstraints { make in
            make.leading.bottom.trailing.equalTo(0)
            make.height.equalTo(44.5)
        }
    }

    @IBAction func textValueChanged(sender: UITextField) {
        if sender.text?.characters.count > 0 {
            commitButtonView?.setRightButtonEnable(true)
            
            //浮点数
            if self.imgViewValidate.alpha < 0.0001 {
                UIView.animateWithDuration(0.5, animations:{
                    self.imgViewValidate.alpha = 1.0
                    self.constraintIconH.constant = 20
                    self.view.layoutIfNeeded()
                    });
            }
        } else {
            commitButtonView?.setRightButtonEnable(false)
            
            //浮点数
            if self.imgViewValidate.alpha > 0.0001 {
                UIView.animateWithDuration(0.5, animations:{
                    self.imgViewValidate.alpha = 0;
                    self.constraintIconH.constant = 10;
                    self.view.layoutIfNeeded()
                    })
            }
        }
    }
}
