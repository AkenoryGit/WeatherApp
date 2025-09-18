//
//  CitySearchViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 15.09.2025.
//

import UIKit
import CoreLocation

protocol CitySearchDelegate: AnyObject {
    func didSelectLocation(_ location: LocationData)
}

class CitySearchViewController: UIViewController {

    weak var delegate: CitySearchDelegate?

    private let geocoder = CLGeocoder()
    private var results: [CLPlacemark] = []
    private var searchTimer: Timer?

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Введите город"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func searchCities(query: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.geocoder.geocodeAddressString(query) { placemarks, error in
                if let error = error {
                    print("Ошибка геокодирования: \(error)")
                    return
                }
                self.results = placemarks ?? []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension CitySearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            results.removeAll()
            tableView.reloadData()
            return
        }
        searchCities(query: searchText)
    }
}

extension CitySearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let placemark = results[indexPath.row]
        let city = placemark.locality ?? placemark.name ?? "Неизвестно"
        let country = placemark.country ?? ""
        cell.textLabel?.text = city
        cell.detailTextLabel?.text = country
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placemark = results[indexPath.row]
        guard let location = placemark.location,
              let city = placemark.locality ?? placemark.name,
              let country = placemark.country else { return }

        let chosen = LocationData(
            city: city,
            country: country,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        delegate?.didSelectLocation(chosen)
        dismiss(animated: true)
    }
}
