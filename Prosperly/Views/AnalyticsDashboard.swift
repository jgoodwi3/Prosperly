//
//  AnalyticsDashboard.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import SwiftUI
import Foundation

struct AnalyticsDashboard: View {
    @EnvironmentObject private var analytics: SimpleAnalyticsTracker
    
    private var eventsByCategory: [String: Int] {
        Dictionary(grouping: analytics.events, by: { $0.category })
            .mapValues { $0.count }
    }
    
    private var recentEvents: [AnalyticsEventData] {
        Array(analytics.events.suffix(10).reversed())
    }
    
    private var topCategories: [(String, Int)] {
        eventsByCategory.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image("ProsperlyLogo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                    
                                    Text("Analytics Dashboard")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Track your app usage and behavior patterns")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Summary Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Usage Summary")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "Total Events",
                                value: "\(analytics.events.count)",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Categories",
                                value: "\(eventsByCategory.keys.count)",
                                icon: "folder.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Today's Events",
                                value: "\(todaysEventCount)",
                                icon: "calendar.badge.clock",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "Most Active",
                                value: topCategory,
                                icon: "star.fill",
                                color: .purple
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Category Breakdown
                    if !eventsByCategory.isEmpty {
                        CategoryBreakdownView(categories: topCategories)
                    }
                    
                    // Recent Events
                    if !recentEvents.isEmpty {
                        RecentEventsView(events: recentEvents)
                    }
                    
                    // Development Note
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Development Status", systemImage: "info.circle.fill")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✅ Basic Analytics Tracking")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            
                            Text("✅ Real-time Event Collection")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            
                            Text("🚧 Core Data Integration (Next Phase)")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            
                            Text("🚧 Historical Reporting (Next Phase)")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Prosperly - Analytics")
            .onAppear {
                analytics.trackScreenView("analytics_dashboard")
            }
        }
    }
    
    private var todaysEventCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return analytics.events.filter { event in
            Calendar.current.isDate(event.timestamp, inSameDayAs: today)
        }.count
    }
    
    private var topCategory: String {
        eventsByCategory.max(by: { $0.value < $1.value })?.key ?? "None"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct CategoryBreakdownView: View {
    let categories: [(String, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(categories, id: \.0) { category, count in
                    CategoryRow(name: category, count: count, total: categories.reduce(0) { $0 + $1.1 })
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct CategoryRow: View {
    let name: String
    let count: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    private var categoryColor: Color {
        switch name {
        case "onboarding": return .blue
        case "expense": return .orange
        case "budget": return .green
        case "goal": return .purple
        case "navigation": return .teal
        case "settings": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(categoryColor)
                    .frame(width: 12, height: 12)
                
                Text(name.capitalized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    Text("\(percentage * 100, specifier: "%.1f")%")
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
                        .fill(categoryColor)
                        .frame(width: geometry.size.width * percentage, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.5), value: percentage)
                }
            }
            .frame(height: 4)
        }
    }
}

struct RecentEventsView: View {
    let events: [AnalyticsEventData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Events")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(events.indices, id: \.self) { index in
                    let event = events[index]
                    EventRow(event: event)
                    
                    if index < events.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct EventRow: View {
    let event: AnalyticsEventData
    
    private var categoryColor: Color {
        switch event.category {
        case "onboarding": return .blue
        case "expense": return .orange
        case "budget": return .green
        case "goal": return .purple
        case "navigation": return .teal
        case "settings": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(categoryColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(event.eventName.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(event.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(event.category.capitalized)
                    .font(.caption)
                    .foregroundColor(categoryColor)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 2)
    }
}

struct AnalyticsDashboard_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsDashboard()
            .environmentObject(SimpleAnalyticsTracker())
    }
} 