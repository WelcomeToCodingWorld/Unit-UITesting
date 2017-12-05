//
//  DropdownListView.swift
//  CarOli
//
//  Created by ari 李 on 05/12/2017.
//  Copyright © 2017 Lesta. All rights reserved.
//

import UIKit

protocol DropdownListDelegate {
    
}

protocol DropdownListDataSource {
    
}

class DropdownListView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
    }
    
}
