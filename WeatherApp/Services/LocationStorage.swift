//
//  LocationStorage.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 15.09.2025.
//

import Foundation

struct LocationData: Codable {
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
}

class LocationStorage {
    private let key = "savedLocation"
    
    func save(location: LocationData) {
        if let data = try? JSONEncoder().encode(location) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load() -> LocationData? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(LocationData.self, from: data)
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
