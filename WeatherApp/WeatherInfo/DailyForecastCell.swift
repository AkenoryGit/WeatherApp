//
//  DailyForecastCell.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 16.09.2025.
//

import UIKit

final class DailyForecastCell: UITableViewCell {
    static let identifier = "DailyForecastCell"

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return iv
    }()

    private let precipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemBlue
        return label
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none

        let leftStack = UIStackView(arrangedSubviews: [dayLabel, dateLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 8

        stack.addArrangedSubview(leftStack)
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(precipLabel)
        stack.addArrangedSubview(tempLabel)

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(day: String, date: String, icon: String, precip: String, description: String, temp: String) {
        dayLabel.text = day
        dateLabel.text = date
        iconView.image = UIImage(named: icon)
        precipLabel.text = "\(precip)  \(description)"
        tempLabel.text = temp
    }
}
