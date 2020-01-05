//
//  OgaHuntTests.swift
//  OgaHuntTests
//
//  Created by Humberto Aquino on 4/6/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import XCTest
import SwiftDate
import ObjectMapper
import CoreData

@testable import OgaHunt

class OgaHuntTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDateParsing() {
        let dateStr = "2018-08-30T16:15:55.102360"
        let date = dateStr.toISODate()?.date
        XCTAssertNotNil(date)

        let anotherDAteStr = "2018-09-12T19:19:48.502632"
//        let formatter = Formatter.iso8601
//        let res = formatter.date(from: anotherDAteStr)

        let date2 = anotherDAteStr.toISODate()?.date

        XCTAssertNotNil(date2)
        

    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
