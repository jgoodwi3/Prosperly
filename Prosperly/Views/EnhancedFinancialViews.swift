//
//  EnhancedFinancialViews.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import SwiftUI
import Foundation
import UserNotifications

// MARK: - Enhanced Budget Management View

struct EnhancedBudgetView: View {
    @StateObject private var enhancedDataManager = EnhancedDataManager.shared
    @State private var showingAddBudget = false
    @State private var showingBudgetDetails = false
    @State private var selectedBudget: EnhancedBudget?
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
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
                                    
                                    Text("Enhanced Budgets")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Smart budget tracking with alerts and insights")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                analytics.track(event: "add_budget_tapped", category: "budget")
                                showingAddBudget = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Budget Overview
                    if !enhancedDataManager.enhancedBudgets.isEmpty {
                        BudgetOverviewCard(budgets: enhancedDataManager.enhancedBudgets)
                    }
                    
                    // Active Budgets
                    if !enhancedDataManager.enhancedBudgets.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Active Budgets")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(enhancedDataManager.enhancedBudgets, id: \.id) { budget in
                                    BudgetCard(budget: budget) {
                                        selectedBudget = budget
                                        showingBudgetDetails = true
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    // Financial Insights
                    if !enhancedDataManager.financialInsights.isEmpty {
                        FinancialInsightsCard(insights: enhancedDataManager.financialInsights.filter { $0.type == .budget })
                    }
                    
                    // Empty State
                    if enhancedDataManager.enhancedBudgets.isEmpty {
                        EmptyBudgetState {
                            showingAddBudget = true
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Enhanced Budgets")
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
                    .environmentObject(analytics)
            }
            .sheet(item: $selectedBudget) { (budget: EnhancedBudget) in
                BudgetDetailView(budget: budget)
                    .environmentObject(analytics)
            }
            .onAppear {
                analytics.trackScreenView("enhanced_budget")
            }
        }
    }
}

// MARK: - Enhanced Savings Goals View

struct EnhancedSavingsGoalsView: View {
    @StateObject private var enhancedDataManager = EnhancedDataManager.shared
    @State private var showingAddGoal = false
    @State private var showingGoalDetails = false
    @State private var selectedGoal: EnhancedSavingsGoal?
    @State private var selectedPriority: FilterPriority = .all
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    var filteredGoals: [EnhancedSavingsGoal] {
        let goals = enhancedDataManager.enhancedSavingsGoals.filter { $0.isActive }
        if selectedPriority == .all {
            return goals.sorted { goalPriorityOrder($0.priority) > goalPriorityOrder($1.priority) }
        }
        return goals.filter { goalPriorityMatches($0.priority, filter: selectedPriority) }
    }
    
    private func goalPriorityOrder(_ priority: GoalPriority) -> Int {
        switch priority {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    private func goalPriorityMatches(_ priority: GoalPriority, filter: FilterPriority) -> Bool {
        return priority.rawValue == filter.rawValue
    }
    
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
                                    
                                    Text("Enhanced Goals")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Categorized goals with smart progress tracking")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                analytics.track(event: "add_goal_tapped", category: "goal")
                                showingAddGoal = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Priority Filter
                    if !enhancedDataManager.enhancedSavingsGoals.isEmpty {
                        PriorityFilterView(selectedPriority: $selectedPriority)
                    }
                    
                    // Goals Overview
                    if !filteredGoals.isEmpty {
                        GoalsOverviewCard(goals: filteredGoals)
                    }
                    
                    // Active Goals
                    if !filteredGoals.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Goals")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(filteredGoals, id: \.id) { goal in
                                    EnhancedGoalCard(goal: goal) {
                                        selectedGoal = goal
                                        showingGoalDetails = true
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    // Empty State
                    if enhancedDataManager.enhancedSavingsGoals.isEmpty {
                        EmptyGoalsState {
                            showingAddGoal = true
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Enhanced Goals")
            .sheet(isPresented: $showingAddGoal) {
                AddSavingsGoalView()
                    .environmentObject(analytics)
            }
            .sheet(item: $selectedGoal) { (goal: EnhancedSavingsGoal) in
                GoalDetailView(goal: goal)
                    .environmentObject(analytics)
            }
            .onAppear {
                analytics.trackScreenView("enhanced_goals")
            }
        }
    }
}

// MARK: - Financial Insights Dashboard

struct FinancialInsightsDashboard: View {
    @StateObject private var enhancedDataManager = EnhancedDataManager.shared
    @State private var selectedInsightType: FilterInsightType = .all
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    var filteredInsights: [FinancialInsight] {
        if selectedInsightType == .all {
            return enhancedDataManager.financialInsights
        }
        return enhancedDataManager.financialInsights.filter { insightTypeMatches($0.type, filter: selectedInsightType) }
    }
    
    private func insightTypeMatches(_ type: InsightType, filter: FilterInsightType) -> Bool {
        return type.rawValue == filter.rawValue
    }
    
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
                                    
                                    Text("Financial Insights")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("AI-powered insights and recommendations")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Insight Type Filter
                    if !enhancedDataManager.financialInsights.isEmpty {
                        InsightTypeFilterView(selectedType: $selectedInsightType)
                    }
                    
                    // Insights Summary
                    if !enhancedDataManager.financialInsights.isEmpty {
                        InsightsSummaryCard(insights: enhancedDataManager.financialInsights)
                    }
                    
                    // Insights List
                    if !filteredInsights.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Insights")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(filteredInsights, id: \.id) { insight in
                                    FinancialInsightCard(insight: insight)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    // Empty State
                    if enhancedDataManager.financialInsights.isEmpty {
                        EmptyInsightsState()
                    }
                }
                .padding()
            }
            .navigationTitle("Financial Insights")
            .onAppear {
                analytics.trackScreenView("financial_insights")
                enhancedDataManager.generateInsights()
            }
        }
    }
}

