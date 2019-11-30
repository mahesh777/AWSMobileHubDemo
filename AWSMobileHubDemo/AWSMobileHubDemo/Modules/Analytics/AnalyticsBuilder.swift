//
//  AnalyticsBuilder.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 21/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import Foundation

class AnalyticsBuilder {
    private var _eventAttributes: [String : String]?
    private var _eventMetrics: [String: NSNumber]?
    private var _eventName: String?
    
    // MARK:- Init Analytics Builder
    init(withEventName: String) {
        _eventName = withEventName
    }
    
    // MARK:- Add Property
    func addProperty(propertyName: String,
                     propertyValue: String) -> AnalyticsBuilder {
        if _eventAttributes == nil {
            _eventAttributes = [:]
            _eventAttributes?[propertyName] = propertyValue
        } else {
            _eventAttributes?[propertyName] = propertyValue
        }
        return self
    }
    
    // MARK:- Add Property
    func addMetric(propertyName: String,
                     propertyValue: NSNumber) -> AnalyticsBuilder {
        if _eventMetrics == nil {
            _eventMetrics = [:]
            _eventMetrics?[propertyName] = propertyValue
        } else {
            _eventMetrics?[propertyName] = propertyValue
        }
        return self
    }
    
    // MARK: MS:- Build Analytics Event
    func build() {
        if let eventName = _eventName {
            AnalyticsHelper.shared.recordEvent(eventName: eventName,
                                               attributes: _eventAttributes,
                                               metrics: _eventMetrics)
        } else {
            print("\(_eventName ?? "Nil Event") is not logged.")
        }
    }
}
