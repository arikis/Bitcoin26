//
//  Cache.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import RxSwift
import RealmSwift

/**
 Defines errors that can occur while using some caching operations.
*/
public enum CacheError: ErrorType {
    
    /// Cache is empty
    case CacheEmpty
}

/**
 Provides top level interface for some Realm caching operations.
*/
class Cache {
    
    /// Number of days that stay in the local cache
    static let length = 28
    
    /**
     Retrieves all exchange rates from cache
     
     - throws: CacheError
     
     - returns: Array of `ExchangeRate` objects
    */
    class func fetchAll() throws -> [ExchangeRate] {
        do {
            let realm = try Realm()
            
            let objects = realm
                .objects(ExchangeRate)
                .sorted("rateID", ascending: true)
            
            let startDate = objects.first?.date
            let endDate = objects.last?.date
            
            if let startDate = startDate, endDate = endDate {
                let difference = DateUtilities.numberOfDays(fromDate: startDate, toDateTime: endDate)
                
                // If the difference is 28 days or less, just return the result
                if difference <= length {
                    return objects.map { $0 }
                }
                
                // If the difference is greater that 28 days, that means that we have some
                // objects that need to be deleted
                if difference > length {
                    let removeOldRatesPredicate = NSPredicate(format: "date <= %@", DateUtilities.startDate)
                    let oldRates = objects.filter(removeOldRatesPredicate)
                    
                    try realm.write {
                        realm.delete(oldRates)
                    }
                }
            }
            
            return objects.map { $0 }
        } catch {
            throw error
        }
    }
    
    /**
     Saves single `ExchangeRate` object to the cache.
     
     - parameter rate: ExchangeRate object to be saved
     
     - throws: RealmError
    */
    class func save(rate rate: ExchangeRate) throws {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(rate, update: true)
            }
        } catch {
            throw error
        }
    }
    
    /**
     Saves an array of `ExchangeRate` objects to the cache.
     
     - parameter rates: `ExchangeRate` array
     
     - throws: RealmError
    */
    class func save(rates rates: [ExchangeRate]) throws {
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(rates, update: true)
            }
        } catch {
            throw error
        }
    }
}
