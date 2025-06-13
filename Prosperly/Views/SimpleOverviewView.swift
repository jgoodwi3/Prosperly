//
//  SimpleOverviewView.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import SwiftUI

// MARK: - Simple Data Models

struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let amount: Double
    let notes: String?
    let date: Date
}

struct ExpenseCategory {
    let name: String
    let amount: Double
    let color: Color
}

struct SimpleOverviewView: View {
    @State private var expenses: [String: [ExpenseItem]] = [
        "Food & Dining": [],
        "Transportation": [],
        "Entertainment": [],
        "Shopping": [],
        "Housing": [],
        "Healthcare": [],
        "Travel": [],
        "Utilities": [],
        "Education": [],
        "Other": []
    ]
    
    @State private var selectedCategory = "Food & Dining"
    @State private var expenseAmount = ""
    @State private var expenseNotes = ""
    @State private var monthlyBudget: Double = 2000
    @State private var monthlyBudgetText: String = "2000"
    @State private var showingExpenseHistory = false
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    private var totalExpenses: Double {
        expenses.values.flatMap { $0 }.reduce(0) { $0 + $1.amount }
    }
    
    private var categoryTotals: [String: Double] {
        var totals: [String: Double] = [:]
        for (category, items) in expenses {
            totals[category] = items.reduce(0) { $0 + $1.amount }
        }
        return totals
    }
    
    private var budgetUtilization: Double {
        guard monthlyBudget > 0 else { return 0 }
        return (totalExpenses / monthlyBudget) * 100
    }
    
    private var expenseCategories: [ExpenseCategory] {
        categoryTotals.map { ExpenseCategory(name: $0.key, amount: $0.value, color: categoryColor(for: $0.key)) }
            .sorted { $0.amount > $1.amount }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Food & Dining": return .orange
        case "Transportation": return .blue
        case "Entertainment": return .purple
        case "Shopping": return .pink
        case "Housing": return .brown
        case "Healthcare": return .red
        case "Travel": return .teal
        case "Utilities": return .yellow
        case "Education": return .indigo
        default: return .gray
        }
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
                                    
                                    Text("Expense Tracker")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Monitor your spending across categories")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingExpenseHistory = true
                            }) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                            
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Budget Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Monthly Budget Overview")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Budget Input Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Set Your Monthly Budget:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text("$")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                TextField("2000", text: $monthlyBudgetText)
                                    .font(.title3)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onSubmit {
                                        updateBudget()
                                    }
                                
                                Button("Update") {
                                    updateBudget()
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .disabled(monthlyBudgetText.isEmpty)
                            }
                        }
                        
                        VStack(spacing: 12) {
                            // Budget Utilization Bar
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Budget Used: \(budgetUtilization, specifier: "%.1f")%")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("$\(totalExpenses, specifier: "%.2f") / $\(monthlyBudget, specifier: "%.0f")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(budgetUtilization > 100 ? .red : .green)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 8)
                                            .cornerRadius(4)
                                        
                                        Rectangle()
                                            .fill(budgetUtilization > 100 ? Color.red : Color.green)
                                            .frame(width: min(geometry.size.width * (budgetUtilization / 100), geometry.size.width), height: 8)
                                            .cornerRadius(4)
                                            .animation(.easeInOut(duration: 0.5), value: budgetUtilization)
                                    }
                                }
                                .frame(height: 8)
                            }
                            
                            // Quick Stats
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Remaining")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("$\(max(0, monthlyBudget - totalExpenses), specifier: "%.2f")")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Total Entries")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(expenses.values.flatMap { $0 }.count)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Add Expense Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add New Expense")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 16) {
                            // Category Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Picker("Expense Category", selection: $selectedCategory) {
                                    ForEach(Array(expenses.keys.sorted()), id: \.self) { category in
                                        Label(category, systemImage: categoryIcon(for: category))
                                            .tag(category)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Amount Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Amount")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    Text("$")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0.00", text: $expenseAmount)
                                        .font(.title3)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            
                            // Notes Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes (Optional)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Add a description or note...", text: $expenseNotes, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(2...4)
                            }
                            
                            // Add Button
                            Button(action: addExpense) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                    
                                    Text("Add Expense")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(expenseAmount.isEmpty)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Expense Categories Breakdown
                    if totalExpenses > 0 {
                        ExpenseCategoriesView(categories: expenseCategories, total: totalExpenses)
                    }
                    
                    // Recent Expenses Preview
                    if !expenses.values.flatMap({ $0 }).isEmpty {
                        RecentExpensesPreview(expenses: expenses)
                    }
                }
                .padding()
            }
            .navigationTitle("Prosperly - Overview")
            .sheet(isPresented: $showingExpenseHistory) {
                ExpenseHistoryView(expenses: expenses)
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
        guard let amount = Double(expenseAmount), amount > 0 else { return }
        
        let newExpense = ExpenseItem(
            amount: amount,
            notes: expenseNotes.isEmpty ? nil : expenseNotes,
            date: Date()
        )
        
        expenses[selectedCategory, default: []].append(newExpense)
        
        // Check if budget exceeded
        if (totalExpenses + amount) > monthlyBudget {
            // Track budget exceeded with analytics
            // This is a placeholder and should be replaced with actual analytics tracking
        }
        
        // Clear inputs
        expenseAmount = ""
        expenseNotes = ""
    }
    
    private func updateBudget() {
        guard let newBudget = Double(monthlyBudgetText), newBudget > 0 else { 
            monthlyBudgetText = String(format: "%.0f", monthlyBudget)
            return 
        }
        
        let oldBudget = monthlyBudget
        monthlyBudget = newBudget
        monthlyBudgetText = String(format: "%.0f", newBudget)
        
        // Track budget change with analytics
        // This is a placeholder and should be replaced with actual analytics tracking
    }
}

