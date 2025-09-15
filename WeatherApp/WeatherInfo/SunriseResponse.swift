//
//  SunriseResponse.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 09.09.2025.
//

import Foundation

struct SunriseResponse: Codable {
    let properties: SunriseProperties
}

struct SunriseProperties: Codable {
    let sunrise: EventTime?
    let sunset: EventTime?
}

struct EventTime: Codable {
    let time: String
    let azimuth: Double?
}

class SunriseService {
    private let session = URLSession.shared
    private let userAgentHeader = "WeatherApp/1.0 your@email.com"
    
    func fetchSunriseSunset(lat: Double, lon: Double, completion: @escaping (Date?, Date?) -> Void) {
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        let offset = TimeZone.current.secondsFromGMT() / 3600
        let offsetString = String(format: "%+03d:00", offset)
        
        let urlString =
        "https://api.met.no/weatherapi/sunrise/3.0/sun?lat=\(lat)&lon=\(lon)&date=\(today)&offset=\(offsetString)"
        
        guard let url = URL(string: urlString) else {
            print("Невалидный URL: \(urlString)")
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue(userAgentHeader, forHTTPHeaderField: "User-Agent")

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Ошибка получения восхода/заката: \(error)")
                completion(nil, nil)
                return
            }

            guard let data = data else {
                print("Пустой ответ от sunrise API")
                completion(nil, nil)
                return
            }
            
            if let raw = String(data: data, encoding: .utf8) {
                print("RAW JSON:\n\(raw)")
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SunriseResponse.self, from: data)

                guard let sunriseString = response.properties.sunrise?.time,
                      let sunsetString = response.properties.sunset?.time else {
                    print("Нет данных о sunrise/sunset в JSON")
                    completion(nil, nil)
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mmxxx"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                let sunriseDate = formatter.date(from: sunriseString)
                let sunsetDate  = formatter.date(from: sunsetString)

                completion(sunriseDate, sunsetDate)
            } catch {
                print("Ошибка парсинга sunrise JSON: \(error)")
                completion(nil, nil)
            }
        }.resume()
    }
}
