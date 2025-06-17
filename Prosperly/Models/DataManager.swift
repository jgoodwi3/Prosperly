//
//  DataManager.swift
//  Prosperly
//
//  Created by Jeff Goodwin on 5/30/25.
//

import Foundation
import SwiftUI
import UserNotifications

// MARK: - Enhanced Model Types (Included for compilation compatibility)

// Enhanced expense item with additional features
public struct EnhancedExpenseItem: Identifiable, Codable {
    public let id: UUID
    public let amount: Double
    public let category: String
    public let notes: String?
    public let date: Date
    public let isRecurring: Bool
    public let recurringFrequency: RecurringFrequency?
    public let tags: [String]
    public let merchant: String?
    public let paymentMethod: PaymentMethod
    
    public init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        notes: String? = nil,
        date: Date = Date(),
        isRecurring: Bool = false,
        recurringFrequency: RecurringFrequency? = nil,
        tags: [String] = [],
        merchant: String? = nil,
        paymentMethod: PaymentMethod = .cash
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.notes = notes
        self.date = date
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.tags = tags
        self.merchant = merchant
        self.paymentMethod = paymentMethod
    }
}

// Enhanced budget with category support and alerts
public struct EnhancedBudget: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let amount: Double
    public let period: BudgetPeriod
    public let category: String?
    public let isActive: Bool
    public let alertThreshold: Double
    public let color: String
    public let startDate: Date
    public let endDate: Date?
    public let rollover: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        period: BudgetPeriod,
        category: String? = nil,
        isActive: Bool = true,
        alertThreshold: Double = 90.0,
        color: String = "#4CAF50",
        startDate: Date = Date(),
        endDate: Date? = nil,
        rollover: Bool = false
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.period = period
        self.category = category
        self.isActive = isActive
        self.alertThreshold = alertThreshold
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
        self.rollover = rollover
    }
}

// Enhanced savings goal with milestones and categories
public struct EnhancedSavingsGoal: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let targetAmount: Double
    public var currentAmount: Double
    public let targetDate: Date?
    public let category: GoalCategory
    public let priority: GoalPriority
    public let createdAt: Date
    public let completedAt: Date?
    public let isActive: Bool
    public let milestones: [SavingsGoalMilestone]
    public let color: String
    public let automaticContributions: AutomaticContribution?
    
    public var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    public var isCompleted: Bool {
        return currentAmount >= targetAmount
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        targetDate: Date? = nil,
        category: GoalCategory = .general,
        priority: GoalPriority = .medium,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        isActive: Bool = true,
        milestones: [SavingsGoalMilestone] = [],
        color: String = "#2196F3",
        automaticContributions: AutomaticContribution? = nil
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.category = category
        self.priority = priority
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.isActive = isActive
        self.milestones = milestones
        self.color = color
        self.automaticContributions = automaticContributions
    }
}

// Recurring transaction support
public struct RecurringTransaction: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let amount: Double
    public let category: String
    public let frequency: RecurringFrequency
    public let type: TransactionType
    public let startDate: Date
    public let endDate: Date?
    public let isActive: Bool
    public let lastProcessed: Date?
    public let nextDue: Date
    public let tags: [String]
    public let notes: String?
    
    public init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        category: String,
        frequency: RecurringFrequency,
        type: TransactionType,
        startDate: Date = Date(),
        endDate: Date? = nil,
        isActive: Bool = true,
        lastProcessed: Date? = nil,
        tags: [String] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.category = category
        self.frequency = frequency
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.lastProcessed = lastProcessed
        self.nextDue = frequency.nextDate(from: startDate)
        self.tags = tags
        self.notes = notes
    }
}

// Financial insight data
public struct FinancialInsight: Identifiable, Codable {
    public let id: UUID
    public let type: InsightType
    public let title: String
    public let description: String
    public let value: String
    public let trend: TrendDirection
    public let priority: InsightPriority
    public let actionable: Bool
    public let category: String
    public let createdAt: Date
    
    public init(type: InsightType, title: String, description: String, value: String, trend: TrendDirection, priority: InsightPriority, actionable: Bool, category: String) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.description = description
        self.value = value
        self.trend = trend
        self.priority = priority
        self.actionable = actionable
        self.category = category
        self.createdAt = Date()
    }
}

public struct BudgetAlert: Identifiable, Codable {
    public let id: UUID
    public let type: AlertType
    public let severity: AlertSeverity
    public let message: String
    public let budgetId: UUID?
    public let createdAt: Date
    public let isRead: Bool
    public let actionTaken: Bool
    
