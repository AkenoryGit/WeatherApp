//
//  OnboardingViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 11.09.2025.
//

import UIKit
import CoreLocation

class OnboardingViewController: UIViewController {

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "weather_logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Разрешить приложению Weather использовать данные о местоположении устройства?"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Чтобы получать более точные прогнозы погоды во время движения или путешествия
           
        Вы можете изменить свой выбор в любое время в настройках приложения
        """
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let allowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ИСПОЛЬЗОВАТЬ МЕСТОПОЛОЖЕНИЕ УСТРОЙСТВА", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let denyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("НЕТ, Я БУДУ ДОБАВЛЯТЬ ЛОКАЦИИ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 10/255, green: 60/255, blue: 170/255, alpha: 1)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        setupLayout()

        allowButton.addTarget(self, action: #selector(handleAllow), for: .touchUpInside)
        denyButton.addTarget(self, action: #selector(handleDeny), for: .touchUpInside)
    }

    private func setupLayout() {
        let contentStack = UIStackView(arrangedSubviews: [logoImageView, titleLabel, descriptionLabel])
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonsStack = UIStackView(arrangedSubviews: [allowButton, denyButton])
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 16
        buttonsStack.alignment = .center
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentStack)
        view.addSubview(buttonsStack)

        NSLayoutConstraint.activate([
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            logoImageView.widthAnchor.constraint(equalToConstant: 220),
            logoImageView.heightAnchor.constraint(equalToConstant: 220),

            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),

            allowButton.widthAnchor.constraint(equalTo: buttonsStack.widthAnchor),
            allowButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func handleAllow() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            let alert = UIAlertController(
                title: "Доступ к геолокации отключён",
                message: "Чтобы включить доступ, откройте Настройки → WeatherApp → Геолокация",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "В Настройки", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            present(alert, animated: true)
        } else {
            locationManager.requestLocation()
        }
    }

    @objc private func handleDeny() {
        openMainScreen(city: nil)
    }

    private func openMainScreen(city: String?, lat: Double? = nil, lon: Double? = nil) {
        UserDefaults.standard.set(true, forKey: "hasOnboarded")

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }

        let mainVC = MainPageViewController()

        if let city = city, let lat = lat, let lon = lon {
            let weatherVC = WeatherViewController()
            weatherVC.title = city
            weatherVC.latitude = lat
            weatherVC.longitude = lon
            mainVC.setPages([weatherVC, AddLocationViewController()])
            mainVC.topBar.cityLabel.text = city
        } else {
            mainVC.setPages([AddLocationViewController()])
            mainVC.topBar.cityLabel.text = "Выберите город"
        }

        let nav = UINavigationController(rootViewController: mainVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}

extension OnboardingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("Геолокация разрешена")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("Нет координат, жду ещё…")
            return
        }

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? "Неизвестно"
                let country = placemark.country ?? ""
                let coords = LocationData(
                    city: city,
                    country: country,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                LocationStorage().save(location: coords)
                self?.openMainScreen(city: "\(city), \(country)", lat: coords.latitude, lon: coords.longitude)
            } else {
                self?.openMainScreen(city: nil)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения локации: \(error.localizedDescription)")
    }
}
