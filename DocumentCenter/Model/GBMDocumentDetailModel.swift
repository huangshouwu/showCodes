//
//  GBMDocumentDetailModel.swift
//  GreatBuildingMaster
//
//  Created by huang shervin on 2018/11/22.
//  Copyright © 2018年 huang shervin. All rights reserved.
//

import UIKit

class GBMDocumentDetailModel: GBMBaseViewModel {
    
    var iid:String?
    var fileName:String?
    var fileSize:Int64?
    var uploadUser:String?
    var uploadTime:String?
    var fileURL:String?
    var fileType:String?
    
    func load(fileId:String,startBlock: GJTViewModelWillStartLoadBlock!, finishedBlock fininshedBlock: GJTViewModelFinishedBlock!) -> Void {
        if !fileId.isEmpty {
            super.load(start: startBlock, finishedBlock: fininshedBlock)
            var parameters:Dictionary<String,String> = Dictionary.init()
            parameters["id"] = fileId
            self.model?.load(withURL: GBMHttpTool.dynamicURL(path: GBM_documentDetailAPI) , method: GJTRequestMethod.POST, parameters: parameters)
        }
    }
    
    override func loadDidFinished(_ model: GJTRequestDelegate!, error: Error!) {
        if model.errorItem == nil {
            let dic:Dictionary<String,Any>? = model?.resultDictionary as! Dictionary<String, Any>?
            if dic?.isEmpty == false{
                let result:Dictionary<String,Any>? = dic!["result"] as! Dictionary<String, Any>?
                if result?.isEmpty == false{
                    self.iid = (result?["id"] as! String)
                    self.fileName = (result?["fileName"] as! String)
                    self.fileSize = (result?["fileSize"] as! Int64)
                    self.uploadUser = (result?["uploadUser"] as! String)
                    self.uploadTime = (result?["uploadTime"] as! String)
                    self.fileURL = (result?["fileUrl"] as! String)
                    self.fileType = (result?["fileType"] as! String)
                }
            }
        }
        super.loadDidFinished(model, error: error)
    }
    
    lazy var items: Array<GBMDocumentDetailCellItem> = {
        var list:Array<GBMDocumentDetailCellItem> = Array.init()
        let item1:GBMDocumentDetailCellItem = GBMDocumentDetailCellItem.init(leftText: "文件名称", rightText: fileName)
        let item2:GBMDocumentDetailCellItem = GBMDocumentDetailCellItem.init(leftText: "文件大小", rightText: SVHFileTool.svhFileSizeDescription(Float(self.fileSize!)))
        let item3:GBMDocumentDetailCellItem = GBMDocumentDetailCellItem.init(leftText: "上传者", rightText: uploadUser)
        let item4:GBMDocumentDetailCellItem = GBMDocumentDetailCellItem.init(leftText: "上传时间", rightText: self.uploadTime)
        
        list.append(item1)
        list.append(item2)
        list.append(item3)
        list.append(item4)
        return list
    }()
    
}
