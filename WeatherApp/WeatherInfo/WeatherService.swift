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