    public init(type: AlertType, severity: AlertSeverity, message: String, budgetId: UUID? = nil, isRead: Bool = false, actionTaken: Bool = false) {
        self.id = UUID()
        self.type = type
        self.severity = severity
        self.message = message
        self.budgetId = budgetId
        self.createdAt = Date()
        self.isRead = isRead
        self.actionTaken = actionTaken
    }
}

public struct UserSettings: Codable {
    public var isDarkMode: Bool = false
    public var notificationsEnabled: Bool = true
    public var biometricEnabled: Bool = false
    public var currencySymbol: String = "$"
    public var monthlyBudgetReminders: Bool = true
    public var onboardingCompletedAt: Date?
    
    public init() {}
}

// MARK: - Supporting Enums

public enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case biWeekly = "Bi-Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
}

public enum GoalCategory: String, CaseIterable, Codable {
    case emergency = "Emergency Fund"
    case vacation = "Vacation"
    case house = "House/Property"
    case car = "Vehicle"
    case education = "Education"
    case retirement = "Retirement"
    case wedding = "Wedding"
    case general = "General"
    
    public var icon: String {
        switch self {
        case .emergency: return "shield.fill"
        case .vacation: return "airplane"
        case .house: return "house.fill"
        case .car: return "car.fill"
        case .education: return "book.fill"
        case .retirement: return "person.crop.circle.fill"
        case .wedding: return "heart.fill"
        case .general: return "target"
        }
    }
    
    public var color: String {
        switch self {
        case .emergency: return "#FF5722"
        case .vacation: return "#2196F3"
        case .house: return "#4CAF50"
        case .car: return "#FF9800"
        case .education: return "#9C27B0"
        case .retirement: return "#607D8B"
        case .wedding: return "#E91E63"
        case .general: return "#795548"
        }
    }
}

public enum GoalPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

public enum RecurringFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biWeekly = "Bi-Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    public func nextDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .biWeekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}

public enum TransactionType: String, CaseIterable, Codable {
    case income = "Income"
    case expense = "Expense"
}

public enum InsightType: String, CaseIterable, Codable {
    case spending = "Spending"
    case budget = "Budget"
    case savings = "Savings"
    case trend = "Trend"
    case alert = "Alert"
    case opportunity = "Opportunity"
    case achievement = "Achievement"
    case warning = "Warning"
}

public enum TrendDirection: String, CaseIterable, Codable {
    case up = "Up"
    case down = "Down"
    case stable = "Stable"
}

public enum InsightPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
}

public enum AlertType: String, CaseIterable, Codable {
    case budgetExceeded = "Budget Exceeded"
    case budgetWarning = "Budget Warning"
    case goalAchieved = "Goal Achieved"
    case recurringDue = "Recurring Payment Due"
    case unusualSpending = "Unusual Spending"
}

public enum AlertSeverity: String, CaseIterable, Codable {
    case info = "Info"
    case warning = "Warning"
    case critical = "Critical"
}

public enum PaymentMethod: String, CaseIterable, Codable {
    case cash = "Cash"
    case credit = "Credit Card"
    case debit = "Debit Card"
    case bankTransfer = "Bank Transfer"
    case paypal = "PayPal"
    case venmo = "Venmo"
    case applePay = "Apple Pay"
    case other = "Other"
}

// MARK: - Supporting Structures

public struct SavingsGoalMilestone: Identifiable, Codable {
    public let id: UUID
    public let amount: Double
    public let description: String
    public let isCompleted: Bool
    public let completedAt: Date?
    
    public init(
        id: UUID = UUID(),
        amount: Double,
        description: String,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.amount = amount
        self.description = description
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}

public struct AutomaticContribution: Codable {
    public let amount: Double
    public let frequency: RecurringFrequency
    public let nextContribution: Date
    public let isActive: Bool
    
    public init(amount: Double, frequency: RecurringFrequency, nextContribution: Date, isActive: Bool) {
        self.amount = amount
        self.frequency = frequency
        self.nextContribution = nextContribution
        self.isActive = isActive
    }
}

public enum SavingsEntryType: String, CaseIterable, Codable {
    case addition = "Addition"
    case removal = "Removal"
    
    public var icon: String {
        switch self {
        case .addition: return "plus.circle.fill"
        case .removal: return "minus.circle.fill"
        }
    }
    
    public var color: String {
        switch self {
        case .addition: return "#4CAF50" // Green
        case .removal: return "#FF9800" // Orange
        }
    }
}

public struct SavingsEntry: Identifiable, Codable {
    public let id: UUID
    public let goalId: UUID
    public let amount: Double
    public let type: SavingsEntryType
    public let date: Date
    public let notes: String?
    
