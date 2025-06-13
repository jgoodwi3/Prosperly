//
//  ContentView.swift
//  Prosperly
//
//  Created by Jeff Goodwin on 5/30/25.
//  Refactored for Technical Debt Resolution - Phase 1: Modularization
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

// MARK: - ContentView
/// Main entry point for the application
/// Implements clean architecture with proper separation of concerns
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var analytics = SimpleAnalyticsTracker()
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(analytics)
                    .onAppear {
                        analytics.trackScreenView("main_app")
                    }
            } else {
                OnboardingFlow()
                    .environmentObject(analytics)
                    .onAppear {
                        analytics.track(event: "onboarding_started", category: "onboarding")
                    }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// MARK: - Main Tab View
/// Main tab-based navigation view
/// Clean implementation with separated concerns
struct MainTabView: View {
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SimpleBudgetView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Budget")
                }
                .tag(0)
            
            SimpleSavingsGoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
                .tag(1)
            
            SimpleOverviewView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Overview")
                }
                .tag(2)
            
            QuickActionsView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Quick Actions")
                }
                .tag(3)
            
            SimpleProfileView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(Color(red: 0.2, green: 0.55, blue: 0.25))
        .onChange(of: selectedTab) { newValue in
            trackTabChange(to: newValue)
        }
        .onAppear {
            analytics.trackScreenView("main_app")
        }
    }
    
    // MARK: - Analytics Tracking
    private func trackTabChange(to newTab: Int) {
        let tabNames = ["budget", "goals", "overview", "quick_actions", "settings"]
        guard newTab < tabNames.count else { return }
        
        let tabName = tabNames[newTab]
        
        analytics.track(event: "tab_changed", category: "navigation", properties: [
            "to_tab": tabName
        ])
        
        analytics.trackScreenView(tabName)
    }
}

