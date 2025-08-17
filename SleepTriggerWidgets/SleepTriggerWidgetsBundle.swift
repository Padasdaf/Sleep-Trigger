//
//  SleepTriggerWidgetsBundle.swift
//  SleepTriggerWidgets
//
//  Created by Daniel Hu on 2025-08-12.
//

import WidgetKit
import SwiftUI

@main
struct SleepTriggerWidgetsBundle: WidgetBundle {
    var body: some Widget {
        #if os(watchOS)
        SleepTriggerComplication_watchOS()
        #else
        SleepTriggerWidget_iOS()
        #endif
    }
}
