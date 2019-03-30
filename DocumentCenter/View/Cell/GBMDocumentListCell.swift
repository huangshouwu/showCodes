//
//  GBMDocumentListCell.swift
//  GreatBuildingMaster
//
//  Created by huang shervin on 2018/11/21.
//  Copyright © 2018年 huang shervin. All rights reserved.
//

import Foundation



class GBMDocumentListCell: GBMBaseCell {
    
    static let fileNameLabelFont:UIFont = UIFont.systemFont(ofSize: 14.0)
    
    private let _fileNameLabel:UILabel = GBMViewTool.createLabel(text: nil, font: fileNameLabelFont, textColor: UIColor.darkGray)
    
    /** 重载OC类方法 */
    override static func tableView(_ tableView: UITableView!, rowHeightFor: SVHBaseCellItem!) -> CGFloat{
        let newItem:GBMDocumentListCellItem = rowHeightFor as! GBMDocumentListCellItem
        
        if newItem.cellHeight > 0 {
            return newItem.cellHeight
        }
        
        let textSize:CGSize = SVHTextSizeWithText(newItem.fileName, fileNameLabelFont, CGSize.init(width: tableView.width - newItem.contentEdgeInsets.left - newItem.contentEdgeInsets.right, height: 1000))
        
        newItem.cellHeight = textSize.height + newItem.contentEdgeInsets.top + newItem.contentEdgeInsets.bottom
        
        return newItem.cellHeight
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _fileNameLabel.numberOfLines = 0
        self.contentView.addSubview(_fileNameLabel)
    }
    
    override var item: SVHBaseCellItem!{
        get {
            return super.item
        }
        set {
            if self.item != newValue {
                super.item = newValue
                let newItem:GBMDocumentListCellItem = newValue as! GBMDocumentListCellItem
                _fileNameLabel.text = newItem.fileName
                self.setNeedsLayout()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //code
        let newItem:GBMDocumentListCellItem = self.item as! GBMDocumentListCellItem
        _fileNameLabel.frame = CGRect.init(x: newItem.contentEdgeInsets.left, y: newItem.contentEdgeInsets.top, width: self.width - newItem.contentEdgeInsets.left - newItem.contentEdgeInsets.right, height: self.height - newItem.contentEdgeInsets.top - newItem.contentEdgeInsets.bottom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class GBMDocumentListCellItem: GBMBaseCellItem {
    var fileId:String?
    var fileName:String?
    override func cellClass() -> AnyClass! {
        return GBMDocumentListCell.classForCoder()
    }
    
    override init() {
        super.init()
        self.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 30)
        self.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        self.selectionStyle = UITableViewCell.SelectionStyle.gray
    }
}
