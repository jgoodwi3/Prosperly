//
//  FinancialCalculationsTests.swift
//  ProsperlyTests
//
//  Created by Technical Debt Resolution
//

import XCTest
@testable import Prosperly

/// Comprehensive unit tests for financial calculations
/// Critical for ensuring accuracy of financial operations
final class FinancialCalculationsTests: XCTestCase {
    
    var dataManager: EnhancedDataManager!
    
    override func setUpWithError() throws {
        super.setUp()
        dataManager = EnhancedDataManager()
    }
    
    override func tearDownWithError() throws {
        dataManager = nil
        super.tearDown()
    }
    
    // MARK: - Budget Calculation Tests
    
    func testBudgetUtilizationCalculation() throws {
        // Given
        let budget = EnhancedBudget(
            category: "Food",
            limit: 500.0,
            period: .monthly,
            alertThreshold: 0.8
        )
        
        let expenses = [
            EnhancedExpenseItem(amount: 150.0, category: "Food", date: Date()),
            EnhancedExpenseItem(amount: 200.0, category: "Food", date: Date()),
            EnhancedExpenseItem(amount: 75.0, category: "Food", date: Date())
        ]
        
        // When
        let utilization = dataManager.calculateBudgetUtilization(budget: budget, expenses: expenses)
        
        // Then
        XCTAssertEqual(utilization.totalSpent, 425.0, accuracy: 0.01)
        XCTAssertEqual(utilization.percentageUsed, 0.85, accuracy: 0.01)
        XCTAssertEqual(utilization.remainingAmount, 75.0, accuracy: 0.01)
        XCTAssertTrue(utilization.isOverThreshold)
        XCTAssertFalse(utilization.isOverBudget)
    }
    
    func testBudgetOverspendingDetection() throws {
        // Given
        let budget = EnhancedBudget(
            category: "Entertainment",
            limit: 200.0,
            period: .monthly,
            alertThreshold: 0.8
        )
        
        let expenses = [
            EnhancedExpenseItem(amount: 150.0, category: "Entertainment", date: Date()),
            EnhancedExpenseItem(amount: 80.0, category: "Entertainment", date: Date())
        ]
        
        // When
        let utilization = dataManager.calculateBudgetUtilization(budget: budget, expenses: expenses)
        
        // Then
        XCTAssertEqual(utilization.totalSpent, 230.0, accuracy: 0.01)
        XCTAssertEqual(utilization.percentageUsed, 1.15, accuracy: 0.01)
        XCTAssertEqual(utilization.remainingAmount, -30.0, accuracy: 0.01)
        XCTAssertTrue(utilization.isOverBudget)
        XCTAssertTrue(utilization.isOverThreshold)
    }
    
    // MARK: - Savings Goal Tests
    
    func testSavingsGoalProgressCalculation() throws {
        // Given
        let goal = EnhancedSavingsGoal(
            name: "Emergency Fund",
            targetAmount: 10000.0,
            currentAmount: 2500.0,
            targetDate: Calendar.current.date(byAdding: .month, value: 12, to: Date())!,
            category: .emergency,
            priority: .high
        )
        
        // When
        let progress = dataManager.calculateSavingsProgress(goal: goal)
        
        // Then
        XCTAssertEqual(progress.percentageComplete, 0.25, accuracy: 0.01)
        XCTAssertEqual(progress.remainingAmount, 7500.0, accuracy: 0.01)
        XCTAssertFalse(progress.isCompleted)
        XCTAssertTrue(progress.isOnTrack)
    }
    
    func testMonthlyContributionRequirement() throws {
        // Given
        let goal = EnhancedSavingsGoal(
            name: "Vacation",
            targetAmount: 6000.0,
            currentAmount: 1000.0,
            targetDate: Calendar.current.date(byAdding: .month, value: 10, to: Date())!,
            category: .travel,
            priority: .medium
        )
        
        // When
        let monthlyRequired = dataManager.calculateRequiredMonthlyContribution(goal: goal)
        
        // Then
        XCTAssertEqual(monthlyRequired, 500.0, accuracy: 0.01)
    }
    
    // MARK: - Recurring Transaction Tests
    
