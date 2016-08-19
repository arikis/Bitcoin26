//
//  CoinDesk.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

/**
 Provides API interface for the most common **CoinDesk API** requests.
 
 `CoinDesk` class contains both regular Swift APIs with completion blocks 
 and reactive extensions that return `Observable` sequences.
*/
public class CoinDesk {
    
    /// `NSURLSession` instance used when executing network tasks
    public static var session: NSURLSession = {
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        return NSURLSession(configuration: configuration)
    }()
    
    /**
     Fetch historical data from CoinDesk API.
     
     - parameter completion: Completion block that executes after API request finishes. Completion takes
     two arguments.
     * rates - optional array of `ExchangeRate`
     * error - optional error
     */
    public class func fetchHistorical(completion: (rates: [ExchangeRate]?, error: ErrorType?) -> ()) {
        
        var endDate: NSDate?
        var startDate: NSDate?
        
        do {
            /// Fetch all cached rates and execute completion
            let cachedRates = try Cache.fetchAll()
            
            startDate = cachedRates.first?.date
            endDate = cachedRates.last?.date
            
            completion(rates: cachedRates, error: nil)
        } catch {
            completion(rates: nil, error: error)
        }
        
        
        if let startDate = startDate, endDate = endDate {
            // If start date is not equal to end date, and the end date is equal to today
            // we can just return from the function
            if !startDate.isEqualToDate(endDate) && endDate.isEqualToDate(DateUtilities.today) {
                return
            }
        }
        
        // Create request
        let requestURL = CoinDeskHistoricalDataRequest(
            startDate: endDate ?? DateUtilities.startDate,
            endDate: DateUtilities.today)
        
        let request = NSMutableURLRequest(URL: requestURL.url)
        
        request.setValue("application/json",
                         forHTTPHeaderField: "Content-Type")
        
        // Setup task completion block
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                completion(rates: nil, error: error!)
                return
            } else {
                do {
                    let rates = try Serializer.parseHistoricalData(data!)
                    let sorted = rates.sort { $0.date.compare($1.date) == NSComparisonResult.OrderedAscending }
                    
                    completion(rates: sorted, error: nil)
                    
                    /// Calls to the `Realm.write(_:)` must be dispatched to the main queue
                    DispatchQueue.dispatchToMainQueue {
                        _ = try? Cache.save(rates: rates)
                    }
                } catch {
                    completion(rates: nil, error: error)
                }
            }
        }
        
        task.resume()
    }
    
    /**
     Fetch current live data from CoinDesk API.
     
     - parameter completion: Completion block that executes after API network request is finished.
     Takes two arguments:
     * rate - optional `ExchangeRate`
     * error - optional error
     */
    public class func fetchCurrent(completion: (rate: ExchangeRate?, error: ErrorType?) -> ()) {
        let requestURL = CoinDeskCurrentDataRequest()
        let request = NSMutableURLRequest(URL: requestURL.url)
        
        request.setValue("application/json",
                         forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                completion(rate: nil, error: error!)
                return
            } else {
                
                do {
                    let currentRate = try Serializer.parseCurrentData(data!)
                    completion(rate: currentRate, error: nil)
                    
                    /// Calls to the Realm.write must be dispatched to the main queue
                    DispatchQueue.dispatchToMainQueue {
                        _ = try? Cache.save(rate: currentRate)
                    }
                } catch {
                    completion(rate: nil, error: error)
                }
            }
        }
        
        task.resume()
    }
}
