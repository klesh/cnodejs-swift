//
//  PHTextView.swift
//  CNode
//
//  Created by Klesh Wong on 1/14/16.
//  Copyright © 2016 Klesh Wong. All rights reserved.
//

import UIKit

class PHTextView : UITextView, UITextViewDelegate {
    var placeHolder: UILabel!
    
    override func awakeFromNib() {
        placeHolder = UILabel(frame: CGRectMake(5, 0, frame.size.width, 30))
        placeHolder.textColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        
        self.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        
        self.delegate = self
        
        self.addSubview(placeHolder)
    }
    
    func textViewDidChange(textView: UITextView) {
        placeHolder.hidden = textView.hasText()
    }
}