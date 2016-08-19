//
//  Dispatch.swift
//  Bitcoin26
//
//  Created by Said Sikira on 7/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/// Provides simple interface for dispatch call
class DispatchQueue {
    
    /// Dispatches block of code to the main queue
    class func dispatchToMainQueue(completion: (Void -> ())) {
        dispatch_async(dispatch_get_main_queue(), completion)
    }
}
