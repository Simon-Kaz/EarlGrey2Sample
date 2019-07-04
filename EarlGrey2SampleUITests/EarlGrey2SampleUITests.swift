//
//  EarlGrey2SampleUITests.swift
//  EarlGrey2SampleUITests
//
//  Created by Szymon Kazmierczak on 04/07/2019.
//  Copyright © 2019 simonk. All rights reserved.
//

import XCTest

class EarlGrey2SampleUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSample() {
        EarlGrey.selectElement(with: grey_keyWindow())
            .perform(grey_tap())
        EarlGrey.selectElement(with: grey_accessibilityID("text_label"))
            .assert(grey_text("Just A Label"))
        EarlGrey.selectElement(with: grey_accessibilityID("switch"))
            .perform(grey_turnSwitchOn(true))
            .assert(grey_switchWithOnState(true))
            .perform(grey_turnSwitchOn(false))
            .assert(grey_switchWithOnState(false))
    }

}
