//
//  HourlyDetailViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 15.09.2025.
//

import UIKit

class HourlyDetailViewController: UIViewController, UITableViewDataSource {
    private let tableView = UITableView()
    private var hourlyData: [(time: String, condition: String, temp: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Прогноз на 24 часа"

        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // тестовые данные
        hourlyData = [
            ("00:00", "weather_cloud", "14°"),
            ("03:00", "weather_rain", "13°"),
            ("06:00", "weather_drops", "15°"),
            ("09:00", "weather_thunderstorm", "18°"),
            ("12:00", "weather_sun", "23°"),
            ("15:00", "weather_cloud", "21°"),
            ("18:00", "weather_rain", "19°"),
            ("21:00", "weather_sun", "16°"),
        ]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourlyData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = hourlyData[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.time
        content.secondaryText = item.temp
        content.image = UIImage(named: item.condition)
        cell.contentConfiguration = content

        return cell
    }

    private func generateHourlyData() -> [(time: String, condition: String, temp: String)] {
        let times24 = ["00:00","03:00","06:00","09:00","12:00","15:00","18:00","21:00"]

        var data: [(String, String, String)] = []
        for (index, time) in times24.enumerated() {
            let condition: String
            switch index {
            case 0: condition = "weather_cloud"
            case 1: condition = "weather_rain"
            case 2: condition = "weather_drops"
            case 3: condition = "weather_thunderstorm"
            case 4: condition = "weather_sun"
            case 5: condition = "weather_cloud"
            case 6: condition = "weather_rain"
            default: condition = "weather_sun"
            }

            let tempValue = 10 + index * 2
            let temp: String
            if SettingsManager.shared.temperatureUnit == 0 {
                temp = "\(tempValue)°C"
            } else {
                let fahrenheit = Int(Double(tempValue) * 1.8 + 32)
                temp = "\(fahrenheit)°F"
            }

            data.append((time, condition, temp))
        }
        return data
    }
}
