//
//  MainPageViewController.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 11.09.2025.
//

import UIKit

class MainPageViewController: UIPageViewController {

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
        let onboardingVC = OnboardingViewController()
        onboardingVC.modalPresentationStyle = .fullScreen
        present(onboardingVC, animated: true)
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