    public init(
        id: UUID = UUID(),
        goalId: UUID,
        amount: Double,
        type: SavingsEntryType = .addition,
        date: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.goalId = goalId
        self.amount = amount
        self.type = type
        self.date = date
        self.notes = notes
    }
}

// MARK: - Enhanced Analytics Classes

// Enhanced Analytics Tracker with local persistence
public class SimpleAnalyticsTracker: ObservableObject {
    @Published public var events: [AnalyticsEventData] = []
    private let persistenceKey = "ProsperlyAnalyticsEvents"
    
    public init() {
        loadPersistedEvents()
    }
    
    public func track(event: String, category: String, properties: [String: Any]? = nil) {
        let analyticsEvent = AnalyticsEventData(
            eventName: event,
            category: category,
            properties: properties,
            timestamp: Date()
        )
        events.append(analyticsEvent)
        persistEvents()
        print("📊 Analytics: \(event) - \(category) - \(properties ?? [:])")
    }
    
    public func trackScreenView(_ screenName: String) {
        track(event: "screen_viewed", category: "navigation", properties: ["screen_name": screenName])
    }
    
    public func trackOnboardingStep(_ step: String) {
        track(event: "onboarding_step_completed", category: "onboarding", properties: ["step": step])
    }
    
    private func persistEvents() {
        if events.count > 1000 {
            events = Array(events.suffix(1000))
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(events)
            UserDefaults.standard.set(data, forKey: persistenceKey)
        } catch {
            print("❌ Failed to persist analytics events: \(error)")
        }
    }
    
    func loadPersistedEvents() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey) else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            events = try decoder.decode([AnalyticsEventData].self, from: data)
        } catch {
            print("❌ Failed to load persisted analytics events: \(error)")
            events = []
        }
    }
    
    public func clearEvents() {
        events.removeAll()
        UserDefaults.standard.removeObject(forKey: persistenceKey)
    }
}

// Enhanced Analytics Event Data Structure
public struct AnalyticsEventData: Codable, Identifiable {
    public let id: UUID
    public let eventName: String
    public let category: String
    public let properties: [String: String]?
    public let timestamp: Date
    
    public init(eventName: String, category: String, properties: [String: Any]?, timestamp: Date) {
        self.id = UUID()
        self.eventName = eventName
        self.category = category
        self.timestamp = timestamp
        
        if let props = properties {
            var stringProps: [String: String] = [:]
            for (key, value) in props {
                stringProps[key] = String(describing: value)
            }
            self.properties = stringProps.isEmpty ? nil : stringProps
        } else {
            self.properties = nil
        }
    }
}

// MARK: - Enhanced Data Manager

public class EnhancedDataManager: ObservableObject {
    public static let shared = EnhancedDataManager()
    
    @Published public var enhancedExpenses: [EnhancedExpenseItem] = []
    @Published public var enhancedBudgets: [EnhancedBudget] = []
    @Published public var enhancedSavingsGoals: [EnhancedSavingsGoal] = []
    @Published public var savingsEntries: [SavingsEntry] = []
    @Published public var recurringTransactions: [RecurringTransaction] = []
    @Published public var budgetAlerts: [BudgetAlert] = []
    @Published public var financialInsights: [FinancialInsight] = []
    
    private let persistenceKeys = [
        "expenses": "ProsperlyEnhancedExpenses",
        "budgets": "ProsperlyEnhancedBudgets", 
        "goals": "ProsperlyEnhancedGoals",
        "savings_entries": "ProsperlySavingsEntries",
        "recurring": "ProsperlyRecurringTransactions",
        "alerts": "ProsperlyBudgetAlerts"
    ]
    
    private let notificationManager = NotificationManager()
    
    private init() {
        // Clear any existing data to ensure fresh start for users
        resetAllData()
        loadAllData()
        generateInsights()
    }
    
    // MARK: - Enhanced Expense Management
    
    public func addExpense(_ expense: EnhancedExpenseItem) {
        enhancedExpenses.append(expense)
        persistData(key: "expenses", data: enhancedExpenses)
        checkBudgetAlerts(for: expense)
        generateInsights()
        
        if expense.isRecurring {
            processRecurringExpense(expense)
        }
    }
    
    public func updateExpense(_ expense: EnhancedExpenseItem) {
        if let index = enhancedExpenses.firstIndex(where: { $0.id == expense.id }) {
            enhancedExpenses[index] = expense
            persistData(key: "expenses", data: enhancedExpenses)
            generateInsights()
        }
    }
    
    public func deleteExpense(_ expense: EnhancedExpenseItem) {
        enhancedExpenses.removeAll { $0.id == expense.id }
        persistData(key: "expenses", data: enhancedExpenses)
        generateInsights()
    }
    
