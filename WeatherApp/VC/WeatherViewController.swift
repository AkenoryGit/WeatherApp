//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 08.09.2025.
//

import UIKit

class WeatherViewController: UIViewController {
    
    var latitude: Double?
    var longitude: Double?
    
    private let daylightArcView: DaylightArcView = {
        let view = DaylightArcView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let temperatureLabel = UILabel()
    private let minMaxLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let cloudLabel = WeatherDetailItem(imageName: "cloud_icon", text: "--%")
    private let windLabel = WeatherDetailItem(imageName: "wind_icon", text: "--")
    private let precipitationLabel = WeatherDetailItem(imageName: "rain_icon", text: "--%")

    private let detailsStack = UIStackView()
    
    private let currentDateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fetchWeather()
        updateDateTime()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsChanged),
            name: .settingsChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleSettingsChanged() {
        refreshWeather()
        updateDateTime()
    }

    private func setupUI() {
        temperatureLabel.text = "--°"
        temperatureLabel.font = .systemFont(ofSize: 48, weight: .semibold)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false

        minMaxLabel.text = "– / –"
        minMaxLabel.textColor = .white
        minMaxLabel.font = .systemFont(ofSize: 18)
        minMaxLabel.textAlignment = .center
        minMaxLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.text = "Описание погоды"
        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        detailsStack.axis = .horizontal
        detailsStack.spacing = 16
        detailsStack.alignment = .center
        detailsStack.distribution = .equalSpacing
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        detailsStack.addArrangedSubview(cloudLabel)
        detailsStack.addArrangedSubview(windLabel)
        detailsStack.addArrangedSubview(precipitationLabel)

        view.addSubview(minMaxLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(detailsStack)
        view.addSubview(currentDateTimeLabel)
        
        view.insertSubview(daylightArcView, at: 0)

        NSLayoutConstraint.activate([
            minMaxLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            minMaxLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            temperatureLabel.topAnchor.constraint(equalTo: minMaxLabel.bottomAnchor, constant: 8),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 0),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            detailsStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            detailsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            daylightArcView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 92),
            daylightArcView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daylightArcView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            daylightArcView.heightAnchor.constraint(equalToConstant: 240),
            
            currentDateTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentDateTimeLabel.bottomAnchor.constraint(equalTo: daylightArcView.bottomAnchor, constant: -8)
        ])
    }

    private func fetchWeather() {
        guard let lat = latitude, let lon = longitude else {
            print("Нет координат, пропускаем загрузку погоды")
            return
        }
        
        let service = WeatherService()

        service.fetchCurrentWeather(lat: lat, lon: lon) { [weak self] weather in
            guard let self = self, let weather = weather else { return }
            DispatchQueue.main.async {
                self.temperatureLabel.text = self.formatTemperature(weather.temperature)
                self.descriptionLabel.text = WeatherSymbols.descriptions[weather.symbolCode] ?? weather.description
                self.cloudLabel.updateText("\(weather.cloudiness ?? 0)%")
                self.windLabel.updateText(self.formatWind(weather.windSpeed ?? 0))
                self.precipitationLabel.updateText("\(weather.precipitationProbability ?? 0)%")
            }
        }

        service.fetchDailyForecast(lat: lat, lon: lon) { [weak self] min, max in
            DispatchQueue.main.async {
                if let min = min, let max = max {
                    self?.minMaxLabel.text = "\(self?.formatTemperature(min) ?? "") / \(self?.formatTemperature(max) ?? "")"
                } else {
                    self?.minMaxLabel.text = "– / –"
                }
            }
        }
        
        let sunriseService = SunriseService()
        sunriseService.fetchSunriseSunset(lat: lat, lon: lon) { [weak self] sunrise, sunset in
            DispatchQueue.main.async {
                self?.daylightArcView.configure(sunrise: sunrise, sunset: sunset)
            }
        }
    }
    
    func refreshWeather() {
        fetchWeather()
    }
    
    private func updateDateTime() {
        currentDateTimeLabel.text = formatTime(Date())
    }
}

extension WeatherViewController {
    private func formatTemperature(_ celsius: Double) -> String {
        if SettingsManager.shared.temperatureUnit == 0 {
            return String(format: "%.0f°C", celsius)
        } else {
            let fahrenheit = celsius * 9/5 + 32
            return String(format: "%.0f°F", fahrenheit)
        }
    }

    private func formatWind(_ speedMs: Double) -> String {
        if SettingsManager.shared.windUnit == 0 {
            let mph = speedMs * 2.23694
            return String(format: "%.1f mi/h", mph)
        } else {
            return String(format: "%.1f м/с", speedMs)
        }
    }

    private func formatTime(_ date: Date) -> String {
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

extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
}
