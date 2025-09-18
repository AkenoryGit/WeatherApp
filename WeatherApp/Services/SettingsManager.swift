//
//  SettingsManager.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 15.09.2025.
//

import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let temperatureUnit = "temperatureUnit"
        static let windUnit = "windUnit"
        static let timeFormat = "timeFormat"
        static let notificationsEnabled = "notificationsEnabled"
    }
    
    var temperatureUnit: Int {
        get { defaults.integer(forKey: Keys.temperatureUnit) }
        set { defaults.set(newValue, forKey: Keys.temperatureUnit) }
    }
    
    var windUnit: Int {
        get { defaults.integer(forKey: Keys.windUnit) }
        set { defaults.set(newValue, forKey: Keys.windUnit) }
    }
    
    var timeFormat: Int {
        get { defaults.integer(forKey: Keys.timeFormat) }
        set { defaults.set(newValue, forKey: Keys.timeFormat) }
    }
    
    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }
    
    private init() {
        if defaults.object(forKey: Keys.temperatureUnit) == nil {
            defaults.set(0, forKey: Keys.temperatureUnit)
        }
        if defaults.object(forKey: Keys.windUnit) == nil {
            defaults.set(1, forKey: Keys.windUnit)
        }
        if defaults.object(forKey: Keys.timeFormat) == nil {
            defaults.set(1, forKey: Keys.timeFormat)
        }
        if defaults.object(forKey: Keys.notificationsEnabled) == nil {
            defaults.set(false, forKey: Keys.notificationsEnabled)
        }
    }
}