// MARK: - Onboarding Flow
/// Streamlined onboarding flow
struct OnboardingFlow: View {
    @State private var currentStep = 0
    @State private var isLoading = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    var body: some View {
        ZStack {
            // Onboarding step views
            switch currentStep {
            case 0:
                SplashScreenView(
                    onComplete: { startLoading() }
                )
            case 1:
                LoadingScreenView(
                    onComplete: { currentStep = 2 }
                )
            case 2:
                PersonalInfoView(
                    onContinue: { currentStep = 3 }
                )
            case 3:
                PrimaryUseView(
                    onContinue: { currentStep = 4 }
                )
            case 4:
                IncomeSourceView(
                    onContinue: { currentStep = 5 }
                )
            case 5:
                BudgetRangeView(
                    onContinue: { currentStep = 6 }
                )
            case 6:
                IndustryView(
                    onContinue: { currentStep = 7 }
                )
            case 7:
                NotificationPermissionView(
                    onContinue: { currentStep = 8 }
                )
            case 8:
                OnboardingCompleteView(
                    onComplete: { completeOnboarding() }
                )
            default:
                Text("Unknown Step")
                    .foregroundColor(.red)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        .onAppear {
            analytics.trackOnboardingStep("step_\(currentStep)")
        }
    }
    
    private func startLoading() {
        isLoading = true
        currentStep = 1
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Views
/// Individual onboarding step views with completion callbacks

struct SplashScreenView: View {
    let onComplete: () -> Void
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.5, blue: 0.1), 
                    Color(red: 0.05, green: 0.3, blue: 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image("ProsperlyLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    
                    Text("Prosperly")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onComplete()
            }
        }
    }
}

struct LoadingScreenView: View {
    let onComplete: () -> Void
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("ProsperlyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .opacity(index == 0 ? 1.0 : 0.3)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        }
    }
}

struct PersonalInfoView: View {
    let onContinue: () -> Void
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var occupation = ""
    @State private var monthlyIncome = ""
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Image("ProsperlyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 16) {
                    Text("Tell us about yourself")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("This helps us personalize your experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 20) {
                TextField("First name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Last name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Occupation (optional)", text: $occupation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Monthly Income (optional)", text: $monthlyIncome)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("Continue") {
                    onContinue()
                }
                .disabled(firstName.isEmpty || lastName.isEmpty)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(!firstName.isEmpty && !lastName.isEmpty ? Color.green : Color.gray.opacity(0.5))
                )
                
                Button("Skip for now") {
                    onContinue()
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

// Enhanced interactive onboarding views
struct PrimaryUseView: View {
    let onContinue: () -> Void
    @State private var selectedUse: String?
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    private let uses = [
        "Personal budgeting",
        "Expense tracking", 
        "Savings goals",
        "Debt management"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Image("ProsperlyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 16) {
                    Text("What will you use Prosperly for?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Select your primary goal to personalize your experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(uses, id: \.self) { use in
                    Button(action: {
                        selectedUse = use
                        analytics.track(event: "primary_use_selected", category: "onboarding", properties: ["use": use])
                    }) {
                        HStack {
                            Text(use)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedUse == use ? .white : .primary)
                            
                            Spacer()
                            
                            if selectedUse == use {
                                Image(systemName: "checkmark")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedUse == use ? Color.green : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("Continue") {
                    if let selected = selectedUse {
                        UserDefaults.standard.set(selected, forKey: "selectedPrimaryUse")
                    }
                    onContinue()
                }
                .disabled(selectedUse == nil)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedUse != nil ? Color.green : Color.gray.opacity(0.5))
                )
                
                Button("Skip for now") {
                    onContinue()
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

struct IncomeSourceView: View {
    let onContinue: () -> Void
    @State private var selectedIncomeSource: String?
    @State private var customIncomeSource = ""
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    private let incomeSources = [
        "Full-time employment",
        "Part-time employment",
        "Freelance/Contract work",
        "Business owner",
        "Investments",
        "Retirement/Pension",
        "Other"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Image("ProsperlyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 16) {
                    Text("What's your primary income source?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us provide better financial recommendations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(incomeSources, id: \.self) { source in
                        Button(action: {
                            selectedIncomeSource = source
                            analytics.track(event: "income_source_selected", category: "onboarding", properties: ["source": source])
                        }) {
                            HStack {
                                Text(source)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedIncomeSource == source ? .white : .primary)
                                
                                Spacer()
                                
                                if selectedIncomeSource == source {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIncomeSource == source ? Color.green : Color.gray.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Custom income source input if "Other" is selected
                    if selectedIncomeSource == "Other" {
                        TextField("Please specify your income source", text: $customIncomeSource)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("Continue") {
                    let sourceToSave = selectedIncomeSource == "Other" ? customIncomeSource : selectedIncomeSource
                    if let source = sourceToSave, !source.isEmpty {
                        UserDefaults.standard.set(source, forKey: "selectedIncomeSource")
                    }
                    onContinue()
                }
                .disabled(selectedIncomeSource == nil || (selectedIncomeSource == "Other" && customIncomeSource.isEmpty))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill((selectedIncomeSource != nil && !(selectedIncomeSource == "Other" && customIncomeSource.isEmpty)) ? Color.green : Color.gray.opacity(0.5))
                )
                
                Button("Skip for now") {
                    onContinue()
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

struct BudgetRangeView: View {
    let onContinue: () -> Void
    @State private var monthlyBudget = ""
    @State private var selectedRange: String?
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    private let budgetRanges = [
        "Under $1,000",
        "$1,000 - $2,500",
        "$2,500 - $5,000",
        "$5,000 - $10,000",
        "Over $10,000",
        "I'll enter a custom amount"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Image("ProsperlyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 16) {
                    Text("What's your monthly budget?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us create personalized spending categories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(budgetRanges, id: \.self) { range in
                        Button(action: {
                            selectedRange = range
                            analytics.track(event: "budget_range_selected", category: "onboarding", properties: ["range": range])
                        }) {
                            HStack {
                                Text(range)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedRange == range ? .white : .primary)
                                
                                Spacer()
                                
                                if selectedRange == range {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedRange == range ? Color.green : Color.gray.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Custom budget input if "custom amount" is selected
                    if selectedRange == "I'll enter a custom amount" {
                        VStack(spacing: 16) {
                            Text("Enter your monthly budget:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text("$")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                TextField("2,500", text: $monthlyBudget)
                                    .keyboardType(.numberPad)
                                    .font(.title2)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("Continue") {
                    let budgetToSave = selectedRange == "I'll enter a custom amount" ? "$\(monthlyBudget)" : selectedRange
                    if let budget = budgetToSave, !budget.isEmpty {
                        UserDefaults.standard.set(budget, forKey: "selectedBudgetRange")
                    }
                    onContinue()
                }
                .disabled(selectedRange == nil || (selectedRange == "I'll enter a custom amount" && monthlyBudget.isEmpty))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill((selectedRange != nil && !(selectedRange == "I'll enter a custom amount" && monthlyBudget.isEmpty)) ? Color.green : Color.gray.opacity(0.5))
                )
                
                Button("Skip for now") {
                    onContinue()
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

struct IndustryView: View {
    let onContinue: () -> Void
    @State private var selectedIndustry: String?
    @State private var customIndustry = ""
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    private let industries = [
        "Technology",
        "Healthcare",
        "Finance",
        "Education",
        "Retail",
        "Manufacturing",
        "Construction",
        "Transportation",
        "Government",
        "Non-profit",
        "Student",
        "Retired",
        "Other"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Image("ProsperlyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 16) {
                    Text("What industry do you work in?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us provide industry-specific financial insights")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(industries, id: \.self) { industry in
                        Button(action: {
                            selectedIndustry = industry
                            analytics.track(event: "industry_selected", category: "onboarding", properties: ["industry": industry])
                        }) {
                            HStack {
                                Text(industry)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedIndustry == industry ? .white : .primary)
                                
                                Spacer()
                                
                                if selectedIndustry == industry {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIndustry == industry ? Color.green : Color.gray.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Custom industry input if "Other" is selected
                    if selectedIndustry == "Other" {
                        TextField("Please specify your industry", text: $customIndustry)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("Continue") {
                    let industryToSave = selectedIndustry == "Other" ? customIndustry : selectedIndustry
                    if let industry = industryToSave, !industry.isEmpty {
                        UserDefaults.standard.set(industry, forKey: "selectedIndustry")
                    }
                    onContinue()
                }
                .disabled(selectedIndustry == nil || (selectedIndustry == "Other" && customIndustry.isEmpty))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill((selectedIndustry != nil && !(selectedIndustry == "Other" && customIndustry.isEmpty)) ? Color.green : Color.gray.opacity(0.5))
                )
                
                Button("Skip for now") {
                    onContinue()
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

struct NotificationPermissionView: View {
    let onContinue: () -> Void
    @State private var isRequestingPermission = false
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                VStack(spacing: 16) {
                    Text("Stay Updated")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Get notifications for important financial updates, budget alerts, and savings milestones")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 20) {
                // Notification benefits
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Budget overspending alerts")
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Savings goal milestone notifications")
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Bill payment reminders")
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Weekly financial insights")
                            .font(.subheadline)
                        Spacer()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    requestNotificationPermission()
                }) {
                    HStack {
                        if isRequestingPermission {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isRequestingPermission ? "Requesting Permission..." : "Enable Notifications")
                    }
                }
                .disabled(isRequestingPermission)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isRequestingPermission ? Color.gray : Color.green)
                )
                
                Button("Maybe Later") {
                    analytics.track(event: "notifications_skipped", category: "onboarding")
                    UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                    onContinue()
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
    
    private func requestNotificationPermission() {
        isRequestingPermission = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                isRequestingPermission = false
                
                if let error = error {
                    print("Notification permission error: \(error)")
                    analytics.track(event: "notification_permission_error", category: "onboarding", properties: ["error": error.localizedDescription])
                } else {
                    analytics.track(event: "notification_permission_requested", category: "onboarding", properties: ["granted": granted])
                    UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
                }
                
                onContinue()
            }
        }
    }
}

struct OnboardingCompleteView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Image("ProsperlyLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                
                VStack(spacing: 16) {
                    Text("Welcome to Prosperly!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("You're all set! Start managing your finances today.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            Button("Get Started") {
                onComplete()
            }
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green)
            )
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

struct SimpleModalView: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("This feature is coming soon.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .navigationTitle(title)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 