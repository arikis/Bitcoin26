//
//  ExchangeRate.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSDate
import class Foundation.NSDateFormatter

import RealmSwift

//MARK: - Model

public class ExchangeRate: Object {
    
    /// Rate ID, derived from the date string
    public dynamic var rateID = ""
    
    /// Exchange rate date
    public dynamic var date = DateUtilities.today
    
    /// Euro value
    public dynamic var euroValue = 0.0
    
    override public class func primaryKey() -> String {
        return "rateID"
    }
}

//MARK: - Creation
extension ExchangeRate {
    
    /**
     Creates new instance of `ExchangeRate`
     
     - parameter date: Exchange rate date
     - parameter euroValue: Euro value associated with rate
     
     - returns: ExchangeRate instance
    */
    public class func createNew(date: NSDate = DateUtilities.today, euroValue: Double) -> ExchangeRate {
        let rate = ExchangeRate()
        rate.date = DateUtilities.stripTime(fromDate: date)
        rate.euroValue = euroValue
        
        rate.rateID = DateUtilities.formatter.stringFromDate(date)
        
        return rate
    }
}
