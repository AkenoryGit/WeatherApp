//
//  HourlyDetailViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 15.09.2025.
//

import UIKit

class HourlyDetailViewController: UIViewController, UITableViewDataSource {
    private let tableView = UITableView()
    var hourlyData: [(time: String, condition: String, temp: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Прогноз на 24 часа"

        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourlyData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = hourlyData[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.time
        content.secondaryText = item.temp
        content.image = UIImage(named: item.condition)
        cell.contentConfiguration = content

        return cell
    }
}
