//
//  GBMDocumentCenterController.swift
//  GreatBuildingMaster
//
//  Created by huang shervin on 2018/11/21.
//  Copyright © 2018年 huang shervin. All rights reserved.
//

import UIKit

/** 知识库 */
class GBMDocumentCenterController: GBMBaseTableViewController,SVHSearchBarDelegate {

    private var searchResult:Array<GBMContactsListCellItem> = Array.init()
    private lazy var _listViewModel: GBMDocumentListViewModel = GBMDocumentListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "知识库"
        self.resetViewFrame(true)
        
        self.view.addSubview(_searchBar)
        self.tableView.frame = CGRect.init(x: 0, y: _searchBar.bottom, width: self.view.width, height: self.view.height - _searchBar.bottom)
        
        self.loadListViewModelWithFilterString(filterString: nil)
    }
    
    private lazy var _searchBar:SVHSearchBar = {
        let searchBar:SVHSearchBar = SVHSearchBar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: 50))
        searchBar.textField.placeholder = "请输入搜索内容"
        searchBar.delegate = self
        searchBar.textField.inputAccessoryView = GBMTextFieldAccessoryViewWith(self,#selector(GBMDocumentCenterController.startSearch))
        return searchBar
    }()
    
    @objc func startSearch() -> Void {
        self.hideKeyboard()
        self.loadListViewModelWithFilterString(filterString: _searchBar.textField.text)
    }
    
    func loadListViewModelWithFilterString(filterString:String?) -> Void {
        _listViewModel.load(page: 0, filterString: filterString, start: { (model:GJTRequestDelegate?) in
            self.tableView.showGapView(with: SVHLoadingGapViewStyle.loading, block: nil)
        }) { (model:GJTRequestDelegate?, error:Error?) in
            if model?.errorItem == nil {
                self.tableView.hideGapView()
                if self._listViewModel.items.count > 0 {
                    self.reloadTableViewWithItems(items: self._listViewModel.items)
                }else {
                    self.tableView.showGapView(with: SVHLoadingGapViewStyle.noDataNoImage, block: nil)
                }
            }else {
                self.tableView.showGapView(with: SVHLoadingGapViewStyle.loadFailNoImage, block: {
                    self.loadListViewModelWithFilterString(filterString: filterString)
                })
            }
        }
    }
    
    func loadListViewModelMoreWithFilterString(filterString:String?) -> Void {
        _listViewModel.load(page: _listViewModel.page + 1, filterString: filterString, start: nil) { (model:GJTRequestDelegate?, error:Error?) in
            if model?.errorItem == nil {
                if self._listViewModel.items.count > 0 {
                    self.reloadTableViewWithItems(items: self._listViewModel.items)
                }
            }
        }
    }
    
    func pullToLoadViewModelWithFilterString(filterString:String?) -> Void {
        _listViewModel.load(page: 0, filterString: filterString, start: nil) { (model:GJTRequestDelegate?, error:Error?) in
            if model?.errorItem == nil {
                self.tableView.endRefreshSuccess(true)
                if self._listViewModel.items.count > 0 {
                    self.reloadTableViewWithItems(items: self._listViewModel.items)
                }
            }else {
                self.tableView.endRefreshSuccess(false)
            }
        }
    }
    
    func reloadTableViewWithItems(items:Array<SVHBaseCellItem>) -> Void {
        self.tableView.items.removeAllObjects()
        self.tableView.items.addObjects(from: items)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: SVHBaseTableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: SVHBaseTableView!, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: SVHBaseTableView!, didSelectObject object: SVHBaseCellItem!, at indexPath: IndexPath!) {
        self.hideKeyboard()
        let newItem:GBMDocumentListCellItem = object as! GBMDocumentListCellItem
        self.pushToDetailController(fileId: newItem.fileId)
    }
    
    override func tableViewWillStartDragRefresh(_ tableView: SVHBaseTableView!) {
        self.pullToLoadViewModelWithFilterString(filterString: _searchBar.textField.text)
    }
    
    override func tableView(_ tableView: SVHBaseTableView!, willDisplay cell: UITableViewCell!, forRowAt indexPath: IndexPath!) {
        if cell.isKind(of: SVHLoadingCell.classForCoder()) {
            self.loadListViewModelMoreWithFilterString(filterString: _searchBar.textField.text!)
        }
    }

    func pushToDetailController(fileId:String?) -> Void {
        let vc:GBMDocumentDetailController = GBMDocumentDetailController.init(style: UITableView.Style.grouped)
        vc.fileId = fileId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
