//
//  CoinDeskTests.swift
//  CoinDeskTests
//
//  Created by Said Sikira on 8/16/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import CoinDesk
import RealmSwift

class CoinDeskAPITests: XCTestCase {
    
    func testHistoricDataRetrieval() {
        let fetchExpecation = expectationWithDescription("Fetch historic data expecation")
        
        CoinDesk.fetchHistorical {
            rates, error in
            
            XCTAssert(error == nil, "Error presented while fetching data \(error)")
            
            if let _ = rates {
                fetchExpecation.fulfill()
            } else {
                XCTFail("Rates not available")
            }
        }
        
        waitForExpectationsWithTimeout(1) { handlerError in
            print(handlerError)
        }
    }
}