    public func getExpensesByCategory() -> [String: [EnhancedExpenseItem]] {
        return Dictionary(grouping: enhancedExpenses, by: { $0.category })
    }
    
    public func getExpensesByMonth() -> [Date: [EnhancedExpenseItem]] {
        let calendar = Calendar.current
        return Dictionary(grouping: enhancedExpenses) { expense in
            calendar.dateInterval(of: .month, for: expense.date)?.start ?? expense.date
        }
    }
    
    // MARK: - Enhanced Budget Management
    
    public func addBudget(_ budget: EnhancedBudget) {
        enhancedBudgets.append(budget)
        persistData(key: "budgets", data: enhancedBudgets)
        generateInsights()
    }
    
    public func updateBudget(_ budget: EnhancedBudget) {
        if let index = enhancedBudgets.firstIndex(where: { $0.id == budget.id }) {
            enhancedBudgets[index] = budget
            persistData(key: "budgets", data: enhancedBudgets)
            generateInsights()
        }
    }
    
    public func deleteBudget(_ budget: EnhancedBudget) {
        enhancedBudgets.removeAll { $0.id == budget.id }
        persistData(key: "budgets", data: enhancedBudgets)
        generateInsights()
    }
    
    public func getBudgetUtilization(for budget: EnhancedBudget) -> BudgetUtilization {
        let relevantExpenses = enhancedExpenses.filter { expense in
            if let budgetCategory = budget.category {
                return expense.category == budgetCategory
            }
            return true
        }
        
        let spent = relevantExpenses.reduce(0) { $0 + $1.amount }
        let utilization = budget.amount > 0 ? (spent / budget.amount) * 100 : 0
        
        return BudgetUtilization(
            budget: budget,
            amountSpent: spent,
            utilizationPercentage: utilization,
            isOverBudget: spent > budget.amount
        )
    }
    
    // MARK: - Enhanced Savings Goals Management
    
    public func addSavingsGoal(_ goal: EnhancedSavingsGoal) {
        enhancedSavingsGoals.append(goal)
        persistData(key: "goals", data: enhancedSavingsGoals)
        generateInsights()
    }
    
    public func updateSavingsGoal(_ goal: EnhancedSavingsGoal) {
        if let index = enhancedSavingsGoals.firstIndex(where: { $0.id == goal.id }) {
            let oldGoal = enhancedSavingsGoals[index]
            enhancedSavingsGoals[index] = goal
            
            if !oldGoal.isCompleted && goal.isCompleted {
                notificationManager.scheduleGoalCompletionNotification(for: goal)
            }
            
            persistData(key: "goals", data: enhancedSavingsGoals)
            generateInsights()
        }
    }
    
    public func deleteSavingsGoal(_ goal: EnhancedSavingsGoal) {
        enhancedSavingsGoals.removeAll { $0.id == goal.id }
        persistData(key: "goals", data: enhancedSavingsGoals)
        generateInsights()
    }
    
    // MARK: - Savings Entries Management
    
    public func addSavingsAmount(_ amount: Double, to goalId: UUID, notes: String? = nil) {
        addSavingsEntry(amount: amount, to: goalId, type: .addition, notes: notes)
    }
    
    public func removeSavingsAmount(_ amount: Double, from goalId: UUID, notes: String? = nil) -> Bool {
        // Get current goal to validate removal amount
        guard let goalIndex = enhancedSavingsGoals.firstIndex(where: { $0.id == goalId }) else {
            return false
        }
        
        let currentGoal = enhancedSavingsGoals[goalIndex]
        
        // Validate that we're not removing more than current amount
        if amount > currentGoal.currentAmount {
            return false // Cannot remove more than current amount
        }
        
        addSavingsEntry(amount: amount, to: goalId, type: .removal, notes: notes)
        return true
    }
    
    private func addSavingsEntry(amount: Double, to goalId: UUID, type: SavingsEntryType, notes: String? = nil) {
        // Create new savings entry
        let entry = SavingsEntry(
            goalId: goalId,
            amount: amount,
            type: type,
            date: Date(),
            notes: notes
        )
        
        // Add to entries list
        savingsEntries.append(entry)
        
        // Update the goal's current amount
        if let index = enhancedSavingsGoals.firstIndex(where: { $0.id == goalId }) {
            var updatedGoal = enhancedSavingsGoals[index]
            let wasCompleted = updatedGoal.isCompleted
            
            switch type {
            case .addition:
                updatedGoal.currentAmount += amount
                // Check if goal is now completed
                if !wasCompleted && updatedGoal.isCompleted {
                    notificationManager.scheduleGoalCompletionNotification(for: updatedGoal)
                }
            case .removal:
                updatedGoal.currentAmount = max(0, updatedGoal.currentAmount - amount)
            }
            
            enhancedSavingsGoals[index] = updatedGoal
        }
        
        // Persist data
        persistData(key: "goals", data: enhancedSavingsGoals)
        persistData(key: "savings_entries", data: savingsEntries)
        
        // Generate new insights
        generateInsights()
    }
    
