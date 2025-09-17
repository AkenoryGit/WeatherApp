//
//  WeatherFormatter.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 17.09.2025.
//

import Foundation 

enum WeatherFormatter {
    static func temperature(_ celsius: Double) -> String {
        if SettingsManager.shared.temperatureUnit == 0 {
            return String(format: "%.0f°C", celsius)
        } else {
            let fahrenheit = celsius * 9/5 + 32
            return String(format: "%.0f°F", fahrenheit)
        }
    }

    static func wind(_ speedMs: Double) -> String {
        if SettingsManager.shared.windUnit == 0 {
            let mph = speedMs * 2.23694
            return String(format: "%.1f mi/h", mph)
        } else {
            return String(format: "%.1f м/с", speedMs)
        }
    }

    static func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        if SettingsManager.shared.timeFormat == 0 {
            formatter.dateFormat = "h:mm a, E d MMMM"
        } else {
            formatter.dateFormat = "HH:mm, E d MMMM"
        }
        return formatter.string(from: date)
    }
}
