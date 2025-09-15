//
//  MainPageViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 11.09.2025.
//

import UIKit
import CoreLocation

class MainPageViewController: UIPageViewController {

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var pages: [UIViewController] = []
    private let pageControl = UIPageControl()
    let topBar = TopBarView()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        locationManager.delegate = self

        if pages.isEmpty {
            let weatherVC = WeatherViewController()
            let addLocationVC = AddLocationViewController()
            pages = [weatherVC, addLocationVC]
        }

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }

        setupLayout()
        
        topBar.menuButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        topBar.locationButton.addTarget(self, action: #selector(handleGeoTap), for: .touchUpInside)
    }

    func setPages(_ newPages: [UIViewController]) {
        self.pages = newPages
        if let first = newPages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
        pageControl.numberOfPages = newPages.count
        pageControl.currentPage = 0
    }

    private func setupLayout() {
        view.backgroundColor = .systemBackground

        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 44)
        ])

        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        view.subviews
            .compactMap { $0 as? UIScrollView }
            .first?
            .contentInset = UIEdgeInsets(top: 44 + 28, left: 0, bottom: 0, right: 0)
    }
    
    @objc private func handleGeoTap() {
        let alert = UIAlertController(
            title: "Использовать геолокацию?",
            message: "Будет определён ваш текущий город и установлен по умолчанию для прогноза погоды.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { _ in
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.delegate = self
                self.locationManager.requestLocation()
            case .denied, .restricted:
                let settingsAlert = UIAlertController(
                    title: "Геолокация отключена",
                    message: "Чтобы включить доступ, откройте Настройки → WeatherApp → Геолокация.",
                    preferredStyle: .alert
                )
                settingsAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                settingsAlert.addAction(UIAlertAction(title: "В Настройки", style: .default, handler: { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }))
                self.present(settingsAlert, animated: true)
            case .notDetermined:
                self.locationManager.delegate = self
                self.locationManager.requestWhenInUseAuthorization()
            @unknown default:
                break
            }
        }))
        
        present(alert, animated: true)
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .formSheet
        present(settingsVC, animated: true)
    }
}

extension MainPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed,
           let currentVC = viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}

extension MainPageViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
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
                
                DispatchQueue.main.async {
                    self.topBar.cityLabel.text = "\(city), \(country)"
                    
                    if let first = self.pages.first as? AddLocationViewController {
                        let weatherVC = WeatherViewController()
                        weatherVC.latitude = coords.latitude
                        weatherVC.longitude = coords.longitude
                        weatherVC.title = "\(city), \(country)"
                        
                        self.setPages([weatherVC, AddLocationViewController()])
                        self.topBar.cityLabel.text = weatherVC.title
                    }
                    else if let weatherVC = self.pages.first as? WeatherViewController {
                        weatherVC.latitude = coords.latitude
                        weatherVC.longitude = coords.longitude
                        weatherVC.title = "\(city), \(country)"
                        weatherVC.refreshWeather()
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения локации: \(error.localizedDescription)")
    }
}