    public func getSavingsEntries(for goalId: UUID) -> [SavingsEntry] {
        return savingsEntries.filter { $0.goalId == goalId }.sorted { $0.date > $1.date }
    }
    
    public func getSavingsEntries(for goalId: UUID, type: SavingsEntryType) -> [SavingsEntry] {
        return savingsEntries.filter { $0.goalId == goalId && $0.type == type }.sorted { $0.date > $1.date }
    }
    
    public func getTotalSavingsAmount(for goalId: UUID) -> Double {
        let entries = getSavingsEntries(for: goalId)
        return entries.reduce(0) { total, entry in
            switch entry.type {
            case .addition:
                return total + entry.amount
            case .removal:
                return total - entry.amount
            }
        }
    }
    
    public func deleteSavingsEntry(_ entry: SavingsEntry) {
        // Remove from entries
        savingsEntries.removeAll { $0.id == entry.id }
        
        // Update the goal's current amount by reversing the entry effect
        if let index = enhancedSavingsGoals.firstIndex(where: { $0.id == entry.goalId }) {
            var updatedGoal = enhancedSavingsGoals[index]
            
            switch entry.type {
            case .addition:
                // Reverse an addition by subtracting
                updatedGoal.currentAmount = max(0, updatedGoal.currentAmount - entry.amount)
            case .removal:
                // Reverse a removal by adding back
                updatedGoal.currentAmount += entry.amount
            }
            
            enhancedSavingsGoals[index] = updatedGoal
        }
        
        // Persist data
        persistData(key: "goals", data: enhancedSavingsGoals)
        persistData(key: "savings_entries", data: savingsEntries)
        
        // Generate new insights
        generateInsights()
    }
    
    // MARK: - Financial Insights & Reporting
    
    public func generateInsights() {
        var insights: [FinancialInsight] = []
        
        insights.append(contentsOf: generateSpendingInsights())
        insights.append(contentsOf: generateBudgetInsights())
        insights.append(contentsOf: generateSavingsInsights())
        
        DispatchQueue.main.async {
            self.financialInsights = insights
        }
    }
    
    private func generateSpendingInsights() -> [FinancialInsight] {
        var insights: [FinancialInsight] = []
        
        let monthlyExpenses = getExpensesByMonth()
        let sortedMonths = monthlyExpenses.keys.sorted()
        
        if sortedMonths.count >= 2 {
            let currentMonth = sortedMonths.last!
            let previousMonth = sortedMonths[sortedMonths.count - 2]
            
            let currentTotal = monthlyExpenses[currentMonth]?.reduce(0) { $0 + $1.amount } ?? 0
            let previousTotal = monthlyExpenses[previousMonth]?.reduce(0) { $0 + $1.amount } ?? 0
            
            let change = currentTotal - previousTotal
            let changePercent = previousTotal > 0 ? (change / previousTotal) * 100 : 0
            
            let trend: TrendDirection = change > 0 ? .up : (change < 0 ? .down : .stable)
            let priority: InsightPriority = abs(changePercent) > 20 ? .high : .medium
            
            insights.append(FinancialInsight(
                type: .trend,
                title: "Monthly Spending Trend",
                description: "Your spending is \(trend.rawValue.lowercased()) by \(String(format: "%.1f", abs(changePercent)))% compared to last month",
                value: String(format: "$%.2f", currentTotal),
                trend: trend,
                priority: priority,
                actionable: abs(changePercent) > 15,
                category: "Spending"
            ))
        }
        
        return insights
    }
    
    private func generateBudgetInsights() -> [FinancialInsight] {
        var insights: [FinancialInsight] = []
        
        for budget in enhancedBudgets {
            let utilization = getBudgetUtilization(for: budget)
            
            if utilization.isOverBudget {
                insights.append(FinancialInsight(
                    type: .alert,
                    title: "Budget Exceeded",
                    description: "\(budget.name) is over budget by \(String(format: "$%.2f", utilization.amountSpent - budget.amount))",
                    value: String(format: "%.1f%%", utilization.utilizationPercentage),
                    trend: .up,
                    priority: .urgent,
                    actionable: true,
                    category: budget.category ?? "General"
                ))
            }
        }
        
        return insights
    }
    
