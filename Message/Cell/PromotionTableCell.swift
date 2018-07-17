//
//  PromotionTableCell.swift
//  MobiJuce
//
//  Created by lhvan on 7/17/18.
//  Copyright © 2018 Kieu Minh Phu. All rights reserved.
//

import UIKit

struct PromotionTableCellItem {
    var dataSource: [Any]
}

class PromotionTableCell: UITableViewCell {
    
    lazy var titleLabel = UILabel()
    lazy var bottomLine = UIView()
    lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
    
    private let flowLayout = UICollectionViewFlowLayout()
    
    var cellItem: PromotionTableCellItem? {
        didSet {
            self.setData()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initialize UI
    func initializeUI() {
        
        // collectionView
        self.flowLayout.scrollDirection = .horizontal
        self.flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.flowLayout.minimumLineSpacing = 16
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView.register(PromotionCollectionCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.addSubview(self.collectionView)
        
        self.collectionView.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.top.left.right.equalTo(strongSelf).offset(0)
//            maker.left.equalTo(strongSelf).offset(16)
//            maker.right.equalTo(strongSelf).offset(-16)
            maker.height.equalTo(304)
        }
    }
    
    // MARK: set data
    func setData() {
        self.collectionView.reloadData()
    }
    
}

extension PromotionTableCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellItem?.dataSource.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellItem = self.cellItem?.dataSource[indexPath.item] as? PromotionCollectionCellItem {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                          for: indexPath) as! PromotionCollectionCell
            cell.cellItem = cellItem
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension PromotionTableCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 280)
    }
}
