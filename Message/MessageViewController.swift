//
//  MessageViewController.swift
//  MobiJuce
//
//  Created by Phu on 6/25/18.
//  Copyright © 2018 Kieu Minh Phu. All rights reserved.
//

import UIKit

class MessageViewController: BaseTabItemViewController {
    
    lazy var tableView = UITableView()
    var cellItems = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeUI()
        self.setDataSource()
        title = "Message".localized()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeUI() {
        
        self.view.backgroundColor = .white
        
        // tableView
        self.tableView.allowsSelection = true
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .red
        self.tableView.register(PromotionTableCell.self, forCellReuseIdentifier: "promotionCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { [weak self] (maker) in
            guard let strongSelf = self else { return }
            maker.edges.equalTo(strongSelf.view)
        }
    }
    
    func setDataSource() {
        
        self.cellItems.removeAll()
        
        // Promotion Data
        var promotionDataSource = [Any]()
        promotionDataSource.append(PromotionCollectionCellItem(image: "https://i.pinimg.com/originals/fe/7a/7f/fe7a7fe6a3a95ab9a3f25668341d5a92.jpg", subTitle: "SHOP NAME", title: "Promotion name\nLine 2"))
        promotionDataSource.append(PromotionCollectionCellItem(image: "https://i.pinimg.com/originals/fe/7a/7f/fe7a7fe6a3a95ab9a3f25668341d5a92.jpg", subTitle: "SHOP NAME", title: "Promotion name\nLine 2"))
        promotionDataSource.append(PromotionCollectionCellItem(image: "https://i.pinimg.com/originals/fe/7a/7f/fe7a7fe6a3a95ab9a3f25668341d5a92.jpg", subTitle: "SHOP NAME", title: "Promotion name\nLine 2"))
        self.cellItems.append(PromotionTableCellItem(dataSource: promotionDataSource))
 
        self.tableView.reloadData()
    }
}

extension MessageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.cellItems[indexPath.row] as? PromotionTableCellItem) != nil {
            return 304
        }
        
        return UITableViewAutomaticDimension
    }
}

extension MessageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cellItem = self.cellItems[indexPath.row] as? PromotionTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "promotionCell", for: indexPath) as! PromotionTableCell
            cell.cellItem = cellItem
            
            cell.selectionStyle = .none
            
            return cell
        }
        return UITableViewCell()
    }
}