// MARK: - Supporting Card Views

struct BudgetCard: View {
    let budget: EnhancedBudget
    let onTap: () -> Void
    
    @StateObject private var enhancedDataManager = EnhancedDataManager.shared
    
    private var utilization: BudgetUtilization {
        enhancedDataManager.getBudgetUtilization(for: budget)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if let category = budget.category {
                            Text(category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color(hex: budget.color))
                        .frame(width: 12, height: 12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(String(format: "$%.0f", utilization.amountSpent))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(String(format: "/ $%.0f", budget.amount))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", utilization.utilizationPercentage))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(utilization.isOverBudget ? .red : .green)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(utilization.isOverBudget ? Color.red : Color(hex: budget.color))
                                .frame(
                                    width: min(geometry.size.width * (utilization.utilizationPercentage / 100), geometry.size.width),
                                    height: 6
                                )
                                .cornerRadius(3)
                                .animation(.easeInOut(duration: 0.5), value: utilization.utilizationPercentage)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EnhancedGoalCard: View {
    let goal: EnhancedSavingsGoal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: goal.category.icon)
                                .font(.title3)
                                .foregroundColor(Color(hex: goal.category.color))
                            
                            Text(goal.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        Text(goal.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        PriorityBadge(priority: goal.priority)
                        
                        if goal.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(String(format: "$%.0f", goal.currentAmount))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(String(format: "/ $%.0f", goal.targetAmount))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", goal.progress * 100))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: goal.color))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: goal.color), Color(hex: goal.color).opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * goal.progress, height: 8)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.5), value: goal.progress)
                        }
                    }
                    .frame(height: 8)
                    
                    if let targetDate = goal.targetDate {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Target: \(targetDate, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
                            if daysRemaining > 0 {
                                Text("\(daysRemaining) days left")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FinancialInsightCard: View {
    let insight: FinancialInsight
    
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Image(systemName: trendIcon(insight.trend))
                    .font(.title2)
                    .foregroundColor(trendColor(insight.trend))
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(insight.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    InsightPriorityBadge(priority: insight.priority)
                }
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                if !insight.value.isEmpty {
                    Text(insight.value)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(priorityColor(insight.priority))
                }
                
                if insight.actionable {
                    Text("💡 Actionable")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func trendIcon(_ trend: TrendDirection) -> String {
        switch trend {
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }
    
    private func trendColor(_ trend: TrendDirection) -> Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .orange
        }
    }
    
    private func priorityColor(_ priority: InsightPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .urgent: return .purple
        }
    }
}

// MARK: - Supporting Views

struct PriorityBadge: View {
    let priority: GoalPriority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(goalPriorityColor(priority))
            )
    }
    
    private func goalPriorityColor(_ priority: GoalPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

struct InsightPriorityBadge: View {
    let priority: InsightPriority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(priorityBadgeColor(priority))
            )
    }
    
    private func priorityBadgeColor(_ priority: InsightPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .urgent: return .purple
        }
    }
}

// MARK: - Filter Views

struct PriorityFilterView: View {
    @Binding var selectedPriority: FilterPriority
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterPriority.allCases, id: \.rawValue) { priority in
                    FilterChip(
                        title: priority.rawValue,
                        isSelected: selectedPriority == priority
                    ) {
                        selectedPriority = priority
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct InsightTypeFilterView: View {
    @Binding var selectedType: FilterInsightType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterInsightType.allCases, id: \.rawValue) { type in
                    FilterChip(
                        title: type.rawValue,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.green : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty States

struct EmptyBudgetState: View {
    let onAddBudget: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Budgets Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first budget to start tracking your spending and get insights.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddBudget) {
                Text("Create Budget")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct EmptyGoalsState: View {
    let onAddGoal: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Goals Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Set your first savings goal and start building your financial future.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddGoal) {
                Text("Create Goal")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct EmptyInsightsState: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Insights Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add some expenses and budgets to start receiving personalized financial insights.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Placeholder Modal Views (to be implemented)

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Add Budget Modal - To be implemented")
                .navigationTitle("Add Budget")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct AddSavingsGoalView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Add Savings Goal Modal - To be implemented")
                .navigationTitle("Add Goal")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct BudgetDetailView: View {
    let budget: EnhancedBudget
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Budget Detail View - To be implemented")
                .navigationTitle(budget.name)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct GoalDetailView: View {
    let goal: EnhancedSavingsGoal
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Goal Detail View - To be implemented")
                .navigationTitle(goal.name)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

// MARK: - Placeholder Overview Cards

struct BudgetOverviewCard: View {
    let budgets: [EnhancedBudget]
    
    var body: some View {
        VStack {
            Text("Budget Overview - To be enhanced")
            Text("\(budgets.count) active budgets")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct GoalsOverviewCard: View {
    let goals: [EnhancedSavingsGoal]
    
    var body: some View {
        VStack {
            Text("Goals Overview - To be enhanced")
            Text("\(goals.count) active goals")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct FinancialInsightsCard: View {
    let insights: [FinancialInsight]
    
    var body: some View {
        VStack {
            Text("Financial Insights - To be enhanced")
            Text("\(insights.count) insights")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct InsightsSummaryCard: View {
    let insights: [FinancialInsight]
    
    var body: some View {
        VStack {
            Text("Insights Summary - To be enhanced")
            Text("\(insights.count) total insights")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 