    private func generateSavingsInsights() -> [FinancialInsight] {
        var insights: [FinancialInsight] = []
        
        for goal in enhancedSavingsGoals where goal.isActive {
            if goal.progress >= 0.8 && !goal.isCompleted {
                insights.append(FinancialInsight(
                    type: .opportunity,
                    title: "Goal Almost Complete",
                    description: "\(goal.name) is \(String(format: "%.0f", goal.progress * 100))% complete!",
                    value: String(format: "$%.2f remaining", goal.targetAmount - goal.currentAmount),
                    trend: .up,
                    priority: .medium,
                    actionable: true,
                    category: goal.category.rawValue
                ))
            }
        }
        
        return insights
    }
    
    private func checkBudgetAlerts(for expense: EnhancedExpenseItem) {
        let relevantBudgets = enhancedBudgets.filter { budget in
            if let budgetCategory = budget.category {
                return budgetCategory == expense.category
            }
            return true
        }
        
        for budget in relevantBudgets {
            let utilization = getBudgetUtilization(for: budget)
            
            if utilization.utilizationPercentage >= budget.alertThreshold {
                if utilization.isOverBudget {
                    notificationManager.scheduleBudgetExceededNotification(for: budget, overage: utilization.amountSpent - budget.amount)
                } else {
                    notificationManager.scheduleBudgetWarningNotification(for: budget, utilization: utilization.utilizationPercentage)
                }
            }
        }
    }
    
    private func processRecurringExpense(_ expense: EnhancedExpenseItem) {
        guard let frequency = expense.recurringFrequency else { return }
        
        let recurringTransaction = RecurringTransaction(
            name: "Auto: \(expense.category)",
            amount: expense.amount,
            category: expense.category,
            frequency: frequency,
            type: .expense,
            notes: expense.notes
        )
        
        addRecurringTransaction(recurringTransaction)
    }
    
    func addRecurringTransaction(_ transaction: RecurringTransaction) {
        recurringTransactions.append(transaction)
        persistData(key: "recurring", data: recurringTransactions)
    }
    
    // MARK: - Data Persistence
    
