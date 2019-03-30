//
//  GBMDocumentDetailController.swift
//  GreatBuildingMaster
//
//  Created by huang shervin on 2018/11/22.
//  Copyright © 2018年 huang shervin. All rights reserved.
//

import UIKit

class GBMDocumentDetailController: GBMBaseTableViewController {

    private lazy var _detailViewModel: GBMDocumentDetailModel = GBMDocumentDetailModel()
    
    var fileId:String?
    
    override init!(style: UITableView.Style) {
        super.init(style: style)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "详情"
        self.tableView.tableView.tableFooterView = footerView
        self.loadDetailViewModel()
    }
    
    override func tableViewWillStartDragRefresh(_ tableView: SVHBaseTableView!) {
        self.pullToLoadDetailViewModel()
    }
    
    override func tableView(_ tableView: SVHBaseTableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    private lazy var footerView: UIView = {
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: 60))
        let frame:CGRect = CGRect.init(x: 10, y: 10, width: view.width - 20, height: 40)
        let button:UIButton = GBMViewTool.createButton(type: UIButton.ButtonType.custom, frame: frame, title: "预览", backgroudColor: GBMAppConfig.appMainColor(),target: self, action: #selector(GBMDocumentDetailController.previewButtonTaped))
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        view.addSubview(button)
        return view
    }()
    
    @objc func previewButtonTaped() -> Void {
        if _detailViewModel.fileURL?.isEmpty == false {
            let vc:GBMBaseWebViewController = GBMBaseWebViewController()
            vc.url = _detailViewModel.fileURL!
            let title:NSString = _detailViewModel.fileName! as NSString
            vc.navTitle = title.deletingPathExtension
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func loadDetailViewModel() -> Void {
        if fileId?.isEmpty == false {
            _detailViewModel.load(fileId: fileId!, startBlock: { (model:GJTRequestDelegate?) in
                self.view.showGapView(with: SVHLoadingGapViewStyle.loading, block: nil)
            }) { (model:GJTRequestDelegate?, error:Error?) in
                if model?.errorItem == nil {
                    self.view.hideGapView()
                    self.reloadTableViewWithItems(items: self._detailViewModel.items)
                }else {
                    self.view.showGapView(with: SVHLoadingGapViewStyle.loadFailNoImage, block: {
                        self.loadDetailViewModel()
                    })
                }
            }
        }
    }
    
    func pullToLoadDetailViewModel() -> Void {
        if fileId?.isEmpty == false {
            _detailViewModel.load(fileId: fileId!, startBlock: nil) { (model:GJTRequestDelegate?, error:Error?) in
                if model?.errorItem == nil {
                    self.tableView.endRefreshSuccess(true)
                    self.reloadTableViewWithItems(items: self._detailViewModel.items)
                }else {
                    self.tableView.endRefreshSuccess(false)
                }
            }
        }
    }
    
    func reloadTableViewWithItems(items:Array<GBMBaseCellItem>) -> Void {
        self.tableView.items.removeAllObjects()
        self.tableView.items.addObjects(from: items)
        self.tableView.reloadData()
    }

}
