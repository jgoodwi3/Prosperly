//
//  SharedModels.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import Foundation
import SwiftUI

// MARK: - Shared Enums

public enum PayFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biWeekly = "Bi-Weekly"
    case monthly = "Monthly"
    
    public var multiplier: Double {
        switch self {
        case .daily: return 365
        case .weekly: return 52
        case .biWeekly: return 26
        case .monthly: return 12
        }
    }
    
    public var displayName: String {
        return self.rawValue
    }
}

// MARK: - Filter Enums for Enhanced Views

public enum FilterPriority: String, CaseIterable {
    case all = "All"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

public enum FilterInsightType: String, CaseIterable {
    case all = "All"
    case spending = "Spending"
    case budget = "Budget"
    case savings = "Savings"
    case trend = "Trend"
    case alert = "Alert"
    case opportunity = "Opportunity"
    case achievement = "Achievement"
    case warning = "Warning"
} 