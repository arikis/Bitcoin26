//
//  CoinDeskRequest.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

//MARK: - CoinDeskRequestType protocol

/**
 Structures adopting this protocol can be used to create network requests
 for CoinDesk API
*/
protocol CoinDeskRequestType {
    var url: NSURL { get }
}

//MARK: - CoinDeskHistoricalDataRequest implementation

/// Historical data request
class CoinDeskHistoricalDataRequest: CoinDeskRequestType, CustomStringConvertible {
    
    /// Start date, passed to the API
    let startDate: NSDate
    
    /// End date, passed to the API
    let endDate: NSDate
    
    init(startDate: NSDate, endDate: NSDate) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var url: NSURL {
        let baseURL = NSURLComponents(string: "https://api.coindesk.com/v1/bpi/historical/close.json")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDateString = dateFormatter.stringFromDate(startDate)
        let endDateString = dateFormatter.stringFromDate(endDate)
        
        baseURL?.queryItems = [
            NSURLQueryItem(name: "start", value: startDateString),
            NSURLQueryItem(name: "end", value: endDateString)
        ]
        
        return baseURL!.URL!
    }
    
    var description: String {
        return url.absoluteString
    }
}

//MARK: - CoinDeskCurrentDataRequest implementation

/// CoinDesk current data request
class CoinDeskCurrentDataRequest: CoinDeskRequestType, CustomStringConvertible {
    var url: NSURL {
        return NSURL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
    }
    
    var description: String {
        return url.absoluteString
    }
}
