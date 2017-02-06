//
//  CommunityCell.swift
//  FindestProj
//
//  Created by 焱 孙 on 16/6/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

import UIKit

class CommunityCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgViewSelect: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = SkinManage.colorNamed("Function_BK_Color")
        
        let viewSelected = UIView(frame:self.frame)
        viewSelected.backgroundColor = SkinManage.colorNamed("Table_Selected_Color")
        self.selectedBackgroundView = viewSelected
        
        lblName.textColor = SkinManage.colorNamed("Menu_Title_Color")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setEntity(entity: CommunityVo) {
        lblName.text = entity.strName
        imgViewSelect.hidden = !entity.bSelected
    }
}