    func testRecurringTransactionCalculation() throws {
        // Given
        let recurringTransaction = RecurringTransaction(
            amount: 1200.0,
            description: "Salary",
            frequency: .monthly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            type: .income,
            category: "Salary"
        )
        
        // When
        let annualAmount = dataManager.calculateAnnualRecurringAmount(transaction: recurringTransaction)
        
        // Then
        XCTAssertEqual(annualAmount, 14400.0, accuracy: 0.01) // 12 months
    }
    
    func testWeeklyRecurringCalculation() throws {
        // Given
        let recurringTransaction = RecurringTransaction(
            amount: 50.0,
            description: "Groceries",
            frequency: .weekly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            type: .expense,
            category: "Food"
        )
        
        // When
        let annualAmount = dataManager.calculateAnnualRecurringAmount(transaction: recurringTransaction)
        
        // Then
        XCTAssertEqual(annualAmount, 2600.0, accuracy: 0.01) // 52 weeks
    }
    
    // MARK: - Financial Insights Tests
    
    func testSpendingTrendAnalysis() throws {
        // Given
        let expenses = [
            EnhancedExpenseItem(amount: 100.0, category: "Food", date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!),
            EnhancedExpenseItem(amount: 120.0, category: "Food", date: Calendar.current.date(byAdding: .day, value: -60, to: Date())!),
            EnhancedExpenseItem(amount: 90.0, category: "Food", date: Calendar.current.date(byAdding: .day, value: -90, to: Date())!)
        ]
        
        // When
        let insights = dataManager.generateSpendingInsights(expenses: expenses)
        
        // Then
        XCTAssertFalse(insights.isEmpty)
        XCTAssertTrue(insights.contains { $0.type == .spendingTrend })
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testZeroBudgetHandling() throws {
        // Given
        let budget = EnhancedBudget(
            category: "Test",
            limit: 0.0,
            period: .monthly,
            alertThreshold: 0.8
        )
        
        let expenses = [
            EnhancedExpenseItem(amount: 10.0, category: "Test", date: Date())
        ]
        
        // When
        let utilization = dataManager.calculateBudgetUtilization(budget: budget, expenses: expenses)
        
        // Then
        XCTAssertTrue(utilization.isOverBudget)
        XCTAssertEqual(utilization.remainingAmount, -10.0, accuracy: 0.01)
    }
    
    func testNegativeAmountHandling() throws {
        // Given
        let goal = EnhancedSavingsGoal(
            name: "Test Goal",
            targetAmount: 1000.0,
            currentAmount: -100.0, // Negative current amount
            targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
            category: .general,
            priority: .low
        )
        
        // When
        let progress = dataManager.calculateSavingsProgress(goal: goal)
        
        // Then
        XCTAssertEqual(progress.percentageComplete, 0.0, accuracy: 0.01)
        XCTAssertEqual(progress.remainingAmount, 1100.0, accuracy: 0.01)
        XCTAssertFalse(progress.isCompleted)
    }
    
    // MARK: - Performance Tests
    
    func testLargeDataSetPerformance() throws {
        // Given
        let budget = EnhancedBudget(
            category: "Food",
            limit: 1000.0,
            period: .monthly,
            alertThreshold: 0.8
        )
        
        var expenses: [EnhancedExpenseItem] = []
        for i in 0..<1000 {
            expenses.append(
                EnhancedExpenseItem(
                    amount: Double(i % 100),
                    category: "Food",
                    date: Date()
                )
            )
        }
        
        // When & Then
        measure {
            _ = dataManager.calculateBudgetUtilization(budget: budget, expenses: expenses)
        }
    }
}

// MARK: - Mock Data Extensions
extension FinancialCalculationsTests {
    
    func createMockBudget(
        category: String = "Test",
        limit: Double = 500.0,
        period: BudgetPeriod = .monthly
    ) -> EnhancedBudget {
        return EnhancedBudget(
            category: category,
            limit: limit,
            period: period,
            alertThreshold: 0.8
        )
    }
    
    func createMockExpenses(
        count: Int = 5,
        category: String = "Test",
        averageAmount: Double = 50.0
    ) -> [EnhancedExpenseItem] {
        return (0..<count).map { index in
            EnhancedExpenseItem(
                amount: averageAmount + Double(index * 10),
                category: category,
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date())!
            )
        }
    }
} 