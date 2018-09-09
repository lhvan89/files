//
//  ACAgreementTableCell.swift
//  ShoeBuddy
//
//  Created by Van Le on 9/5/18.
//  Copyright © 2018 EdgeWorks Sofware. All rights reserved.
//

import UIKit

import UIKit

protocol ACAgreementTableCellDelegate: class {
    func acAgreementTableCell(_ cell: ACAgreementTableCell, didTapButton cellItem: ACAgreementTableCellItem?, _ gestureRegconize: UITapGestureRecognizer)
}

struct ACAgreementTableCellItem {
    var id: Int?
    var title: String?
}

class ACAgreementTableCell: UITableViewCell {
    
    var cellItem: ACAgreementTableCellItem? {
        didSet {
            self.setData()
        }
    }
    
    weak var delegate: ACAgreementTableCellDelegate?
    
    // titleLabel
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.setThemeTextColor(keyPath: ThemeKeys.Label.textColor1.key, alpha: 0.6)
        label.setThemeFont(keyPath: ThemeKeys.Global.RegularFont.key, fontSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initialize UI
    func initializeUI() {
        
        self.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleAgreementLabelTapped(_ :)))
        self.titleLabel.addGestureRecognizer(tapGesture)
        self.addSubview(self.titleLabel)
        
        // Set constraint layouts
        self.titleLabel.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.centerX.equalTo(strongSelf)
            maker.top.equalTo(strongSelf).offset(8)
            maker.bottom.equalTo(strongSelf).offset(-8)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
    }
    
    // MARK: Set Data
    func setData() {
        
        guard let agreementText = cellItem?.title else { return }
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: agreementText)
        attributedString.setColorForText(textForAttribute: LocalizeStrings.Account.termsAndConditionsString, withColor: .white)
        attributedString.setColorForText(textForAttribute: LocalizeStrings.Account.privacyPolicyString, withColor: .white)
        
        self.titleLabel.attributedText = attributedString
    }
    
    @objc func handleAgreementLabelTapped(_ gestureRegconize: UITapGestureRecognizer) {
        
        self.delegate?.acAgreementTableCell(self, didTapButton: self.cellItem, gestureRegconize)
    }
}
