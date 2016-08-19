//
//  RateViewModel.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation
import RxSwift
import CoinDesk

/// View model used in `RateViewController`
struct RateViewModel {
    
    /// Historic data
    var historicalRates: Observable<[ExchangeRate]>
    
    /// Live data
    var currentRate: Observable<ExchangeRate>
    
    init() {
        historicalRates = CoinDesk
            .rx_fetchHistorical()
            .observeOn(MainScheduler.instance)
            .catchErrorJustReturn([])
            .retry(3)
//            .debug("historical")
        
        currentRate = CoinDesk
            .rx_fetchCurrent()
            .observeOn(MainScheduler.instance)
            .distinctUntilChanged { $0.euroValue == $1.euroValue }
            .retry(3)
//            .debug("current")
    }
}
