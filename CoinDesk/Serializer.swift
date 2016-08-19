//
//  Serializer.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

public enum SerializerError: ErrorType {
    case InvalidDataReturnedFromServer
}

/**
 Provides interface for serializing `JSON` reponses from CoinDesk API
*/
class Serializer {
    
    /**
     Serializes historical data returned from the server into `[Rate]` array.
     
     - parameter data: raw `NSData` returned from the server
     
     - returns: [ExchangeRate] array
     */
    class func parseHistoricalData(data: NSData) throws -> [ExchangeRate] {
        do {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: [.AllowFragments])
            
            guard let dictionaryData = jsonData as? [String: AnyObject] else {
                throw SerializerError.InvalidDataReturnedFromServer
            }
            
            guard let bpi = dictionaryData["bpi"] as? [String: Double] else {
                throw SerializerError.InvalidDataReturnedFromServer
            }
            
            let rates = bpi.map { ExchangeRate.createNew(DateUtilities.fromString($0), euroValue: $1) }
            
            return rates
        } catch {
            throw error
        }
    }
    
    /**
     Serializes live data returned from the server.
     
     - parameter data: Raw `NSData` from the server
     
     - returns: `ExchangeRate` instance
    */
    class func parseCurrentData(data: NSData) throws -> ExchangeRate {
        do {
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: [.AllowFragments])
            
            guard let dictionaryData = jsonData as? [String: AnyObject] else {
                throw SerializerError.InvalidDataReturnedFromServer
            }
            
            guard let bpi = dictionaryData["bpi"] as? [String: AnyObject] else {
                throw SerializerError.InvalidDataReturnedFromServer
            }
            
            guard let EURData = bpi["EUR"] as? [String: AnyObject] else {
                throw SerializerError.InvalidDataReturnedFromServer
            }
            
            guard let rate = EURData["rate_float"] as? Double else {
                throw SerializerError.InvalidDataReturnedFromServer
            }
            
            return ExchangeRate.createNew(euroValue: rate)
            
        } catch {
            throw error
        }
    }
}