// Supporting views
struct RecentExpensesPreview: View {
    let expenses: [String: [ExpenseItem]]
    
    private var recentExpenses: [(category: String, item: ExpenseItem)] {
        var allExpenses: [(category: String, item: ExpenseItem)] = []
        
        for (category, items) in expenses {
            for item in items {
                allExpenses.append((category: category, item: item))
            }
        }
        
        return allExpenses
            .sorted { $0.item.date > $1.item.date }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Expenses")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Last 3")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(recentExpenses, id: \.item.id) { expense in
                    RecentExpenseRow(category: expense.category, item: expense.item)
                }
                
                if recentExpenses.isEmpty {
                    Text("No expenses recorded yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct RecentExpenseRow: View {
    let category: String
    let item: ExpenseItem
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Food & Dining": return .orange
        case "Transportation": return .blue
        case "Entertainment": return .purple
        case "Shopping": return .pink
        case "Housing": return .brown
        case "Healthcare": return .red
        case "Travel": return .teal
        case "Utilities": return .yellow
        case "Education": return .indigo
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category indicator
            Circle()
                .fill(categoryColor(for: category))
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(category)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("$\(item.amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(categoryColor(for: category))
                }
                
                if let notes = item.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(item.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExpenseHistoryView: View {
    let expenses: [String: [ExpenseItem]]
    @Environment(\.dismiss) private var dismiss
    
    private var allExpenses: [(category: String, item: ExpenseItem)] {
        var result: [(category: String, item: ExpenseItem)] = []
        
        for (category, items) in expenses {
            for item in items {
                result.append((category: category, item: item))
            }
        }
        
        return result.sorted { $0.item.date > $1.item.date }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allExpenses, id: \.item.id) { expense in
                    ExpenseHistoryRow(category: expense.category, item: expense.item)
                }
            }
            .navigationTitle("Prosperly - Expense History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExpenseHistoryRow: View {
    let category: String
    let item: ExpenseItem
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Food & Dining": return .orange
        case "Transportation": return .blue
        case "Entertainment": return .purple
        case "Shopping": return .pink
        case "Housing": return .brown
        case "Healthcare": return .red
        case "Travel": return .teal
        case "Utilities": return .yellow
        case "Education": return .indigo
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("$\(item.amount, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(categoryColor(for: category))
            }
            
            if let notes = item.notes {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(item.date, format: .dateTime.weekday(.wide).month().day().hour().minute())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ExpenseCategoriesView: View {
    let categories: [ExpenseCategory]
    let total: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(categories.filter { $0.amount > 0 }, id: \.name) { category in
                    ExpenseCategoryRow(category: category, total: total)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ExpenseCategoryRow: View {
    let category: ExpenseCategory
    let total: Double
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return (category.amount / total) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(category.amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    Text("\(percentage, specifier: "%.1f")%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(category.color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.5), value: percentage)
                }
            }
            .frame(height: 4)
        }
    }
} 