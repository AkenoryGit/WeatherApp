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

    private var hourlyData: [HourlyForecast] = []

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
    
    private let dailyHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Ежедневный прогноз"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()

    private let toggleDaysButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "15 дней"
        let attributed = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        button.setAttributedTitle(attributed, for: .normal)
        return button
    }()

    private var isShowing15Days = false

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
        view.addSubview(dailyHeaderLabel)
        view.addSubview(toggleDaysButton)
        view.addSubview(dailyTableView)
        dailyTableView.dataSource = self

        dailyTableView.translatesAutoresizingMaskIntoConstraints = false
        hourlyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hourlyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        dailyHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleDaysButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hourlyTitleLabel.topAnchor.constraint(equalTo: currentDateTimeLabel.bottomAnchor, constant: 20),
            hourlyTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            hourlyCollectionView.topAnchor.constraint(equalTo: hourlyTitleLabel.bottomAnchor, constant: 12),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            dailyHeaderLabel.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: 20),
            dailyHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            toggleDaysButton.centerYAnchor.constraint(equalTo: dailyHeaderLabel.centerYAnchor),
            toggleDaysButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dailyTableView.topAnchor.constraint(equalTo: dailyHeaderLabel.bottomAnchor, constant: 12),
            dailyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dailyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dailyTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        toggleDaysButton.addTarget(self, action: #selector(toggleDaysTapped), for: .touchUpInside)
    }
    
    @objc private func toggleDaysTapped() {
        isShowing15Days.toggle()
        
        let newTitle = isShowing15Days ? "7 дней" : "15 дней"
        let attributed = NSAttributedString(
            string: newTitle,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        toggleDaysButton.setAttributedTitle(attributed, for: .normal)
        
        guard let lat = latitude, let lon = longitude else { return }
        let service = WeatherService()
        
        if isShowing15Days {
            service.fetchOpenMeteoForecast(lat: lat, lon: lon, days: 16) { [weak self] forecasts in
                DispatchQueue.main.async {
                    self?.updateDailyData(with: forecasts, limit: 15)
                }
            }
        } else {
            service.fetchOpenMeteoForecast(lat: lat, lon: lon, days: 8) { [weak self] forecasts in
                DispatchQueue.main.async {
                    self?.updateDailyData(with: forecasts, limit: 7)
                }
            }
        }
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
    
    private func updateDailyData(with forecasts: [DailyForecast], limit: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let nextDays = forecasts.filter { calendar.startOfDay(for: $0.date) > today }
        
        dailyData = Array(nextDays.prefix(limit)).map { mapDailyForecast($0) }
        dailyTableView.reloadData()
    }
    
    private func mapDailyForecast(_ forecast: DailyForecast) -> (day: String, date: String, description: String, icon: String, precip: String, temp: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "E"
        let day = formatter.string(from: forecast.date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        let dateString = dateFormatter.string(from: forecast.date)
        
        let iconName = WeatherIconMapper.imageName(for: forecast.symbol)
        let precip = "\(forecast.precipProb)%"
        let temp = "\(WeatherFormatter.temperature(forecast.minTemp))–\(WeatherFormatter.temperature(forecast.maxTemp))"
        
        let description = WeatherSymbols.descriptions[forecast.symbol] ?? forecast.symbol
        
        return (day: day, date: dateString, description: description, icon: iconName, precip: precip, temp: temp)
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
                self.temperatureLabel.text = WeatherFormatter.temperature(weather.temperature)
                self.descriptionLabel.text = WeatherSymbols.descriptions[weather.symbolCode] ?? weather.description
                self.cloudLabel.updateText("\(weather.cloudiness ?? 0)%")
                self.windLabel.updateText(WeatherFormatter.wind(weather.windSpeed ?? 0))
                self.precipitationLabel.updateText("\(weather.precipitationProbability ?? 0)%")
            }
        }

        service.fetchDailyForecast(lat: lat, lon: lon) { [weak self] min, max in
            DispatchQueue.main.async {
                if let min = min, let max = max {
                    self?.minMaxLabel.text = "\(WeatherFormatter.temperature(min)) / \(WeatherFormatter.temperature(max))"
                } else {
                    self?.minMaxLabel.text = "– / –"
                }
            }
        }
        
        service.fetchHourlyForecast(lat: lat, lon: lon) { [weak self] forecasts in
            DispatchQueue.main.async {
                self?.hourlyData = forecasts
                self?.hourlyCollectionView.reloadData()
            }
        }
        
        service.fetchOpenMeteoForecast(lat: lat, lon: lon, days: 8) { [weak self] forecasts in
            DispatchQueue.main.async {
                self?.updateDailyData(with: forecasts, limit: 7)
            }
        }
        
        SunriseService().fetchSunriseSunset(lat: lat, lon: lon) { [weak self] sunrise, sunset in
            DispatchQueue.main.async {
                self?.daylightArcView.configure(sunrise: sunrise, sunset: sunset)
            }
        }
    }
    
    func refreshWeather() {
        fetchWeather()
    }
    
    private func updateDateTime() {
        currentDateTimeLabel.text = WeatherFormatter.time(Date())
    }
    
    private func loadHourlyMockData() {
        let calendar = Calendar.current
        let now = Date()
        hourlyData = [
            HourlyForecast(
                time: calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) ?? now,
                condition: "weather_cloud",
                tempCelsius: 14,
                description: "Облачно",
                wind: 2.0,
                precip: "20%",
                cloud: "50%"
            ),
            HourlyForecast(
                time: calendar.date(bySettingHour: 3, minute: 0, second: 0, of: now) ?? now,
                condition: "weather_rain",
                tempCelsius: 13,
                description: "Дождь",
                wind: 3.0, 
                precip: "70%",
                cloud: "90%"
            )
        ]
        hourlyCollectionView.reloadData()
    }
    
    @objc private func openHourlyDetail() {
        let vc = HourlyDetailViewController()
        vc.hourlyData = hourlyData
        vc.locationName = self.title
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
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
        cell.configure(
            time: WeatherFormatter.time(item.time),
            condition: item.condition,
            temp: WeatherFormatter.temperature(item.tempCelsius)
        )
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
