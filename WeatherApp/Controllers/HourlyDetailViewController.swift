//
//  HourlyDetailViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 15.09.2025.
//

import UIKit

class HourlyDetailViewController: UIViewController, UITableViewDataSource {
    private let tableView = UITableView()
    var hourlyData: [HourlyForecast] = []
    var locationName: String?
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let chartView = HourlyChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Прогноз на 24 часа"

        locationLabel.text = locationName
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.data = hourlyData

        view.addSubview(locationLabel)
        view.addSubview(chartView)
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.register(HourlyForecastDetailCell.self, forCellReuseIdentifier: HourlyForecastDetailCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            chartView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 160),

            tableView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourlyData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HourlyForecastDetailCell.identifier,
            for: indexPath
        ) as! HourlyForecastDetailCell
        let item = hourlyData[indexPath.row]

        cell.configure(
            time: item.time,
            tempCelsius: item.tempCelsius,
            icon: item.condition,
            description: item.description,
            wind: WeatherFormatter.wind(item.wind),
            precip: item.precip,
            cloud: item.cloud
        )
        return cell
    }
}


final class HourlyChartView: UIView {
    var data: [HourlyForecast] = [] {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        clipsToBounds = true
    }

    override func draw(_ rect: CGRect) {
        guard data.count > 1 else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let temps = data.map { $0.tempCelsius }
        guard let maxTemp = temps.max(), let minTemp = temps.min() else { return }
        let tempRange = maxTemp - minTemp == 0 ? 1 : maxTemp - minTemp

        let paddingX: CGFloat = 20
        let stepX = (rect.width - 2 * paddingX) / CGFloat(data.count - 1)
        let baselineY = rect.height - 60

        let linePath = UIBezierPath()
        let fillPath = UIBezierPath()

        let timeFormatter = DateFormatter()
        if SettingsManager.shared.timeFormat == 0 {
            timeFormatter.dateFormat = "h a"
        } else {
            timeFormatter.dateFormat = "HH:mm"
        }

        for (i, item) in data.enumerated() {
            let t = item.tempCelsius

            let displayTemp: String
            if SettingsManager.shared.temperatureUnit == 0 {
                displayTemp = "\(Int(round(t)))°C"
            } else {
                let f = (t * 9/5) + 32
                displayTemp = "\(Int(round(f)))°F"
            }

            let x = paddingX + stepX * CGFloat(i)
            let y = baselineY - ((CGFloat(t - minTemp) / CGFloat(tempRange)) * (baselineY - 40))
            
            let point = CGPoint(x: x, y: y)
            if i == 0 {
                linePath.move(to: point)
                fillPath.move(to: CGPoint(x: x, y: baselineY))
                fillPath.addLine(to: point)
            } else {
                linePath.addLine(to: point)
                fillPath.addLine(to: point)
            }

            let circleRect = CGRect(x: x-3, y: y-3, width: 6, height: 6)
            UIColor.white.setFill()
            context.fillEllipse(in: circleRect)
            UIColor.systemBlue.setStroke()
            context.strokeEllipse(in: circleRect)

            let tempString = NSString(string: displayTemp)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.label
            ]
            tempString.draw(at: CGPoint(x: x-14, y: y-20), withAttributes: attrs)

            if let icon = UIImage(named: item.condition) {
                icon.draw(in: CGRect(x: x-12, y: baselineY+4, width: 24, height: 24))
            }

            let precipString = NSString(string: item.precip)
            precipString.draw(at: CGPoint(x: x-14, y: baselineY+30), withAttributes: [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.label
            ])

            let timeString = NSString(string: timeFormatter.string(from: item.time))
            timeString.draw(at: CGPoint(x: x-15, y: baselineY+44), withAttributes: [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.secondaryLabel
            ])
        }

        if let lastX = linePath.currentPoint.x as CGFloat? {
            fillPath.addLine(to: CGPoint(x: lastX, y: baselineY))
            fillPath.close()
            UIColor.systemBlue.withAlphaComponent(0.2).setFill()
            fillPath.fill()
        }

        UIColor.systemBlue.setStroke()
        linePath.lineWidth = 2
        linePath.stroke()
    }
}
