//
//  TopBarView.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 12.09.2025.
//

import UIKit

class TopBarView: UIView {
    
    let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "menu_icon"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "geo_icon"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "Город"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(menuButton)
        addSubview(locationButton)
        addSubview(cityLabel)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),
            
            menuButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            menuButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 34),
            menuButton.heightAnchor.constraint(equalToConstant: 18),
            
            locationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            locationButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            locationButton.widthAnchor.constraint(equalToConstant: 20),
            locationButton.heightAnchor.constraint(equalToConstant: 26),
            
            cityLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            cityLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
