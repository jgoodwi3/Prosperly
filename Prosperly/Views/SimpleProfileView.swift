//
//  SimpleProfileView.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import SwiftUI
import Foundation

struct SimpleProfileView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("currencySymbol") private var currencySymbol = "$"
    @AppStorage("monthlyBudgetReminders") private var monthlyBudgetReminders = true
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    @State private var showingAnalyticsDashboard = false
    
    private let currencyOptions = ["$", "€", "£", "¥", "₹"]
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
                                    
                                    Text("Settings")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Customize your Prosperly experience")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Appearance Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Appearance", systemImage: "paintbrush.fill")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        VStack(spacing: 16) {
                            // Dark Mode Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Dark Mode")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Switch between light and dark themes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isDarkMode)
                                    .labelsHidden()
                                    .onChange(of: isDarkMode) { _, newValue in
                                        analytics.track(event: "dark_mode_toggled", category: "settings", properties: [
                                            "enabled": newValue
                                        ])
                                    }
                            }
                            
                            Divider()
                            
                            // Currency Selection
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Currency")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Choose your preferred currency symbol")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Picker("Currency", selection: $currencySymbol) {
                                    ForEach(currencyOptions, id: \.self) { currency in
                                        Text(currency).tag(currency)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 60)
                                .onChange(of: currencySymbol) { _, newValue in
                                    analytics.track(event: "currency_changed", category: "settings", properties: [
                                        "currency": newValue
                                    ])
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Notifications Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Notifications", systemImage: "bell.fill")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 16) {
                            // Push Notifications
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Push Notifications")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Receive updates about your finances")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .onChange(of: notificationsEnabled) { _, newValue in
                                        analytics.track(event: "notifications_toggled", category: "settings", properties: [
                                            "enabled": newValue
                                        ])
                                    }
                            }
                            
                            Divider()
                            
                            // Budget Reminders
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Budget Reminders")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Monthly budget tracking notifications")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $monthlyBudgetReminders)
                                    .labelsHidden()
                                    .disabled(!notificationsEnabled)
                                    .onChange(of: monthlyBudgetReminders) { _, newValue in
                                        analytics.track(event: "budget_reminders_toggled", category: "settings", properties: [
                                            "enabled": newValue
                                        ])
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Security Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Security", systemImage: "lock.shield.fill")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 16) {
                            // Biometric Authentication
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Biometric Authentication")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Use Face ID or Touch ID to secure your app")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $biometricEnabled)
                                    .labelsHidden()
                                    .onChange(of: biometricEnabled) { _, newValue in
                                        analytics.track(event: "biometric_toggled", category: "settings", properties: [
                                            "enabled": newValue
                                        ])
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Developer Tools
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Developer Tools", systemImage: "wrench.and.screwdriver.fill")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                analytics.track(event: "analytics_dashboard_opened", category: "settings")
                                showingAnalyticsDashboard = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                    Text("View Analytics Dashboard")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // App Information
                    VStack(alignment: .leading, spacing: 16) {
                        Label("About", systemImage: "info.circle.fill")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Version")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("1.0.0")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Build")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("2024.1")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Analytics Events")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("\(analytics.events.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            analytics.track(event: "reset_data_attempted", category: "settings")
                            // Reset app data action
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset App Data")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            analytics.track(event: "export_data_attempted", category: "settings")
                            // Export data action
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Data")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Prosperly - Settings")
            .sheet(isPresented: $showingAnalyticsDashboard) {
                AnalyticsDashboard()
                    .environmentObject(analytics)
            }
            .onAppear {
                analytics.trackScreenView("settings")
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
} 