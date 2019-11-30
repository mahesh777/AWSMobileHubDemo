//
//  AnalyticsHelper.swift
//  AWSMobileHubDemo
//
//  Created by Mahesh Sonaiya on 21/07/19.
//  Copyright © 2019 Mahesh Sonaiya. All rights reserved.
//

import Foundation
import AWSPinpoint

class AnalyticsHelper {
    // MARK: Static Shared Instance
    static let shared = AnalyticsHelper()
    
    // MARK: pinpoint variable
    private var pinpoint: AWSPinpoint?
    
    private init() {
        
    }
    
    // MARK: Setup AWS Pin Point
    func setupAWSPinPoint(withLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        pinpoint = AWSPinpoint(configuration:
            AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions))
    }
    
    // MARK: Record Events
    func recordEvent(eventName: String,
                attributes: [String: String]? = nil,
                metrics: [String: NSNumber]? = nil)
    {
        // Get PinPoint Instance
        guard let pinpoint = pinpoint else { return }
        
        // Create Event
        let event = pinpoint.analyticsClient.createEvent(withEventType: eventName)
        
        // Create Event Attributes
        if let eventAttributes = attributes {
            for (key, attributeValue) in eventAttributes {
                event.addAttribute(attributeValue, forKey: key)
            }
        }
        
        // Create Event Metrics
        if let eventMetrics = metrics {
            for (key, metricValue) in eventMetrics {
                event.addMetric(metricValue, forKey: key)
            }
        }
        
        // record event
        pinpoint.analyticsClient.record(event)
        
        // upload events
        pinpoint.analyticsClient.submitEvents { (task) -> Any? in
            print("Event Recorded - \(eventName)")
            if let eventAttributes = attributes {
                print("Event Attributes - \(eventAttributes.description)")
            }
            if let eventMetrics = metrics {
                print("Event metrics - \(eventMetrics.description)")
            }
            return task
        }
    }
}
