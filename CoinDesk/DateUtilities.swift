//
//  DateUtilities.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

/**
 Contains helper functions for managing `NSDate` instances
 */
public class DateUtilities {
    
    /// `NSDateTimeFormatter` used in date parsing of retrieved exchange rates
    public static var formatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    /// `NSCalenadar` associated with system calendar and `GMT` time zone.
    static var calendar: NSCalendar = {
        let sysCalendar = NSCalendar.currentCalendar()
        sysCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        return sysCalendar
    }()
    
    /**
     Strips time component from `NSDate`
     
     - parameter fromDate: date to strip time components from
     
     - returns: Stripped `NSDate`
     */
    public class func stripTime(fromDate date: NSDate) -> NSDate {
        let dateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: date)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        return calendar.dateFromComponents(dateComponents)!
    }
    
    /**
     Creates `NSDate` from string
     
     - parameter dateString: date string
     
     - returns: `NSDate`
     */
    public class func fromString(dateString: String) -> NSDate {
        return formatter.dateFromString(dateString)!
    }
    
    /**
     Computes number of days passed between two dates
     
     - parameter fromDateTime: start date
     - parameter toDateTime: end date
     
     - returns: Number of days passed
    */
    class func numberOfDays(fromDate fromDateTime: NSDate, toDateTime: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: fromDateTime)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.day
    }
}

extension DateUtilities {
    
    /// Returns date associated with today
    public class var today: NSDate {
        return stripTime(fromDate: NSDate())
    }
    
    public class var yesterday: NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.day = -1
        
        return calendar.dateByAddingComponents(dateComponents, toDate: today, options: [])!
    }
    
    /// Returns start date (today - 28 days)
    public class var startDate: NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.day = -Cache.length + 1
        
        return calendar.dateByAddingComponents(dateComponents, toDate: today, options: [])!
    }
}