    private func persistData<T: Codable>(key: String, data: T) {
        guard let persistenceKey = persistenceKeys[key] else { return }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let encoded = try encoder.encode(data)
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        } catch {
            print("❌ Failed to persist \(key): \(error)")
        }
    }
    
    private func loadData<T: Codable>(key: String, type: T.Type) -> T? {
        guard let persistenceKey = persistenceKeys[key],
              let data = UserDefaults.standard.data(forKey: persistenceKey) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("❌ Failed to load \(key): \(error)")
            return nil
        }
    }
    
    func loadAllData() {
        enhancedExpenses = loadData(key: "expenses", type: [EnhancedExpenseItem].self) ?? []
        enhancedBudgets = loadData(key: "budgets", type: [EnhancedBudget].self) ?? []
        enhancedSavingsGoals = loadData(key: "goals", type: [EnhancedSavingsGoal].self) ?? []
        savingsEntries = loadData(key: "savings_entries", type: [SavingsEntry].self) ?? []
        recurringTransactions = loadData(key: "recurring", type: [RecurringTransaction].self) ?? []
        budgetAlerts = loadData(key: "alerts", type: [BudgetAlert].self) ?? []
    }
    
    func resetAllData() {
        enhancedExpenses.removeAll()
        enhancedBudgets.removeAll()
        enhancedSavingsGoals.removeAll()
        savingsEntries.removeAll()
        recurringTransactions.removeAll()
        budgetAlerts.removeAll()
        financialInsights.removeAll()
        
        for key in persistenceKeys.values {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

// MARK: - Notification Manager

class NotificationManager {
    
    func scheduleBudgetWarningNotification(for budget: EnhancedBudget, utilization: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Budget Alert - \(budget.name)"
        content.body = "You've used \(String(format: "%.1f", utilization))% of your budget. Consider tracking your spending."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "budget_warning_\(budget.id.uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleBudgetExceededNotification(for budget: EnhancedBudget, overage: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Budget Exceeded - \(budget.name)"
        content.body = "You've exceeded your budget by \(String(format: "$%.2f", overage)). Review your spending."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "budget_exceeded_\(budget.id.uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleGoalCompletionNotification(for goal: EnhancedSavingsGoal) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goal Achieved!"
        content.body = "Congratulations! You've reached your savings goal: \(goal.name)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "goal_completed_\(goal.id.uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Supporting Data Structures

struct AnalyticsOverview {
    let totalEvents: Int
    let eventsByCategory: [String: Int]
    let eventsLastWeek: Int
    let mostActiveDay: String
}

public struct BudgetUtilization {
    public let budget: EnhancedBudget
    public let amountSpent: Double
    public let utilizationPercentage: Double
    public let isOverBudget: Bool
    
    public init(budget: EnhancedBudget, amountSpent: Double, utilizationPercentage: Double, isOverBudget: Bool) {
        self.budget = budget
        self.amountSpent = amountSpent
        self.utilizationPercentage = utilizationPercentage
        self.isOverBudget = isOverBudget
    }
}

// MARK: - Backward Compatibility Data Manager

class DataManager: ObservableObject {
    static let shared = DataManager()
    private let enhancedDataManager = EnhancedDataManager.shared
    
    private var currentSessionId = UUID()
    
    @Published var userSettings: UserSettings = UserSettings()
    private let analyticsTracker = SimpleAnalyticsTracker()
    
    init() {
        startNewSession()
    }
    
    private func startNewSession() {
        currentSessionId = UUID()
        trackEvent(eventName: "session_started", category: "system")
    }
    
    // MARK: - Analytics Tracking
    
    func trackEvent(eventName: String, category: String, properties: [String: Any]? = nil) {
        analyticsTracker.track(event: eventName, category: category, properties: properties)
    }
    
    func trackScreenView(_ screenName: String) {
        trackEvent(eventName: "screen_viewed", category: "navigation", properties: [
            "screen_name": screenName
        ])
    }
    
    func trackTabChange(from: String, to: String) {
        trackEvent(eventName: "tab_changed", category: "navigation", properties: [
            "from_tab": from,
            "to_tab": to
        ])
    }
    
    // MARK: - Onboarding Management
    
    func updateOnboardingProgress(step: String) {
        trackEvent(eventName: "onboarding_step_completed", category: "onboarding", properties: [
            "step": step,
            "session_id": currentSessionId.uuidString
        ])
    }
    
    func completeOnboarding() {
        userSettings.onboardingCompletedAt = Date()
        trackEvent(eventName: "onboarding_completed", category: "onboarding", properties: [
            "completion_time": Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - Settings Management
    
    func updateSettings(
        isDarkMode: Bool? = nil,
        notificationsEnabled: Bool? = nil,
        biometricEnabled: Bool? = nil,
        currencySymbol: String? = nil,
        monthlyBudgetReminders: Bool? = nil
    ) {
        var changes: [String: Any] = [:]
        
        if let isDarkMode = isDarkMode, isDarkMode != userSettings.isDarkMode {
            userSettings.isDarkMode = isDarkMode
            changes["isDarkMode"] = isDarkMode
        }
        
        if let notificationsEnabled = notificationsEnabled, notificationsEnabled != userSettings.notificationsEnabled {
            userSettings.notificationsEnabled = notificationsEnabled
            changes["notificationsEnabled"] = notificationsEnabled
        }
        
        if let biometricEnabled = biometricEnabled, biometricEnabled != userSettings.biometricEnabled {
            userSettings.biometricEnabled = biometricEnabled
            changes["biometricEnabled"] = biometricEnabled
        }
        
        if let currencySymbol = currencySymbol, currencySymbol != userSettings.currencySymbol {
            userSettings.currencySymbol = currencySymbol
            changes["currencySymbol"] = currencySymbol
        }
        
        if let monthlyBudgetReminders = monthlyBudgetReminders, monthlyBudgetReminders != userSettings.monthlyBudgetReminders {
            userSettings.monthlyBudgetReminders = monthlyBudgetReminders
            changes["monthlyBudgetReminders"] = monthlyBudgetReminders
        }
        
        if !changes.isEmpty {
            trackEvent(eventName: "setting_changed", category: "settings", properties: changes)
        }
    }
    
    // MARK: - Expense Management
    
    func addExpense(amount: Double, category: String, notes: String?) {
        trackEvent(eventName: "expense_added", category: "expense", properties: [
            "amount": amount,
            "category": category,
            "has_notes": notes != nil
        ])
        
        let enhancedExpense = EnhancedExpenseItem(
            amount: amount,
            category: category,
            notes: notes
        )
        enhancedDataManager.addExpense(enhancedExpense)
    }
    
    // MARK: - Budget Management
    
    func createBudget(amount: Double, period: String) {
        trackEvent(eventName: "budget_created", category: "budget", properties: [
            "amount": amount,
            "period": period
        ])
        
        let budgetPeriod = BudgetPeriod(rawValue: period) ?? .monthly
        let enhancedBudget = EnhancedBudget(
            name: "Budget",
            amount: amount,
            period: budgetPeriod
        )
        enhancedDataManager.addBudget(enhancedBudget)
    }
    
    // MARK: - Savings Goal Management
    
    func createSavingsGoal(targetAmount: Double, timeframe: String) {
        trackEvent(eventName: "goal_created", category: "goal", properties: [
            "target_amount": targetAmount,
            "timeframe": timeframe
        ])
        
        let enhancedGoal = EnhancedSavingsGoal(
            name: "Savings Goal",
            targetAmount: targetAmount
        )
        enhancedDataManager.addSavingsGoal(enhancedGoal)
    }
    
    // MARK: - Reporting & Analytics
    
    func generateAnalyticsOverview() -> AnalyticsOverview {
        let events = analyticsTracker.events
        let eventsByCategory = Dictionary(grouping: events, by: { $0.category })
        let categoryStats = eventsByCategory.mapValues { $0.count }
        
        let lastWeekEvents = events.filter { event in
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return event.timestamp >= oneWeekAgo
        }
        
        return AnalyticsOverview(
            totalEvents: events.count,
            eventsByCategory: categoryStats,
            eventsLastWeek: lastWeekEvents.count,
            mostActiveDay: getMostActiveDay(from: events)
        )
    }
    
    private func getMostActiveDay(from events: [AnalyticsEventData]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        let eventsByDay = Dictionary(grouping: events, by: { event in
            formatter.string(from: event.timestamp)
        })
        
        let dayCounts = eventsByDay.mapValues { $0.count }
        return dayCounts.max(by: { $0.value < $1.value })?.key ?? "Unknown"
    }
    
    // MARK: - Data Management
    
    func resetAllData() {
        userSettings = UserSettings()
        enhancedDataManager.resetAllData()
        analyticsTracker.clearEvents()
        trackEvent(eventName: "data_reset", category: "settings")
    }
    
    // MARK: - Sample Data for Demo
    
    func populateSampleData() {
        // Add sample expenses
        let sampleExpenses = [
            EnhancedExpenseItem(amount: 45.67, category: "Food & Dining", notes: "Lunch at cafe", paymentMethod: .credit),
            EnhancedExpenseItem(amount: 120.00, category: "Transportation", notes: "Gas for week", paymentMethod: .debit),
            EnhancedExpenseItem(amount: 85.50, category: "Shopping", notes: "Groceries", paymentMethod: .cash),
            EnhancedExpenseItem(amount: 25.99, category: "Entertainment", notes: "Movie tickets", paymentMethod: .applePay),
            EnhancedExpenseItem(amount: 200.00, category: "Bills & Utilities", notes: "Electric bill", isRecurring: true, recurringFrequency: .monthly, paymentMethod: .bankTransfer)
        ]
        
        for expense in sampleExpenses {
            enhancedDataManager.addExpense(expense)
        }
        
        // Add sample budgets
        let sampleBudgets = [
            EnhancedBudget(name: "Monthly Food Budget", amount: 500.00, period: .monthly, category: "Food & Dining", alertThreshold: 85.0),
            EnhancedBudget(name: "Transportation Budget", amount: 300.00, period: .monthly, category: "Transportation", alertThreshold: 90.0),
            EnhancedBudget(name: "General Spending", amount: 1000.00, period: .monthly, alertThreshold: 80.0)
        ]
        
        for budget in sampleBudgets {
            enhancedDataManager.addBudget(budget)
        }
        
        // Add sample savings goals
        let sampleGoals = [
            EnhancedSavingsGoal(name: "Emergency Fund", targetAmount: 5000.00, currentAmount: 1250.00, category: .emergency, priority: .high),
            EnhancedSavingsGoal(name: "Vacation to Europe", targetAmount: 3000.00, currentAmount: 750.00, category: .vacation, priority: .medium),
            EnhancedSavingsGoal(name: "New Car Down Payment", targetAmount: 8000.00, currentAmount: 2400.00, category: .car, priority: .high)
        ]
        
        for goal in sampleGoals {
            enhancedDataManager.addSavingsGoal(goal)
        }
        
        // Add sample recurring transactions
        let sampleRecurring = [
            RecurringTransaction(name: "Salary", amount: 4500.00, category: "Income", frequency: .monthly, type: .income),
            RecurringTransaction(name: "Rent", amount: 1200.00, category: "Housing", frequency: .monthly, type: .expense),
            RecurringTransaction(name: "Netflix Subscription", amount: 15.99, category: "Entertainment", frequency: .monthly, type: .expense),
            RecurringTransaction(name: "Gym Membership", amount: 29.99, category: "Healthcare", frequency: .monthly, type: .expense)
        ]
        
        for transaction in sampleRecurring {
            enhancedDataManager.addRecurringTransaction(transaction)
        }
        
        trackEvent(eventName: "sample_data_populated", category: "demo")
    }
} 