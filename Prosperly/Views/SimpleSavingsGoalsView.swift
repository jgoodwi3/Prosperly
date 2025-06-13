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
                    
                    // Visual Progress Meter
                    if let goalAmount = Double(savingsGoalAmount), goalAmount > 0 {
                        SavingsProgressMeter(
                            goalAmount: goalAmount,
                            currentProgress: $currentProgress
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
}

struct SavingsProgressMeter: View {
    let goalAmount: Double
    @Binding var currentProgress: Double
    @State private var currentAmountText: String = ""
    @State private var isEditingAmount: Bool = false
    
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
                
                // Direct Amount Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter Current Savings Amount:")
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
                                updateProgressFromAmount()
                            }
                            .onChange(of: currentAmountText) { _, _ in
                                isEditingAmount = true
                            }
                        
                        Button("Update") {
                            updateProgressFromAmount()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
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
    
    private func updateProgressFromAmount() {
        guard let amount = Double(currentAmountText), amount >= 0 else { return }
        
        let clampedAmount = min(amount, goalAmount) // Don't allow more than the goal
        let newProgress = goalAmount > 0 ? (clampedAmount / goalAmount) * 100 : 0
        
        currentProgress = newProgress
        currentAmountText = String(format: "%.2f", clampedAmount)
        isEditingAmount = false
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