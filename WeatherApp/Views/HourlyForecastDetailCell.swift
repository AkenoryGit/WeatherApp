//
//  HourlyForecastDetailCell.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 17.09.2025.
//

import UIKit

final class HourlyForecastDetailCell: UITableViewCell {
    static let identifier = "HourlyForecastDetailCell"

    private let hourLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .right
        label.textColor = .label
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return iv
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let windIcon = UIImageView(image: UIImage(named: "wind_icon"))
    private let windLabel = UILabel()

    private let precipIcon = UIImageView(image: UIImage(named: "weather_drops"))
    private let precipLabel = UILabel()

    private let cloudIcon = UIImageView(image: UIImage(named: "weather_cloud"))
    private let cloudLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.systemGray6
        selectionStyle = .none

        [windLabel, precipLabel, cloudLabel].forEach {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .label
        }

        [windIcon, precipIcon, cloudIcon].forEach {
            $0.contentMode = .scaleAspectFit
            $0.widthAnchor.constraint(equalToConstant: 20).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }

        let descriptionStack = UIStackView(arrangedSubviews: [iconView, descriptionLabel])
        descriptionStack.axis = .horizontal
        descriptionStack.spacing = 6
        descriptionStack.alignment = .center

        let windStack = UIStackView(arrangedSubviews: [windIcon, windLabel])
        let precipStack = UIStackView(arrangedSubviews: [precipIcon, precipLabel])
        let cloudStack = UIStackView(arrangedSubviews: [cloudIcon, cloudLabel])

        [windStack, precipStack, cloudStack].forEach {
            $0.axis = .horizontal
            $0.spacing = 6
            $0.alignment = .center
        }

        let centerStack = UIStackView(arrangedSubviews: [descriptionStack, windStack, precipStack, cloudStack])
        centerStack.axis = .vertical
        centerStack.spacing = 6
        centerStack.alignment = .leading

        let timeStack = UIStackView(arrangedSubviews: [hourLabel, dayLabel])
        timeStack.axis = .vertical
        timeStack.alignment = .center
        timeStack.spacing = 2
        timeStack.widthAnchor.constraint(equalToConstant: 80).isActive = true

        let mainStack = UIStackView(arrangedSubviews: [timeStack, centerStack, tempLabel])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.distribution = .fill
        mainStack.spacing = 12

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            tempLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(time: Date, tempCelsius: Double, icon: String, description: String, wind: String, precip: String, cloud: String) {
        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "ru_RU")
        hourFormatter.dateFormat = SettingsManager.shared.timeFormat == 0 ? "h a" : "HH:mm"
        hourLabel.text = hourFormatter.string(from: time)

        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "ru_RU")
        dayFormatter.dateFormat = "E"
        dayLabel.text = dayFormatter.string(from: time)

        tempLabel.text = WeatherFormatter.temperature(tempCelsius)
        iconView.image = UIImage(named: icon)
        descriptionLabel.text = description
        windLabel.text = "Ветер: \(wind)"
        precipLabel.text = "Осадки: \(precip)"
        cloudLabel.text = "Облачность: \(cloud)"
    }
}
