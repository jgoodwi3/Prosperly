//
//  SimpleSavingsGoalsView.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import SwiftUI
import Foundation

// MARK: - Savings Goals View

struct SimpleSavingsGoalsView: View {
    @State private var savingsGoalAmount: String = ""
    @State private var currentProgress: Double = 0.0
    @State private var selectedPayFrequency: PayFrequency = .weekly
    @State private var savingsPerPaycheck: String = ""
    @State private var showingCalculations = false
    @State private var selectedGoalIndex: Int = 0
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    @StateObject private var dataManager = EnhancedDataManager.shared
    
    private var activeGoals: [EnhancedSavingsGoal] {
        return dataManager.enhancedSavingsGoals.filter { $0.isActive }
    }
    
    private var selectedGoal: EnhancedSavingsGoal? {
        guard selectedGoalIndex < activeGoals.count else { return nil }
        return activeGoals[selectedGoalIndex]
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
                                    
                                    Text("Savings Goals")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Track your progress toward financial goals")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "target")
                                .font(.system(size: 28))
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Goal Input Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Set Your Goal")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Savings Goal Amount
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Savings Goal Amount")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    Text("$")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("5,000", text: $savingsGoalAmount)
                                        .font(.title3)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: savingsGoalAmount) {
                                            updateCalculations()
                                        }
                                }
                            }
                            
                            // Savings per Paycheck
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Savings per Paycheck")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    Text("$")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("300", text: $savingsPerPaycheck)
                                        .font(.title3)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: savingsPerPaycheck) {
                                            updateCalculations()
                                        }
                                }
                            }
                            
                            // Pay Frequency
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pay Frequency")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Pay Frequency", selection: $selectedPayFrequency) {
                                    ForEach(PayFrequency.allCases, id: \.self) { frequency in
                                        Text(frequency.rawValue).tag(frequency)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: selectedPayFrequency) {
                                    analytics.track(event: "savings_frequency_changed", category: "goal", properties: [
                                        "frequency": selectedPayFrequency.rawValue
                                    ])
                                    updateCalculations()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Goal Selection (if multiple goals exist)
                    if activeGoals.count > 1 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Goal")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Picker("Goal", selection: $selectedGoalIndex) {
                                ForEach(0..<activeGoals.count, id: \.self) { index in
                                    Text(activeGoals[index].name).tag(index)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    // Visual Progress Meter
                    if let goal = selectedGoal {
                        SavingsProgressMeter(
                            goalAmount: goal.targetAmount,
                            currentProgress: .constant(goal.progress * 100),
                            onAmountAdded: { amount in
                                addSavingsAmount(amount, to: goal)
                            },
                            onAmountRemoved: { amount in
                                return removeSavingsAmount(amount, from: goal)
                            }
                        )
                    } else if let goalAmount = Double(savingsGoalAmount), goalAmount > 0 {
                        // Fallback to manual goal creation mode
                        SavingsProgressMeter(
                            goalAmount: goalAmount,
                            currentProgress: $currentProgress,
                            onAmountAdded: { amount in
                                createAndAddToNewGoal(amount: amount, goalAmount: goalAmount)
                            },
                            onAmountRemoved: { amount in
                                // Can't remove from non-existent goal
                                return false
                            }
                        )
                    }
                    
                    // Calculations Section
                    if showingCalculations,
                       let goalAmount = Double(savingsGoalAmount),
                       let savingsAmount = Double(savingsPerPaycheck),
                       goalAmount > 0 && savingsAmount > 0 {
                        SavingsCalculationsView(
                            goalAmount: goalAmount,
                            savingsPerPaycheck: savingsAmount,
                            frequency: selectedPayFrequency,
                            currentProgress: currentProgress
                        )
                    }
                    
                    // Savings History Log
                    if let goal = selectedGoal {
                        SavingsHistoryView(
                            goalId: goal.id,
                            entries: dataManager.getSavingsEntries(for: goal.id)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Prosperly - Goals")
            .onAppear {
                analytics.trackScreenView("savings_goals")
            }
        }
    }
    
    private func updateCalculations() {
        showingCalculations = !savingsGoalAmount.isEmpty && !savingsPerPaycheck.isEmpty
        
        if showingCalculations {
            analytics.track(event: "savings_goal_calculated", category: "goal", properties: [
                "goal_amount": Double(savingsGoalAmount) ?? 0,
                "savings_per_paycheck": Double(savingsPerPaycheck) ?? 0,
                "frequency": selectedPayFrequency.rawValue
            ])
        }
    }
    
    private func addSavingsAmount(_ amount: Double, to goal: EnhancedSavingsGoal) {
        dataManager.addSavingsAmount(amount, to: goal.id)
        
        // Track analytics
        analytics.track(event: "savings_amount_added", category: "goal", properties: [
            "goal_id": goal.id.uuidString,
            "goal_name": goal.name,
            "amount": amount,
            "goal_progress": goal.progress,
            "new_current_amount": goal.currentAmount + amount
        ])
    }
    
    private func removeSavingsAmount(_ amount: Double, from goal: EnhancedSavingsGoal) -> Bool {
        let success = dataManager.removeSavingsAmount(amount, from: goal.id)
        
        if success {
            // Track analytics
            analytics.track(event: "savings_amount_removed", category: "goal", properties: [
                "goal_id": goal.id.uuidString,
                "goal_name": goal.name,
                "amount": amount,
                "previous_amount": goal.currentAmount,
                "new_current_amount": max(0, goal.currentAmount - amount)
            ])
        } else {
            // Track failed removal attempt
            analytics.track(event: "savings_removal_failed", category: "goal", properties: [
                "goal_id": goal.id.uuidString,
                "goal_name": goal.name,
                "attempted_amount": amount,
                "current_amount": goal.currentAmount,
                "reason": "insufficient_funds"
            ])
        }
        
        return success
    }
    
    private func createAndAddToNewGoal(amount: Double, goalAmount: Double) {
        // Create a new goal with the specified target amount
        let newGoal = EnhancedSavingsGoal(
            name: "My Savings Goal",
            targetAmount: goalAmount,
            currentAmount: 0,
            category: .general,
            priority: .medium
        )
        
        // Add the goal to data manager
        dataManager.addSavingsGoal(newGoal)
        
        // Add the initial savings amount
        dataManager.addSavingsAmount(amount, to: newGoal.id)
        
        // Update local state to show the new goal
        selectedGoalIndex = 0
        
        // Track analytics
        analytics.track(event: "savings_goal_created_with_amount", category: "goal", properties: [
            "goal_target": goalAmount,
            "initial_amount": amount,
            "category": newGoal.category.rawValue
        ])
    }
}

struct SavingsProgressMeter: View {
    let goalAmount: Double
    @Binding var currentProgress: Double
    @State private var currentAmountText: String = ""
    @State private var isEditingAmount: Bool = false
    @State private var showingSuccessMessage: Bool = false
    @State private var showingRemovalMessage: Bool = false
    @State private var lastAddedAmount: Double = 0
    @State private var lastRemovedAmount: Double = 0
    @State private var isRemovalMode: Bool = false
    
    // Callbacks for amount changes
    let onAmountAdded: ((Double) -> Void)?
    let onAmountRemoved: ((Double) -> Bool)?
    
    init(goalAmount: Double, currentProgress: Binding<Double>, onAmountAdded: ((Double) -> Void)? = nil, onAmountRemoved: ((Double) -> Bool)? = nil) {
        self.goalAmount = goalAmount
        self._currentProgress = currentProgress
        self.onAmountAdded = onAmountAdded
        self.onAmountRemoved = onAmountRemoved
    }
    
    private var currentAmount: Double {
        goalAmount * (currentProgress / 100)
    }
    
    private var remainingAmount: Double {
        goalAmount - currentAmount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Visual Savings Meter")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Success Messages
            if showingSuccessMessage {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("Added $\(lastAddedAmount, specifier: "%.2f") to your savings!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .transition(.slide)
                .animation(.easeInOut(duration: 0.3), value: showingSuccessMessage)
            }
            
            if showingRemovalMessage {
                HStack {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.orange)
                    Text("Removed $\(lastRemovedAmount, specifier: "%.2f") from your savings!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .transition(.slide)
                .animation(.easeInOut(duration: 0.3), value: showingRemovalMessage)
            }
            
            VStack(spacing: 12) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: currentProgress / 100)
                        .stroke(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: currentProgress)
                    
                    VStack(spacing: 2) {
                        Text("\(currentProgress, specifier: "%.0f")%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Mode Toggle
                VStack(spacing: 8) {
                    HStack {
                        Text("Action Mode:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    
                    Picker("Mode", selection: $isRemovalMode) {
                        Label("Add Savings", systemImage: "plus.circle")
                            .tag(false)
                        Label("Remove Savings", systemImage: "minus.circle")
                            .tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: isRemovalMode) { _, _ in
                        currentAmountText = ""
                    }
                }
                
                // Direct Amount Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(isRemovalMode ? "Enter Amount to Remove:" : "Enter Amount to Add:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("$")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        TextField("0.00", text: $currentAmountText)
                            .font(.title3)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                processAmountInput()
                            }
                            .onChange(of: currentAmountText) { _, _ in
                                isEditingAmount = true
                            }
                        
                        Button(isRemovalMode ? "Remove" : "Add") {
                            processAmountInput()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isRemovalMode ? Color.orange : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(currentAmountText.isEmpty)
                    }
                }
                
                // Progress Slider
                VStack(spacing: 8) {
                    HStack {
                        Text("Or Adjust Progress:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("$\(currentAmount, specifier: "%.2f") saved")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    
                    Slider(value: $currentProgress, in: 0...100, step: 1)
                        .accentColor(.green)
                        .onChange(of: currentProgress) { _, newValue in
                            if !isEditingAmount {
                                currentAmountText = String(format: "%.2f", currentAmount)
                            }
                            isEditingAmount = false
                        }
                }
                
                // Amount Details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Amount")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(currentAmount, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(remainingAmount, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .onAppear {
            currentAmountText = String(format: "%.2f", currentAmount)
        }
    }
    
    private func processAmountInput() {
        guard let amount = Double(currentAmountText), amount > 0 else { return }
        
        if isRemovalMode {
            // Handle removal
            if let onAmountRemoved = onAmountRemoved {
                let success = onAmountRemoved(amount)
                if success {
                    lastRemovedAmount = amount
                    currentAmountText = ""
                    isEditingAmount = false
                    showRemovalMessage()
                } else {
                    // Show error feedback for invalid removal
                    showRemovalError()
                }
            }
        } else {
            // Handle addition
            lastAddedAmount = amount
            onAmountAdded?(amount)
            currentAmountText = ""
            isEditingAmount = false
            showSuccessMessage()
        }
    }
    
    private func showSuccessMessage() {
        showingSuccessMessage = true
        
        // Add haptic feedback
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
        
        // Hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showingSuccessMessage = false
        }
    }
    
    private func showRemovalMessage() {
        showingRemovalMessage = true
        
        // Add haptic feedback
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
        
        // Hide removal message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showingRemovalMessage = false
        }
    }
    
    private func showRemovalError() {
        // Add error haptic feedback
        #if os(iOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
        #endif
        
        // Could add an error message state here if needed
        // For now, just clear the input to indicate invalid amount
        currentAmountText = ""
    }
}

struct SavingsCalculationsView: View {
    let goalAmount: Double
    let savingsPerPaycheck: Double
    let frequency: PayFrequency
    let currentProgress: Double
    
    private var remainingAmount: Double {
        goalAmount - (goalAmount * currentProgress / 100)
    }
    
    private var paychecksNeeded: Double {
        guard savingsPerPaycheck > 0 else { return 0 }
        return remainingAmount / savingsPerPaycheck
    }
    
    private var timeToGoal: (value: Double, unit: String) {
        switch frequency {
        case .daily:
            let workdays = paychecksNeeded / 5 // 5 workdays per week
            return (workdays, workdays == 1 ? "workday" : "workdays")
        case .weekly:
            return (paychecksNeeded, paychecksNeeded == 1 ? "week" : "weeks")
        case .biWeekly:
            let weeks = paychecksNeeded * 2
            return (weeks, weeks == 1 ? "week" : "weeks")
        case .monthly:
            return (paychecksNeeded, paychecksNeeded == 1 ? "month" : "months")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Goal Timeline")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Paychecks Needed
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Paychecks Needed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(paychecksNeeded, specifier: "%.0f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Time to Goal
                let timeInfo = timeToGoal
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Time to Goal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(timeInfo.value, specifier: "%.1f") \(timeInfo.unit)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // Summary Message
                Text("You'll reach your goal in \(paychecksNeeded, specifier: "%.0f") paychecks or \(timeInfo.value, specifier: "%.1f") \(timeInfo.unit).")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct SavingsHistoryView: View {
    let goalId: UUID
    let entries: [SavingsEntry]
    @State private var showingAllEntries = false
    
    private var displayedEntries: [SavingsEntry] {
        return showingAllEntries ? entries : Array(entries.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Savings History")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if entries.count > 5 {
                    Button(showingAllEntries ? "Show Less" : "Show All (\(entries.count))") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingAllEntries.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            if entries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("No savings entries yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(displayedEntries) { entry in
                        SavingsEntryRow(entry: entry)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct SavingsEntryRow: View {
    let entry: SavingsEntry
    
    private var entryColor: Color {
        switch entry.type {
        case .addition:
            return .green
        case .removal:
            return .orange
        }
    }
    
    private var entryIcon: String {
        switch entry.type {
        case .addition:
            return "plus.circle.fill"
        case .removal:
            return "minus.circle.fill"
        }
    }
    
    private var entryPrefix: String {
        switch entry.type {
        case .addition:
            return "+"
        case .removal:
            return "-"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entryIcon)
                .font(.title3)
                .foregroundColor(entryColor)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(entryPrefix)$\(entry.amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(entryColor)
                    
                    Spacer()
                    
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(entryColor.opacity(0.05))
        .cornerRadius(8)
    }
} 