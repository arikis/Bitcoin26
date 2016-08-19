//
//  rx_timer.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import RxSwift

/**
 Provides a `Observable` wrapper around GCD dispatch timer.
*/
func rx_timer(interval: NSTimeInterval) -> Observable<Int> {
    return Observable.create { observer in
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        
        var next = 0
        
        dispatch_source_set_timer(timer, 0, UInt64(interval * Double(NSEC_PER_SEC)), 0)
        
        let cancel = AnonymousDisposable {
            dispatch_source_cancel(timer)
        }
        
        dispatch_source_set_event_handler(timer, {
            if cancel.disposed {
                return
            }
            observer.on(.Next(next))
            next += 1
        })
        
        dispatch_resume(timer)
        
        return cancel
    }
}
