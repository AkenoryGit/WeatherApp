//
//  WeatherIconMapper.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 15.09.2025.
//

enum WeatherIconMapper {
    static func imageName(for symbol: String) -> String {
        switch symbol {
        case let s where s.contains("clearsky"): return "weather_sun"
        case let s where s.contains("cloud"): return "weather_cloud"
        case let s where s.contains("rain"): return "weather_rain"
        case let s where s.contains("thunder"): return "weather_thunderstorm"
        case let s where s.contains("snow"): return "weather_drops"
        default: return "weather_cloud"
        }
    }
}
