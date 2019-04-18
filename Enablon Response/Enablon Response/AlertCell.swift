//
//  AlertCell.swift
//  Enablon Response
//
//  Created by Josh Kaplan on 4/15/19.
//  Copyright © 2019 Josh Kaplan. All rights reserved.
//

import Foundation
import UIKit

class AlertCell: UITableViewCell {
    
    var alertTitle : String?
    var alertMessage : String?
    
    var alertMessageView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    var alertTitleView : UITextView = {
       var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(alertTitleView)
        self.addSubview(alertMessageView)
        
        alertTitleView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        alertTitleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        alertTitleView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        alertTitleView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        alertMessageView.leftAnchor.constraint(equalTo: self.alertTitleView.rightAnchor).isActive = true
        alertMessageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        alertMessageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        alertMessageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let alertMessage = alertMessage {
            alertMessageView.text = alertMessage
        }
        if let alertTitle = alertTitle {
            alertTitleView.text = alertTitle
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
