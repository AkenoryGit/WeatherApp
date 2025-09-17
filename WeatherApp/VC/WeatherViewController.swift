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
    
    private let hourlyTitleLabel: UILabel = {
        let label = UILabel()
        let text = "Подробнее на 24 часа"
        let attributed = NSAttributedString(
            string: text,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        label.attributedText = attributed
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        return label
    }()

    private lazy var hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 100)
        layout.minimumLineSpacing = 6
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.identifier)
        cv.dataSource = self
        return cv
    }()
    
    private let dailyTableView: UITableView = {
        let tv = UITableView()
        tv.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.identifier)
        tv.isScrollEnabled = true
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        return tv
    }()

    private var hourlyData: [(time: String, condition: String, temp: String)] = []

    private let temperatureLabel = UILabel()
    private let minMaxLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let cloudLabel = WeatherDetailItem(imageName: "cloud_icon", text: "--%")
    private let windLabel = WeatherDetailItem(imageName: "wind_icon", text: "--")
    private let precipitationLabel = WeatherDetailItem(imageName: "rain_icon", text: "--%")

    private let detailsStack = UIStackView()
    
    private var dailyData: [(day: String, description: String, icon: String, precip: String, temp: String, date: String)] = []
    
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
        loadHourlyMockData() 

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsChanged),
            name: .settingsChanged,
            object: nil
        )
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openHourlyDetail))
        hourlyTitleLabel.addGestureRecognizer(tap)
        
        view.addSubview(hourlyTitleLabel)
        view.addSubview(hourlyCollectionView)
        view.addSubview(dailyTableView)
        dailyTableView.dataSource = self

        dailyTableView.translatesAutoresizingMaskIntoConstraints = false

        hourlyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hourlyCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hourlyTitleLabel.topAnchor.constraint(equalTo: currentDateTimeLabel.bottomAnchor, constant: 20),
            hourlyTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            hourlyCollectionView.topAnchor.constraint(equalTo: hourlyTitleLabel.bottomAnchor, constant: 12),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            dailyTableView.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: 20),
            dailyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dailyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dailyTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        
        service.fetchHourlyForecast(lat: lat, lon: lon) { [weak self] forecasts in
            DispatchQueue.main.async {
                self?.hourlyData = forecasts.map { forecast in
                    let timeString = self?.formatHour(forecast.time) ?? ""
                    let iconName = WeatherIconMapper.imageName(for: forecast.symbol)
                    let temp = self?.formatTemperature(forecast.temperature) ?? "--"
                    return (time: timeString, condition: iconName, temp: temp)
                }
                self?.hourlyCollectionView.reloadData()
            }
        }
        
        service.fetch7DayForecast(lat: lat, lon: lon) { [weak self] forecasts in
            DispatchQueue.main.async {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                
                let nextDays = forecasts.filter { calendar.startOfDay(for: $0.date) > today }
                
                self?.dailyData = nextDays.map { forecast in
                    let dayFormatter = DateFormatter()
                    dayFormatter.locale = Locale(identifier: "ru_RU")
                    dayFormatter.dateFormat = "E"
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM"
                    
                    let day = dayFormatter.string(from: forecast.date)
                    let dateStr = dateFormatter.string(from: forecast.date)
                    let iconName = WeatherIconMapper.imageName(for: forecast.symbol)
                    let precip = "\(forecast.precipProb)%"
                    let description = WeatherSymbols.descriptions[forecast.symbol] ?? forecast.symbol
                    let temp = "\(self?.formatTemperature(forecast.minTemp) ?? "")–\(self?.formatTemperature(forecast.maxTemp) ?? "")"

                    return (day: day, description: description, icon: iconName, precip: precip, temp: temp, date: dateStr)
                }
                
                self?.dailyTableView.reloadData()
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
    
    private func loadHourlyMockData() {
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
        hourlyCollectionView.reloadData()
    }
    
    @objc private func openHourlyDetail() {
        let vc = HourlyDetailViewController()
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
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
    
    private func formatHour(_ date: Date) -> String {
        let formatter = DateFormatter()
        if SettingsManager.shared.timeFormat == 0 {
            formatter.dateFormat = "h a"
        } else {
            formatter.dateFormat = "HH:mm"
        }
        return formatter.string(from: date)
    }
}

extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
}

extension WeatherViewController: UICollectionViewDataSource, UITableViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyForecastCell.identifier,
            for: indexPath
        ) as! HourlyForecastCell
        let item = hourlyData[indexPath.item]
        cell.configure(time: item.time, condition: item.condition, temp: item.temp)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastCell.identifier, for: indexPath) as! DailyForecastCell
        let item = dailyData[indexPath.row]
        cell.configure(
            day: item.day,
            date: item.date,
            description: item.description,
            icon: item.icon,
            precip: item.precip,
            temp: item.temp
        )
        return cell
    }
}
