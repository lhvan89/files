//
//  PromotionCollectionCell.swift
//  MobiJuce
//
//  Created by lhvan on 7/17/18.
//  Copyright © 2018 Kieu Minh Phu. All rights reserved.
//

import UIKit

struct PromotionCollectionCellItem {
    var image: String?
    var subTitle: String?
    var title: String?
}

class PromotionCollectionCell: UICollectionViewCell {
    
    lazy var cardView = UIView()
    lazy var imageView = UIImageView()
    lazy var subTitleLabel = UILabel()
    lazy var titleLabel = UILabel()
    
    var cellItem: PromotionCollectionCellItem? {
        didSet {
            self.setData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initialize UI
    func initializeUI() {
        self.backgroundColor = .clear
        
        // cardView
        self.cardView.layer.cornerRadius = 8
        self.cardView.backgroundColor = .red
        self.cardView.clipsToBounds = true
        self.cardView.addShadow(location: .all, opacity: 0.2)
        self.addSubview(self.cardView)
        
        self.cardView.snp.makeConstraints { [weak self] (maker) in
            guard let strongSelf = self else { return }
            maker.top.equalTo(strongSelf).offset(0)
            maker.left.right.equalTo(strongSelf).offset(0)
            maker.height.equalTo(280)
        }
        
        // imageView
        self.imageView.layer.cornerRadius = 8
        self.imageView.clipsToBounds = true
        self.cardView.addSubview(imageView)
        self.imageView.snp.makeConstraints { [weak self] (maker) in
            guard let strongSelf = self else { return }
            maker.left.right.top.bottom.equalTo(strongSelf.cardView)
        }
        
        // subTitleLabel
        self.subTitleLabel.setThemeFont(style: FontStyle.overlineStyle)
        self.subTitleLabel.setThemeTextColor(keyPath: ThemeKeys.Label.TextColor3.key, alpha: AlphaColor.inactive)
        self.cardView.addSubview(self.subTitleLabel)
        
        self.subTitleLabel.snp.makeConstraints { [weak self] (maker) in
            guard let strongSelf = self else { return }
            maker.top.equalTo(strongSelf.cardView).offset(12)
            maker.left.equalTo(strongSelf.cardView).offset(16)
        }
        
        // titleLabel
        self.titleLabel.setThemeFont(style: FontStyle.headline5Style)
        self.titleLabel.setThemeTextColor(keyPath: ThemeKeys.Label.TextColor3.key, alpha: AlphaColor.full)
        self.cardView.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { [weak self] (maker) in
            guard let strongSelf = self else { return }
            maker.top.equalTo(strongSelf.subTitleLabel.snp.bottom)
            maker.left.equalTo(strongSelf.subTitleLabel)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.imageView.image = nil
        self.titleLabel.text = nil
        self.subTitleLabel.text = nil
    }
    
    // MARK: set data
    func setData() {
        self.imageView.loadImage(urlString: cellItem?.image, completion: nil)
        self.titleLabel.text = cellItem?.title
        self.subTitleLabel.text = cellItem?.subTitle
    }
}
