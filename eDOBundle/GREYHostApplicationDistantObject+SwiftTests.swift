//
//  GREYHostApplicationDistantObject+SwiftTests.swift
//  eDOBundle
//
//  Created by Szymon Kazmierczak on 06/07/2019.
//  Copyright © 2019 simonk. All rights reserved.
//
import Foundation
import UIKit

/// Class to check if particular named notification is received or not.
@objcMembers fileprivate class TextFieldNotificationRecorder: NSObject, TextFieldNotification {
    public var wasNotificationReceived = false
    
    /// Custom initializer with a notification name.
    /// - Parameters:
    ///   - notification: The name of the notification to be tracked for receipt.
    /// - Returns: A TextFieldNotificationRecorder object with the provided notification name.
    init(for notification: Notification.Name) {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationFired),
            name: notification,
            object: nil)
    }
    
    func notificationFired() {
        wasNotificationReceived = true
    }
}

/// Class to check if a UITextField element's editing events are received.
@objcMembers fileprivate class TextFieldEditingEventsRecorder: NSObject, TextFieldEditingEvents {
    #if swift(>=4.2)
    var trackedEvent: UIControl.Event!
    #else
    var trackedEvent: UIControlEvents!
    #endif
    public var wasEventReceived = false
    
    #if swift(>=4.2)
    init(for controlEvent: UIControl.Event) {
        super.init()
        trackedEvent = controlEvent
    }
    #else
    init(for controlEvent: UIControlEvents) {
        super.init()
        trackedEvent = controlEvent
    }
    #endif
    
    public func name() -> String {
        return "TextField Events Recorder"
    }
    
    public func perform(_ element: Any, error errorOrNil: UnsafeMutablePointer<NSError?>?) -> Bool {
        guard let control = element as? UIControl else {
            return false
        }
        grey_dispatch_sync_on_main_thread {
            control.addTarget(self, action: #selector(self.eventWasReceived), for: self.trackedEvent)
        }
        return true
    }
    
    public func eventWasReceived() {
        wasEventReceived = true
    }
}

extension GREYHostApplicationDistantObject: SwiftTestsHost {
    
    public func makeTextFieldNotificationRecorder(
        for notification: NSNotification.Name
        ) -> TextFieldNotification {
        return TextFieldNotificationRecorder(for: notification)
    }
    
    /// - Returns: A TextFieldEventsRecorder object that sets up observers for text field
    ///            editing events.
    #if swift(>=4.2)
    public func makeTextFieldEditingEventRecorder(
        for controlEvent: UIControl.Event
        ) -> TextFieldEditingEvents {
        return TextFieldEditingEventsRecorder(for: controlEvent)
    }
    #else
    public func makeTextFieldEditingEventRecorder(
        for controlEvent: UIControlEvents
        ) -> TextFieldEditingEvents {
        return TextFieldEditingEventsRecorder(for: controlEvent)
    }
    #endif
    
    public func makeFirstElementMatcher() -> GREYMatcher {
        var firstMatch = true
        let matches: GREYMatchesBlock = { _ in
            if firstMatch {
                firstMatch = false
                return true
            }
            return false
        }
        return GREYElementMatcherBlock(matchesBlock: matches) { description -> Void in
            description.appendText("first match")
        }
    }
    
    public func makeCheckHiddenAction() -> GREYAction {
        return GREYActionBlock.action(withName: "checkHiddenBlock") { element, errorOrNil in
            // Check if the found element is hidden or not.
            var isHidden = false
            guard let superView = element as? UIView else { return false }
            grey_dispatch_sync_on_main_thread {
                isHidden = !superView.isHidden
            }
            return isHidden
        }
    }
    
    public func resetNavigationStack() {
        guard let delegateWindow = UIApplication.shared.delegate?.window else { return }
        let navController: UINavigationController?
        if let navigationController = delegateWindow?.rootViewController as? UINavigationController {
            navController = navigationController
        } else {
            navController = delegateWindow?.rootViewController?.navigationController
        }
        _ = navController?.popToRootViewController(animated: true)
    }
}
