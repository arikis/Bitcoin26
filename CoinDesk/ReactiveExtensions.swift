//
//  ReactiveExtensions.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import RxSwift
import RealmSwift


extension CoinDesk {
    
    /**
     Reactive wrapper for `fetchHistorical(_:)` method on Self. Fetches historical
     data from CoinDesk API
     
     - returns: Observable sequence of `ExchangeRate` array
     */
    public class func rx_fetchHistorical() -> Observable<[ExchangeRate]> {
        return Observable.create { observer in
            
            // Fetch historical data from CoinDesk API
            self.fetchHistorical { rates, error in
                if let rates = rates {
                    observer.onNext(rates)
                }
                
                if let error = error {
                    observer.onError(error)
                    observer.onCompleted()
                }
            }
            
            return AnonymousDisposable {
            }
        }
    }
    
    /**
     Reactive wrapper for `fetchCurrent(_:)` method on Self. Fetches current
     exchange rate from CoinDesk API.
     
     - returns: Observable sequence of `ExchangeRate`
     */
    public class func rx_fetchCurrent() -> Observable<ExchangeRate> {
        return Observable.create { observer in
            let timerSubscription = rx_timer(60)
                .subscribeNext { _ in
                    
                    // Fetch current using CoinDesk API
                    self.fetchCurrent { rate, error in
                        if let rate = rate {
                            observer.onNext(rate)
                        }
                        
                        // If there is an error with network request pass the latest object from cache
                        if let _ = error {
                            let latest = rx_fetchLatest()
                                .observeOn(MainScheduler.instance)
                            
                            latest.subscribe(observer)
                        }
                    }
            }
            
            return AnonymousDisposable {
                timerSubscription.dispose()
            }
        }
    }
    
    /**
     Fetches latests `ExchangeRate` from the cache
     
     - returns: `Observable<ExchangeRate>`
    */
    public class func rx_fetchLatest() -> Observable<ExchangeRate> {
        return Observable.create { observer in
            
            // Dispatch to main queue to ensure Realm thread safety
            DispatchQueue.dispatchToMainQueue {
                do {
                    let realm = try Realm()
                    let latest = realm
                        .objects(ExchangeRate)
                        .sorted("rateID", ascending: true)
                        .last
                    
                    if let latest = latest {
                        observer.onNext(latest)
                    } else {
                        observer.onError(CacheError.CacheEmpty)
                        observer.onCompleted()
                    }
                } catch {
                    observer.onError(error)
                }
            }
            
            return AnonymousDisposable {
            }
        }
    }
}
