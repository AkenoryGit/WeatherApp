//
//  WeatherDetailItem.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 09.09.2025.
//

import UIKit

class WeatherDetailItem: UIStackView {

    private let iconView = UIImageView()
    private let valueLabel = UILabel()

    init(imageName: String, text: String) {
        super.init(frame: .zero)
        axis = .horizontal
        spacing = 4
        alignment = .center
        translatesAutoresizingMaskIntoConstraints = false

        iconView.image = UIImage(named: imageName)
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 18).isActive = true

        valueLabel.text = text
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .white

        addArrangedSubview(iconView)
        addArrangedSubview(valueLabel)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateText(_ text: String) {
        valueLabel.text = text
    }
}
