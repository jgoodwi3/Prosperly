//
//  ThemeManager.swift
//  Prosperly
//
//  Created by Enhanced Features on 5/30/25.
//

import SwiftUI
import Foundation

// MARK: - Theme Manager

public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @Published public var currentTheme: AppTheme = .light
    @Published public var colorScheme: AppColorScheme = .default
    @Published public var fontSize: FontSize = .medium
    @Published public var enableAnimations: Bool = true
    @Published public var enableHaptics: Bool = true
    
    private let persistenceKey = "ProsperlyThemeSettings"
    
    private init() {
        loadSettings()
    }
    
    public func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        saveSettings()
    }
    
    public func setColorScheme(_ scheme: AppColorScheme) {
        colorScheme = scheme
        saveSettings()
    }
    
    public func setFontSize(_ size: FontSize) {
        fontSize = size
        saveSettings()
    }
    
    public func toggleAnimations() {
        enableAnimations.toggle()
        saveSettings()
    }
    
    public func toggleHaptics() {
        enableHaptics.toggle()
        saveSettings()
    }
    
    private func saveSettings() {
        let settings = ThemeSettings(
            theme: currentTheme,
            colorScheme: colorScheme,
            fontSize: fontSize,
            enableAnimations: enableAnimations,
            enableHaptics: enableHaptics
        )
        
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: persistenceKey)
        }
    }
    
    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey),
              let settings = try? JSONDecoder().decode(ThemeSettings.self, from: data) else {
            return
        }
        
        currentTheme = settings.theme
        colorScheme = settings.colorScheme
        fontSize = settings.fontSize
        enableAnimations = settings.enableAnimations
        enableHaptics = settings.enableHaptics
    }
}

// MARK: - Theme Data Structures

public struct ThemeSettings: Codable {
    public let theme: AppTheme
    public let colorScheme: AppColorScheme
    public let fontSize: FontSize
    public let enableAnimations: Bool
    public let enableHaptics: Bool
    
    public init(theme: AppTheme, colorScheme: AppColorScheme, fontSize: FontSize, enableAnimations: Bool, enableHaptics: Bool) {
        self.theme = theme
        self.colorScheme = colorScheme
        self.fontSize = fontSize
        self.enableAnimations = enableAnimations
        self.enableHaptics = enableHaptics
    }
}

public enum AppTheme: String, CaseIterable, Codable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

public enum AppColorScheme: String, CaseIterable, Codable {
    case `default` = "Default"
    case prosperity = "Prosperity"
    case ocean = "Ocean"
    case sunset = "Sunset"
    case forest = "Forest"
    
    public var primaryColor: Color {
        switch self {
        case .default: return .green
        case .prosperity: return Color(red: 0.1, green: 0.6, blue: 0.1)
        case .ocean: return Color(red: 0.1, green: 0.4, blue: 0.8)
        case .sunset: return Color(red: 0.9, green: 0.5, blue: 0.1)
        case .forest: return Color(red: 0.2, green: 0.5, blue: 0.2)
        }
    }
    
    public var secondaryColor: Color {
        switch self {
        case .default: return Color.blue
        case .prosperity: return Color(red: 0.0, green: 0.4, blue: 0.0)
        case .ocean: return Color(red: 0.0, green: 0.2, blue: 0.6)
        case .sunset: return Color(red: 0.7, green: 0.3, blue: 0.0)
        case .forest: return Color(red: 0.1, green: 0.3, blue: 0.1)
        }
    }
    
    public var gradientColors: [Color] {
        switch self {
        case .default: return [Color.blue, Color.purple]
        case .prosperity: return [primaryColor, secondaryColor]
        case .ocean: return [primaryColor, Color(red: 0.0, green: 0.6, blue: 1.0)]
        case .sunset: return [primaryColor, Color(red: 1.0, green: 0.7, blue: 0.3)]
        case .forest: return [primaryColor, Color(red: 0.4, green: 0.7, blue: 0.4)]
        }
    }
}

public enum FontSize: String, CaseIterable, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"
    
    public var scale: CGFloat {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.15
        case .extraLarge: return 1.3
        }
    }
}

// MARK: - View Extensions

extension View {
    func themedBackground(_ theme: ThemeManager) -> some View {
        self.background(
            LinearGradient(
                colors: theme.colorScheme.gradientColors.map { $0.opacity(0.05) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    func themedCard(_ theme: ThemeManager) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
    }
    
    func themedButton(_ theme: ThemeManager, style: ProsperlyButtonStyle = .primary) -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        style == .primary ? theme.colorScheme.primaryColor : 
                        style == .secondary ? theme.colorScheme.secondaryColor :
                        Color.gray.opacity(0.2)
                    )
            )
            .foregroundColor(style == .primary || style == .secondary ? .white : .primary)
            .scaleEffect(theme.enableAnimations ? 1.0 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: theme.enableAnimations)
    }
    
    func hapticFeedback(enabled: Bool) -> some View {
        self.onTapGesture {
            if enabled {
                // Use simple feedback for now without UIKit dependency
                // This can be enhanced later with proper haptic feedback
            }
        }
    }
}

public enum ProsperlyButtonStyle {
    case primary
    case secondary
    case tertiary
}

// MARK: - Accessibility Extensions

extension View {
    func accessibleTitle(_ title: String) -> some View {
        self.accessibilityLabel(title)
            .accessibilityAddTraits(.isHeader)
    }
    
    func accessibleButton(_ label: String, hint: String? = nil) -> some View {
        self.accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(hint ?? "")
    }
    
    func accessibleValue(_ value: String) -> some View {
        self.accessibilityValue(value)
    }
} 