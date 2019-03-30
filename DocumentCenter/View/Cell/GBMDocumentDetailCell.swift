//
//  GBMDocumentDetailCell.swift
//  GreatBuildingMaster
//
//  Created by huang shervin on 2018/11/22.
//  Copyright © 2018年 huang shervin. All rights reserved.
//

import Foundation

let GBMDocumentDetailCellLeftLabelWidth:CGFloat = 100.0
let GBMDocumentDetailCellLeftLabel_rightlabel_space:CGFloat = 10.0

class GBMDocumentDetailCell: GBMBaseCell {
    
    private var _leftLabel:UILabel = GBMViewTool.createLabel(text: nil, font: nil, textColor: nil)
    private var _rightLabel:UILabel = GBMViewTool.createLabel(text: nil, font: nil, textColor: nil   )

    /** 重载OC类方法 */
    override static func tableView(_ tableView: UITableView!, rowHeightFor: SVHBaseCellItem!) -> CGFloat{
        
        let newItem:GBMDocumentDetailCellItem = rowHeightFor as! GBMDocumentDetailCellItem
        
        if newItem.cellHeight > 0 {
            return newItem.cellHeight
        }
        
        let textSize:CGSize = SVHTextSizeWithText(newItem.rightText, newItem.rightTextFont, CGSize.init(width: tableView.width - newItem.contentEdgeInsets.left - newItem.contentEdgeInsets.right - GBMDocumentDetailCellLeftLabelWidth - GBMDocumentDetailCellLeftLabel_rightlabel_space, height: 1000))
        
        if textSize.height > (50 - newItem.contentEdgeInsets.top - newItem.contentEdgeInsets.bottom) {
            newItem.cellHeight = textSize.height + newItem.contentEdgeInsets.top + newItem.contentEdgeInsets.bottom
        }else {
            newItem.cellHeight = 50
        }
        
        return newItem.cellHeight
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(_leftLabel)
        self.contentView.addSubview(_rightLabel)
        _rightLabel.numberOfLines = 0
    }
    
    override var item: SVHBaseCellItem!{
        get {
            return super.item
        }
        set {
            if self.item != newValue {
                super.item = newValue
                let newItem:GBMDocumentDetailCellItem = newValue as! GBMDocumentDetailCellItem
                
                _leftLabel.text = newItem.leftText
                _leftLabel.font = newItem.leftTextFont
                _leftLabel.textColor = newItem.leftTextColor
                
                _rightLabel.text = newItem.rightText
                _rightLabel.font = newItem.rightTextFont
                _rightLabel.textColor = newItem.rightTextColor
                
                self.setNeedsLayout()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let newItem:GBMDocumentDetailCellItem = self.item as! GBMDocumentDetailCellItem
        _leftLabel.frame = CGRect.init(x:newItem.contentEdgeInsets.left , y: 0, width: GBMDocumentDetailCellLeftLabelWidth, height: _leftLabel.font.lineHeight)
        _rightLabel.frame = CGRect.init(x: _leftLabel.right + GBMDocumentDetailCellLeftLabel_rightlabel_space, y: 0, width: self.width - _leftLabel.right - GBMDocumentDetailCellLeftLabel_rightlabel_space - newItem.contentEdgeInsets.right, height: self.height - newItem.contentEdgeInsets.top - newItem.contentEdgeInsets.bottom)
        _leftLabel.centerY = self.height/2
        _rightLabel.centerY = self.height/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class GBMDocumentDetailCellItem: GBMBaseCellItem {
    var leftText:String?
    var rightText:String?
    var leftTextFont:UIFont = UIFont.systemFont(ofSize: 15.0)
    var rightTextFont:UIFont = UIFont.systemFont(ofSize: 14.0)
    var leftTextColor:UIColor = UIColor.darkGray
    var rightTextColor:UIColor = UIColor.lightGray
    override func cellClass() -> AnyClass! {
        return GBMDocumentDetailCell.classForCoder()
    }
    
    override init() {
        super.init()
        self.accessoryType = UITableViewCell.AccessoryType.none
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    convenience init(leftText:String?,rightText:String?) {
        self.init()
        self.leftText = leftText
        self.rightText = rightText
    }
}
