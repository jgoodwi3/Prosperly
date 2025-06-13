//
//  QuickActionsViews.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

// MARK: - Quick Actions View
struct QuickActionsView: View {
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    @StateObject private var dataManager = EnhancedDataManager.shared
    @State private var showingAddExpense = false
    @State private var showingAddBudget = false
    @State private var showingAddGoal = false
    @State private var showingBudgetStatus = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image("ProsperlyLogo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                    
                                    Text("Quick Actions")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Fast access to key financial tools")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            QuickActionButton(
                                title: "Add Expense",
                                icon: "plus.circle.fill",
                                color: .red
                            ) {
                                analytics.track(event: "quick_action_add_expense_tapped", category: "quick_action")
                                showingAddExpense = true
                            }
                            
                            QuickActionButton(
                                title: "Create Budget",
                                icon: "chart.pie.fill",
                                color: .green
                            ) {
                                analytics.track(event: "quick_action_create_budget_tapped", category: "quick_action")
                                showingAddBudget = true
                            }
                            
                            QuickActionButton(
                                title: "Set Savings Goal",
                                icon: "target",
                                color: .blue
                            ) {
                                analytics.track(event: "quick_action_set_goal_tapped", category: "quick_action")
                                showingAddGoal = true
                            }
                            
                            QuickActionButton(
                                title: "Check Budget Status",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .orange
                            ) {
                                analytics.track(event: "quick_action_budget_status_tapped", category: "quick_action")
                                showingBudgetStatus = true
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Status Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Status Overview")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            StatusRow(
                                title: "Active Budgets", 
                                value: "\(dataManager.enhancedBudgets.filter { $0.isActive }.count)", 
                                icon: "chart.pie.fill", 
                                color: .green
                            )
                            StatusRow(
                                title: "Savings Goals", 
                                value: "\(dataManager.enhancedSavingsGoals.filter { $0.isActive }.count)", 
                                icon: "target", 
                                color: .blue
                            )
                            StatusRow(
                                title: "Financial Insights", 
                                value: "\(dataManager.financialInsights.count)", 
                                icon: "lightbulb.fill", 
                                color: .orange
                            )
                            StatusRow(
                                title: "Recent Expenses", 
                                value: "\(recentExpensesCount)", 
                                icon: "creditcard.fill", 
                                color: .red
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Quick Actions")
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
                    .environmentObject(analytics)
            }
            .sheet(isPresented: $showingAddBudget) {
                CreateBudgetView()
                    .environmentObject(analytics)
            }
            .sheet(isPresented: $showingAddGoal) {
                SetSavingsGoalView()
                    .environmentObject(analytics)
            }
            .sheet(isPresented: $showingBudgetStatus) {
                BudgetStatusView()
                    .environmentObject(analytics)
            }
            .onAppear {
                analytics.trackScreenView("quick_actions")
            }
        }
    }
    
    private var recentExpensesCount: Int {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return dataManager.enhancedExpenses.filter { $0.date >= sevenDaysAgo }.count
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Quick Action Modal Views

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    @StateObject private var dataManager = EnhancedDataManager.shared
    
    @State private var amount: String = ""
    @State private var selectedCategory = "Food & Dining"
    @State private var notes: String = ""
    @State private var selectedDate = Date()
    @State private var isRecurring = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    
    private let categories = [
        "Food & Dining", "Transportation", "Entertainment", "Shopping",
        "Housing", "Healthcare", "Travel", "Utilities", "Education", "Other"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            HStack {
                                Image(systemName: categoryIcon(for: category))
                                Text(category)
                            }
                            .tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Recurring") {
                    Toggle("Recurring Expense", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Frequency", selection: $recurringFrequency) {
                            ForEach(RecurringFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addExpense()
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Food & Dining": return "fork.knife"
        case "Transportation": return "car.fill"
        case "Entertainment": return "tv.fill"
        case "Shopping": return "bag.fill"
        case "Housing": return "house.fill"
        case "Healthcare": return "cross.fill"
        case "Travel": return "airplane"
        case "Utilities": return "bolt.fill"
        case "Education": return "book.fill"
        default: return "questionmark.circle"
        }
    }
    
    private func addExpense() {
        guard let expenseAmount = Double(amount) else { return }
        
        let expense = EnhancedExpenseItem(
            amount: expenseAmount,
            category: selectedCategory,
            notes: notes.isEmpty ? nil : notes,
            date: selectedDate,
            isRecurring: isRecurring,
            recurringFrequency: isRecurring ? recurringFrequency : nil
        )
        
        dataManager.addExpense(expense)
        
        analytics.track(event: "expense_added", category: "expense", properties: [
            "amount": expenseAmount,
            "category": selectedCategory,
            "is_recurring": isRecurring,
            "has_notes": !notes.isEmpty
        ])
        
        dismiss()
    }
}

struct CreateBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    @StateObject private var dataManager = EnhancedDataManager.shared
    
    @State private var budgetName: String = ""
    @State private var amount: String = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var selectedCategory: String? = nil
    @State private var alertThreshold: Double = 80
    @State private var selectedColor = "#4CAF50"
    
    private let categories = [
        "Food & Dining", "Transportation", "Entertainment", "Shopping",
        "Housing", "Healthcare", "Travel", "Utilities", "Education", "Other"
    ]
    
    private let budgetColors = [
        "#4CAF50", "#2196F3", "#FF9800", "#9C27B0", "#F44336", "#607D8B"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Budget Information") {
                    TextField("Budget Name", text: $budgetName)
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                }
                
                Section("Category (Optional)") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Categories").tag(nil as String?)
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category as String?)
                        }
                    }
                }
                
                Section("Settings") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Alert Threshold: \(alertThreshold, specifier: "%.0f")%")
                        
                        Slider(value: $alertThreshold, in: 50...100, step: 5)
                    }
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        HStack(spacing: 12) {
                            ForEach(budgetColors, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Budget")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createBudget()
                    }
                    .disabled(budgetName.isEmpty || amount.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private func createBudget() {
        guard let budgetAmount = Double(amount) else { return }
        
        let budget = EnhancedBudget(
            name: budgetName,
            amount: budgetAmount,
            period: selectedPeriod,
            category: selectedCategory,
            alertThreshold: alertThreshold,
            color: selectedColor
        )
        
        dataManager.addBudget(budget)
        
        analytics.track(event: "budget_created", category: "budget", properties: [
            "amount": budgetAmount,
            "period": selectedPeriod.rawValue,
            "category": selectedCategory ?? "all",
            "alert_threshold": alertThreshold
        ])
        
        dismiss()
    }
}

struct SetSavingsGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    @StateObject private var dataManager = EnhancedDataManager.shared
    
    @State private var goalName: String = ""
    @State private var targetAmount: String = ""
    @State private var currentAmount: String = "0"
    @State private var selectedCategory: GoalCategory = .general
    @State private var selectedPriority: GoalPriority = .medium
    @State private var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var hasTargetDate = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Information") {
                    TextField("Goal Name", text: $goalName)
                    
                    HStack {
                        Text("Target Amount")
                        Spacer()
                        TextField("0.00", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Current Amount")
                        Spacer()
                        TextField("0.00", text: $currentAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Category & Priority") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(GoalPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }
                
                Section("Target Date") {
                    Toggle("Set Target Date", isOn: $hasTargetDate)
                    
                    if hasTargetDate {
                        DatePicker("Target Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Set Savings Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createSavingsGoal()
                    }
                    .disabled(goalName.isEmpty || targetAmount.isEmpty || Double(targetAmount) == nil)
                }
            }
        }
    }
    
    private func createSavingsGoal() {
        guard let target = Double(targetAmount) else { return }
        let current = Double(currentAmount) ?? 0
        
        let goal = EnhancedSavingsGoal(
            name: goalName,
            targetAmount: target,
            currentAmount: current,
            targetDate: hasTargetDate ? targetDate : nil,
            category: selectedCategory,
            priority: selectedPriority
        )
        
        dataManager.addSavingsGoal(goal)
        
        analytics.track(event: "savings_goal_created", category: "goal", properties: [
            "target_amount": target,
            "current_amount": current,
            "category": selectedCategory.rawValue,
            "priority": selectedPriority.rawValue,
            "has_target_date": hasTargetDate
        ])
        
        dismiss()
    }
}

struct BudgetStatusView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    @StateObject private var dataManager = EnhancedDataManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if dataManager.enhancedBudgets.isEmpty {
                        // Empty State
                        VStack(spacing: 20) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("No Budgets Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Create your first budget to see status information here.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        // Budget Status Cards
                        ForEach(dataManager.enhancedBudgets, id: \.id) { budget in
                            BudgetStatusCard(budget: budget)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Budget Status")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            analytics.track(event: "budget_status_viewed", category: "budget")
        }
    }
}

struct BudgetStatusCard: View {
    let budget: EnhancedBudget
    @StateObject private var dataManager = EnhancedDataManager.shared
    
    private var utilization: BudgetUtilization {
        dataManager.getBudgetUtilization(for: budget)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let category = budget.category {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Circle()
                    .fill(Color(hex: budget.color))
                    .frame(width: 20, height: 20)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Spent")
                    Spacer()
                    Text("$\(utilization.amountSpent, specifier: "%.2f")")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Budget")
                    Spacer()
                    Text("$\(budget.amount, specifier: "%.2f")")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Remaining")
                    Spacer()
                    Text("$\(max(0, budget.amount - utilization.amountSpent), specifier: "%.2f")")
                        .fontWeight(.semibold)
                        .foregroundColor(utilization.isOverBudget ? .red : .green)
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(utilization.isOverBudget ? Color.red : Color(hex: budget.color))
                            .frame(
                                width: min(geometry.size.width * (utilization.utilizationPercentage / 100), geometry.size.width),
                                height: 8
                            )
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(utilization.utilizationPercentage, specifier: "%.1f")% used")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if utilization.isOverBudget {
                        Text("Over Budget")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    } else if utilization.utilizationPercentage >= budget.alertThreshold {
                        Text("Near Limit")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    } else {
                        Text("On Track")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
} 