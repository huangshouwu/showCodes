//
//  GBMDocumentListViewModel.swift
//  GreatBuildingMaster
//
//  Created by huang shervin on 2018/11/22.
//  Copyright © 2018年 huang shervin. All rights reserved.
//

import UIKit

class GBMDocumentListViewModel: GBMBaseMutablePageViewModel {
    
    var items:Array<SVHBaseCellItem> = Array.init()
    
    func load(page:Int,filterString:String?,start startBlock: GJTViewModelWillStartLoadBlock!, finishedBlock fininshedBlock: GJTViewModelFinishedBlock!) -> Void {
        
        super.load(withPage: page, start: startBlock, finishedBlock: fininshedBlock)
        
        var parameters:Dictionary<String,String> = Dictionary.init()
        parameters["pageNo"] = String.init(format: "%ld", page)
        parameters["pageSize"] = String.init(format: "%ld", self.size)
        if !GBMStringTool.stringIsEmpty(string: filterString) {
            parameters["fileName"] = filterString!
        }
        
        self.model?.load(withURL: GBMHttpTool.dynamicURL(path: GBM_documentListAPI), method: GJTRequestMethod.POST, parameters: parameters)
    }
    
    override func loadDidFinished(_ model: GJTRequestDelegate!, error: Error!) {
        if model.errorItem == nil {
            if self.page == 0{
                self.allListArray().removeAllObjects()
            }
            let dic:Dictionary<String,Any>? = model?.resultDictionary as! Dictionary<String, Any>?
            if dic?.isEmpty == false{
                let list:Array<Dictionary<String,String>>? = dic!["knowledges"] as! Array<Dictionary<String, String>>?
                
                if (list?.isEmpty)! == false {
                    
                    haveMore = (list!.count >= self.size) ? true : false
                    
                    for files in list! {
                        let item:GBMDocumentListCellItem = GBMDocumentListCellItem.init()
                        item.fileId = files["id"]
                        item.fileName = files["fileName"]
                        self.allListArray().add(item)
                    }
                }else {
                    haveMore = false
                }
                
                var tempItems:Array<SVHBaseCellItem> = Array.init()
                tempItems.append(contentsOf: self.allListArray() as! Array<SVHBaseCellItem>)
                if haveMore {
                    self.loadingItem.loadingState = SVHLoadingStateLoading
                    tempItems.append(self.loadingItem)
                }
                items = tempItems
            }
        }
        super.loadDidFinished(model, error: error)
    }
    
}
