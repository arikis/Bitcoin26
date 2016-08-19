//
//  CurrentRateView.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSDateFormatter
import UIKit
import RxSwift
import RxCocoa
import CoinDesk

class CurrentRateView: UIStackView {
    
    //MARK: Subviews
    
    let eurLabel = UILabel()
    let btcLabel = UILabel()
    let eurIconImageView = UIImageView()
    let btcIconImageView = UIImageView()
    let arrowImageView = UIImageView()
    let currentValueLabel = UILabel()
    let currentDateLabel = UILabel()
    
    //MARK: Stack views
    let headerStackView = UIStackView()
    let currentValueStackView = UIStackView()
    
    //MARK: Auto layout
    func prepareStackViews() {
        axis = .Vertical
        alignment = .Center
        distribution = .Fill
        spacing = 20
        
        headerStackView.axis = .Horizontal
        headerStackView.alignment = .Center
        headerStackView.alignment = .Fill
        headerStackView.spacing = 10
        
        currentValueStackView.axis = .Vertical
        currentValueStackView.alignment = .Center
        currentValueStackView.spacing = 10
        
        headerStackView.addArrangedSubview(btcIconImageView)
        headerStackView.addArrangedSubview(btcLabel)
        headerStackView.addArrangedSubview(arrowImageView)
        headerStackView.addArrangedSubview(eurLabel)
        headerStackView.addArrangedSubview(eurIconImageView)
        
        currentValueStackView.addArrangedSubview(currentValueLabel)
        currentValueStackView.addArrangedSubview(currentDateLabel)
        
        addArrangedSubview(UIView())
        addArrangedSubview(headerStackView)
        addArrangedSubview(currentValueStackView)
    }
    
    func prepareSubviews() {
        arrowImageView.image = UIImage(named: "arrow")
        eurIconImageView.image = UIImage(named: "euro")
        btcIconImageView.image = UIImage(named: "bitcoin")
        
        arrowImageView.contentMode = UIViewContentMode.ScaleAspectFit
        arrowImageView.alpha = 0.5
        
        currentValueLabel.font = UIFont.systemFontOfSize(40, weight: UIFontWeightThin)
        
        currentDateLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        currentDateLabel.textColor = UIColor(red:0.18, green:0.24, blue:0.31, alpha:1.00)
        
        btcLabel.text = "btc".uppercaseString
        eurLabel.text = "eur".uppercaseString
        
        _ = [btcLabel, eurLabel].map {
            $0.font = UIFont.systemFontOfSize(22, weight: UIFontWeightLight)
            $0.textColor = UIColor(red:0.32, green:0.32, blue:0.32, alpha:1.00)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    //MARK: Init methods
    init() {
        super.init(frame: CGRect.zero)
        prepareStackViews()
        prepareSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareStackViews()
        prepareSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CurrentRateView {
    
    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd YYYY"
        return formatter
    }()
    
    var rx_rate: AnyObserver<ExchangeRate> {
        return UIBindingObserver(UIElement: self) { (view: CurrentRateView, exchangeRate: ExchangeRate) in
            view.currentValueLabel.text = "\(exchangeRate.euroValue)"
            
            // Change date
            view.currentDateLabel.text = CurrentRateView
                .dateFormatter
                .stringFromDate(exchangeRate.date)
            }
            .asObserver()
    }
}
