//
//  SimpleBudgetView.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import SwiftUI
import Foundation

struct SimpleBudgetView: View {
    @State private var budgetAmount: String = ""
    @State private var selectedFrequency: PayFrequency = .weekly
    @State private var monthlyExpenses: Double = 0
    @State private var savingsPercentage: Double = 20
    @State private var showingCalculations = false
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    private var yearlyIncome: Double {
        guard let income = Double(budgetAmount) else { return 0 }
        return income * selectedFrequency.multiplier
    }
    
    private var weeklySpendingAllowance: Double {
        let yearlyAfterSavings = yearlyIncome * (1 - savingsPercentage / 100)
        return (yearlyAfterSavings - monthlyExpenses * 12) / 52
    }
    
    private var weeklySavingsContribution: Double {
        return (yearlyIncome * savingsPercentage / 100) / 52
    }
    
    private var advisoryMessage: (String, Color) {
        if weeklySpendingAllowance < 0 {
            return ("⚠️ Your expenses exceed your income after savings. Consider reducing expenses or adjusting your savings rate.", .red)
        } else if weeklySpendingAllowance < 50 {
            return ("💡 You have a tight budget. Look for ways to reduce fixed expenses or increase income.", .orange)
        } else if savingsPercentage >= 20 {
            return ("✅ Great job! You're saving \(String(format: "%.0f", savingsPercentage))% of your income.", .green)
        } else {
            return ("📈 Consider increasing your savings rate to at least 20% for better financial security.", .blue)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                mainContent
            }
            .navigationTitle("Prosperly - Budget")
            .onAppear {
                analytics.trackScreenView("simple_budget")
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
                VStack(spacing: 24) {
            headerCard
            inputSection
            
            // Results Section
            if showingCalculations && !budgetAmount.isEmpty {
                WeeklyBudgetBreakdown(
                    weeklySpendingAllowance: weeklySpendingAllowance,
                    weeklySavingsContribution: weeklySavingsContribution,
                    savingsPercentage: savingsPercentage,
                    advisoryMessage: advisoryMessage
                )
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var headerCard: some View {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image("ProsperlyLogo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                    
                                    Text("Budget Calculator")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Calculate your weekly spending allowance")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
    }
                    
    @ViewBuilder
    private var inputSection: some View {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Income Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 16) {
                incomeAmountInput
                payFrequencyInput
                monthlyExpensesInput
                savingsPercentageInput
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var incomeAmountInput: some View {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Income Amount")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    Text("$")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Enter amount", text: $budgetAmount)
                                        .font(.title3)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: budgetAmount) {
                                            updateCalculations()
                    }
                                        }
                                }
                            }
                            
    @ViewBuilder
    private var payFrequencyInput: some View {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pay Frequency")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Frequency", selection: $selectedFrequency) {
                                    ForEach(PayFrequency.allCases, id: \.self) { frequency in
                                        Text(frequency.displayName).tag(frequency)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: selectedFrequency) {
                                    analytics.track(event: "budget_frequency_changed", category: "budget", properties: [
                                        "frequency": selectedFrequency.rawValue
                                    ])
                                    updateCalculations()
            }
                                }
                            }
                            
    @ViewBuilder
    private var monthlyExpensesInput: some View {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fixed Monthly Expenses")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    Text("$")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Rent, utilities, etc.", value: $monthlyExpenses, format: .number)
                                        .font(.title3)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: monthlyExpenses) {
                                            updateCalculations()
                    }
                                        }
                                }
                            }
                            
    @ViewBuilder
    private var savingsPercentageInput: some View {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Savings Rate: \(savingsPercentage, specifier: "%.0f")%")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Slider(value: $savingsPercentage, in: 0...50, step: 1)
                                    .accentColor(.green)
                                    .onChange(of: savingsPercentage) {
                                        updateCalculations()
            }
        }
    }
    
    private func updateCalculations() {
        showingCalculations = !budgetAmount.isEmpty
        
        if showingCalculations {
            analytics.track(event: "budget_calculated", category: "budget", properties: [
                "income": Double(budgetAmount) ?? 0,
                "frequency": selectedFrequency.rawValue,
                "savings_rate": savingsPercentage,
                "monthly_expenses": monthlyExpenses
            ])
        }
    }
}

struct WeeklyBudgetBreakdown: View {
    let weeklySpendingAllowance: Double
    let weeklySavingsContribution: Double
    let savingsPercentage: Double
    let advisoryMessage: (String, Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Weekly Budget Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Weekly Spending Allowance
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly Spending Allowance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("$\(weeklySpendingAllowance, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(weeklySpendingAllowance < 0 ? .red : .green)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "creditcard.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Weekly Savings Contribution
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly Savings Contribution")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("$\(weeklySavingsContribution, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "banknote.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Savings Percentage
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Savings Rate")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(savingsPercentage, specifier: "%.1f")% of income")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "percent")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            
            // Advisory Note
            Text(advisoryMessage.0)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(advisoryMessage.1)
                .padding()
                .background(advisoryMessage.1.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
} 