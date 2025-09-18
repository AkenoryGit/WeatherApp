//
//  DailyForecastCell.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 16.09.2025.
//

import UIKit

final class DailyForecastCell: UITableViewCell {
    static let identifier = "DailyForecastCell"
    
    private let dayLabel = UILabel()
    private let dateLabel = UILabel()
    private let iconView = UIImageView()
    private let precipLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let tempLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 10/255, green: 60/255, blue: 170/255, alpha: 1)
        v.layer.cornerRadius = 8
        v.clipsToBounds = true
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        selectionStyle = .none
        
        [dayLabel, dateLabel, iconView, precipLabel, descriptionLabel, tempLabel, chevronView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        dayLabel.font = .boldSystemFont(ofSize: 16)
        dayLabel.textColor = .white
        
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .white
        
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        
        precipLabel.font = .systemFont(ofSize: 13)
        precipLabel.textColor = .white
        
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        
        tempLabel.font = .systemFont(ofSize: 16, weight: .medium)
        tempLabel.textColor = .white
        
        chevronView.tintColor = .white
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),
            
            dayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            dayLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            
            dateLabel.leadingAnchor.constraint(equalTo: dayLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
            
            iconView.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            precipLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            precipLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: precipLabel.trailingAnchor, constant: 12),
            descriptionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            chevronView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            chevronView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 20),
            
            tempLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -8),
            tempLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(day: String, date: String, description: String, icon: String, precip: String, temp: String) {
        dayLabel.text = day
        dateLabel.text = date
        descriptionLabel.text = description
        precipLabel.text = precip
        tempLabel.text = temp
        iconView.image = UIImage(named: icon)
    }
}
