//
//  TimestampView.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import UIKit

/**
 Defines timestamp view used in charts to show time period of 4 weeks.
*/
class TimestampView: UIStackView {
    
    //MARK: Label subviews
    func prepareViews() {
        
        let labels: [UILabel] = [Int](1...4).reverse().map {
            let label = UILabel()
            label.text = "\($0)w ago"
            label.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
            label.textAlignment = .Center
            label.textColor = UIColor(red:0.21, green:0.29, blue:0.36, alpha:1.00)
            return label
        }
        
        axis = .Horizontal
        distribution = .FillEqually
        alignment = .Fill
        
        _ = labels.map {
            addArrangedSubview($0)
        }
    }
    
    //MARK: Init methods
    init() {
        super.init(frame: CGRect.zero)
        prepareViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
