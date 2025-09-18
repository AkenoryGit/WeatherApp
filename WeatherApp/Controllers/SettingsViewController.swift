//
//  SettingsViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 15.09.2025.
//

import UIKit

class SettingsViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Настройки"
        label.font = .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tempLabel = SettingsViewController.makeLabel("Температура")
    private let windLabel = SettingsViewController.makeLabel("Скорость ветра")
    private let timeLabel = SettingsViewController.makeLabel("Формат времени")
    private let notifyLabel = SettingsViewController.makeLabel("Уведомления")

    private let tempControl = UISegmentedControl(items: ["C", "F"])
    private let windControl = UISegmentedControl(items: ["Mi", "Km"])
    private let timeControl = UISegmentedControl(items: ["12", "24"])
    private let notifyControl = UISegmentedControl(items: ["On", "Off"])

    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Установить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cloudOne: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloud_one"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let cloudTwo: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloud_two"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let cloudThree: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloud_three"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 10/255, green: 60/255, blue: 170/255, alpha: 1)

        setupControls()
        setupLayout()
        loadSettings()
    }

    private func setupControls() {
        [tempControl, windControl, timeControl, notifyControl].forEach {
            $0.selectedSegmentTintColor = .systemOrange
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 150).isActive = true
        }

        applyButton.addTarget(self, action: #selector(applySettings), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(cloudOne)
        view.addSubview(cloudTwo)
        view.addSubview(cloudThree)

        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        let tempStack = makeRow(label: tempLabel, control: tempControl)
        let windStack = makeRow(label: windLabel, control: windControl)
        let timeStack = makeRow(label: timeLabel, control: timeControl)
        let notifyStack = makeRow(label: notifyLabel, control: notifyControl)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            tempStack,
            windStack,
            timeStack,
            notifyStack,
            applyButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            cloudOne.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cloudOne.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -70),
            cloudOne.widthAnchor.constraint(equalToConstant: 300),
            cloudOne.heightAnchor.constraint(equalToConstant: 100),

            cloudTwo.bottomAnchor.constraint(equalTo: container.topAnchor, constant: -20),
            cloudTwo.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 130),
            cloudTwo.widthAnchor.constraint(equalToConstant: 180),
            cloudTwo.heightAnchor.constraint(equalToConstant: 90),

            cloudThree.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 40),
            cloudThree.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cloudThree.widthAnchor.constraint(equalToConstant: 240),
            cloudThree.heightAnchor.constraint(equalToConstant: 120),

            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),

            applyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func applySettings() {
        SettingsManager.shared.temperatureUnit = tempControl.selectedSegmentIndex
        SettingsManager.shared.windUnit = windControl.selectedSegmentIndex
        SettingsManager.shared.timeFormat = timeControl.selectedSegmentIndex
        SettingsManager.shared.notificationsEnabled = (notifyControl.selectedSegmentIndex == 0)

        NotificationCenter.default.post(name: .settingsChanged, object: nil)
        dismiss(animated: true)
    }

    private func loadSettings() {
        let manager = SettingsManager.shared
        tempControl.selectedSegmentIndex = manager.temperatureUnit
        windControl.selectedSegmentIndex = manager.windUnit
        timeControl.selectedSegmentIndex = manager.timeFormat
        notifyControl.selectedSegmentIndex = manager.notificationsEnabled ? 0 : 1
    }
}

extension SettingsViewController {
    private static func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }

    private func makeRow(label: UILabel, control: UISegmentedControl) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [label, control])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }
}
