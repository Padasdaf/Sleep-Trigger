//
//  AutomationItem.swift
//  SleepTrigger
//
//  Created by Daniel Hu on 2025-08-12.
//

import Foundation

struct AutomationItem: Identifiable, Codable, Equatable {
    var id: UUID = .init()
    var name: String
    var enabled: Bool = true
    var delaySeconds: Int = 0          // delay before running, in seconds
    var isMaster: Bool = false         // if true, this one runs alone
}
