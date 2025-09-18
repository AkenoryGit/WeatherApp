//
//  AddLocationViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 11.09.2025.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {

    private let geocoder = CLGeocoder()

    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 160, weight: .bold)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(plusButton)
        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        plusButton.addTarget(self, action: #selector(handleAddCity), for: .touchUpInside)
    }

    @objc private func handleAddCity() {
        let searchVC = CitySearchViewController()
        searchVC.delegate = self
        searchVC.modalPresentationStyle = .pageSheet
        if let sheet = searchVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()] 
        }
        present(searchVC, animated: true)
    }

}

extension AddLocationViewController: CitySearchDelegate {
    func didSelectLocation(_ location: LocationData) {
        LocationStorage().save(location: location)
        reloadMainScreen(with: location)
    }

    private func reloadMainScreen(with location: LocationData) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }

        let mainVC = MainPageViewController()
        let weatherVC = WeatherViewController()
        weatherVC.latitude = location.latitude
        weatherVC.longitude = location.longitude
        weatherVC.title = "\(location.city), \(location.country)"
        mainVC.setPages([weatherVC, AddLocationViewController()])
        mainVC.topBar.cityLabel.text = weatherVC.title

        let nav = UINavigationController(rootViewController: mainVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}

