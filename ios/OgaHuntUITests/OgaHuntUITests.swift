//
//  OgaHuntUITests.swift
//  OgaHuntUITests
//
//  Created by Humberto Aquino on 4/6/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import XCTest

class OgaHuntUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let settings = app.tabBars.buttons["Settings"]
        if settings.exists {
            settings.tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Logout"]/*[[".cells.staticTexts[\"Logout\"]",".staticTexts[\"Logout\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }

        snapshot("0Launch")

        let emailTextField = app.textFields["Email"]
        emailTextField.tap()

        let clearText = app.buttons["Clear text"]
        if clearText.exists {
            clearText.tap()
        }
        emailTextField.typeText("humber+review@ogahunt.com")

        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123456")

        let signInButton = app.buttons["Sign in"]
        signInButton.tap()

        sleep(10)
//        let exists = NSPredicate(format: "exists == 1")
//        expectation(for: exists, evaluatedWith: tablesQuery, handler: nil)
//        waitForExpectations(timeout: 10, handler: nil)

        snapshot("1List")
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier:"Great apartment with a view").children(matching: .textView).element.tap()

//        app.navigationBars["Great apartment with view"].buttons["Hunt list"].tap()

        snapshot("2ViewElement")
//        let textView = tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Land with beautiful garden")/*[[".cells.containing(.staticText, identifier:\"land\")",".cells.containing(.staticText, identifier:\"$490,000\")",".cells.containing(.staticText, identifier:\"Land with beautiful garden\")"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .textView).element
//        textView.swipeLeft()
//        snapshot("3ListOptions")
//        app/*@START_MENU_TOKEN@*/.tables.containing(.button, identifier:"Delete").element/*[[".tables.containing(.button, identifier:\"Assign\").element",".tables.containing(.button, identifier:\"Archive\").element",".tables.containing(.button, identifier:\"Delete\").element"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        textView.tap()

        app.scrollViews.otherElements.buttons["Map"].tap()
        snapshot("4OptionsMap")
        app.tabBars.buttons["Activities"].tap()
        snapshot("5Events")

    }

    
}
