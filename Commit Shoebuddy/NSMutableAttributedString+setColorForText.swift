//
//  NSMutableAttributedString+setColorForText.swift
//  ShoeBuddy
//
//  Created by MAC on 9/9/18.
//  Copyright © 2018 EdgeWorks Sofware. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)

        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
    }
    
}
