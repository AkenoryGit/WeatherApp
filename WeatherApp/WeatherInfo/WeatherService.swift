//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 08.09.2025.
//

import Foundation

struct WeatherData {
    let temperature: Double
    let description: String
    let symbolCode: String
    let cloudiness: Int?
    let windSpeed: Double?
    let precipitationProbability: Int?
}

struct ForecastResponse: Codable {
    let properties: ForecastProperties
}

struct ForecastProperties: Codable {
    let timeseries: [ForecastTimeseries]
}

struct ForecastTimeseries: Codable {
    let time: Date
    let data: ForecastData
}

struct ForecastData: Codable {
    let instant: ForecastInstant
    let next1Hours: ForecastNext1Hours?

    enum CodingKeys: String, CodingKey {
        case instant
        case next1Hours = "next_1_hours"
    }
}

struct ForecastInstant: Codable {
    let details: ForecastDetails?
}

struct ForecastNext1Hours: Codable {
    let summary: ForecastSummary
    let details: ForecastNext1HoursDetails?
}

struct ForecastSummary: Codable {
    let symbolCode: String

    enum CodingKeys: String, CodingKey {
        case symbolCode = "symbol_code"
    }
}

struct ForecastNext1HoursDetails: Codable {
    let probabilityOfPrecipitation: Double?

    enum CodingKeys: String, CodingKey {
        case probabilityOfPrecipitation = "probability_of_precipitation"
    }
}

struct ForecastDetails: Codable {
    let airTemperature: Double?
    let cloudAreaFraction: Double?
    let windSpeed: Double?

    enum CodingKeys: String, CodingKey {
        case airTemperature = "air_temperature"
        case cloudAreaFraction = "cloud_area_fraction"
        case windSpeed = "wind_speed"
    }
}

class WeatherService {

    private let session = URLSession.shared
    private let userAgentHeader = "WeatherApp/1.0 your@email.com"

    func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping (WeatherData?) -> Void) {
        let urlString = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue(userAgentHeader, forHTTPHeaderField: "User-Agent")

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Ошибка запроса: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let forecast = try decoder.decode(ForecastResponse.self, from: data)

                if let entry = forecast.properties.timeseries.first,
                   let temp = entry.data.instant.details?.airTemperature,
                   let symbol = entry.data.next1Hours?.summary.symbolCode {

                    let weather = WeatherData(
                        temperature: temp,
                        description: symbol,
                        symbolCode: symbol,
                        cloudiness: Int(entry.data.instant.details?.cloudAreaFraction ?? 0),
                        windSpeed: entry.data.instant.details?.windSpeed,
                        precipitationProbability: Int(entry.data.next1Hours?.details?.probabilityOfPrecipitation ?? 0)
                    )
                    completion(weather)

                } else {
                    completion(nil)
                }

            } catch {
                print("Ошибка парсинга: \(error)")
                completion(nil)
            }

        }.resume()
    }

    func fetchDailyForecast(lat: Double, lon: Double, completion: @escaping (Double?, Double?) -> Void) {
        let urlString = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)"
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue(userAgentHeader, forHTTPHeaderField: "User-Agent")

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Ошибка прогноза: \(error)")
                completion(nil, nil)
                return
            }

            guard let data = data else {
                completion(nil, nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(ForecastResponse.self, from: data)

                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())

                let temps = response.properties.timeseries
                    .filter { calendar.isDate($0.time, inSameDayAs: today) }
                    .compactMap { $0.data.instant.details?.airTemperature }

                completion(temps.min(), temps.max())

            } catch {
                print("Ошибка парсинга прогноза: \(error)")
                completion(nil, nil)
            }
        }.resume()
    }
}

struct HourlyForecast {
    let time: Date
    let temperature: Double
    let symbol: String
}

extension WeatherService {
    func fetchHourlyForecast(lat: Double, lon: Double, completion: @escaping ([HourlyForecast]) -> Void) {
        let urlString = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.setValue(userAgentHeader, forHTTPHeaderField: "User-Agent")

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Ошибка прогноза: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(ForecastResponse.self, from: data)

                let calendar = Calendar.current
                let now = Date()

                let currentHour = calendar.component(.hour, from: now)
                let roundedHour = ((currentHour / 3) + 1) * 3 % 24

                var targetHours: [Int] = []
                var hour = roundedHour
                for _ in 0..<8 {
                    targetHours.append(hour)
                    hour = (hour + 3) % 24
                }

                var forecasts: [HourlyForecast] = []

                for ts in response.properties.timeseries {
                    let hourComponent = calendar.component(.hour, from: ts.time)
                    if targetHours.contains(hourComponent),
                       let temp = ts.data.instant.details?.airTemperature,
                       let symbol = ts.data.next1Hours?.summary.symbolCode {
                        forecasts.append(HourlyForecast(time: ts.time, temperature: temp, symbol: symbol))
                        if forecasts.count == 8 { break }
                    }
                }

                completion(forecasts)

            } catch {
                print("Ошибка парсинга прогноза: \(error)")
                completion([])
            }
        }.resume()
    }
    
}

struct DailyForecast {
    let date: Date
    let minTemp: Double
    let maxTemp: Double
    let symbol: String
    let precipProb: Int
}

extension WeatherService {
    func fetch7DayForecast(lat: Double, lon: Double, completion: @escaping ([DailyForecast]) -> Void) {
        let urlString = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.setValue(userAgentHeader, forHTTPHeaderField: "User-Agent")

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Ошибка прогноза: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(ForecastResponse.self, from: data)

                let calendar = Calendar.current
                let grouped = Dictionary(grouping: response.properties.timeseries) {
                    calendar.startOfDay(for: $0.time)
                }

                var result: [DailyForecast] = []

                for (day, entries) in grouped.sorted(by: { $0.key < $1.key }).prefix(7) {
                    let temps = entries.compactMap { $0.data.instant.details?.airTemperature }
                    guard let min = temps.min(), let max = temps.max() else { continue }

                    let symbol = entries.first?.data.next1Hours?.summary.symbolCode ?? "cloudy"
                    let precip = Int(entries.first?.data.next1Hours?.details?.probabilityOfPrecipitation ?? 0)

                    result.append(DailyForecast(date: day, minTemp: min, maxTemp: max, symbol: symbol, precipProb: precip))
                }

                completion(result)

            } catch {
                print("Ошибка парсинга прогноза: \(error)")
                completion([])
            }
        }.resume()
    }
}
