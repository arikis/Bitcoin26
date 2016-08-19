//
//  RatesViewController.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import Charts
import CoinDesk

/**
 Provides view controller that shows historical and current exchange rate data
 for BTC/EUR.
 */
class RatesViewController: UIViewController {
    
    //MARK: Views
    let currentRateView = CurrentRateView()
    let chartView = ChartView()
    
    //MARK: View model
    let viewModel = RateViewModel()
    let disposeBag = DisposeBag()
    
    var reachability: Reachability?
    
    //MARK: Auto layout
    var views: [String: AnyObject] {
        return [
            "current": currentRateView,
            "chart": chartView
        ]
    }
    
    /// Prepares views for Autolayout
    func prepareViews() {
        currentRateView.translatesAutoresizingMaskIntoConstraints = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Creates neccesary `NSLayoutConstraint` objects and activates them
    func setupViews() {
        view.addSubview(currentRateView)
        view.addSubview(chartView)
        
        var allConstraints = [NSLayoutConstraint]()
        
        currentRateView.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor).active = true
        
        
        allConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[current]|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        
        allConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[chart]|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        
        allConstraints.appendContentsOf(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[current]-20-[chart]|",
                options: [],
                metrics: nil,
                views: views
            )
        )
        
        NSLayoutConstraint.activateConstraints(allConstraints)
        
    }
    
    //MARK: Reachability
    func setupReachability() {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            return
        }
        
        reachability?.whenReachable = { [weak self] reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self?.startFetchingData()
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func startFetchingData() {
        
        // Bind historical data to the chart
        viewModel.historicalRates
            .bindTo(chartView.rx_historicalRates)
            .addDisposableTo(disposeBag)
        
        // Bind current rate to the current rate view
        let currentRate = viewModel
            .currentRate
            .shareReplay(1)
        
        currentRate
            .bindTo(currentRateView.rx_rate)
            .addDisposableTo(disposeBag)
        
        // Bind current rate to graph to enable automatic graph updates
        currentRate
            .bindTo(chartView.rx_current)
            .addDisposableTo(disposeBag)
    }
    
    //MARK: View delegate methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)
        title = "Bitcoin26"
        
        prepareViews()
        setupViews()
        setupReachability()
        
        startFetchingData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//MARK: - UINavigationController extensions

extension UINavigationController {
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
