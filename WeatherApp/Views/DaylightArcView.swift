//
//  DaylightArcView.swift
//  WeatherApp
//
//  Created by Дмитрий Дудник on 09.09.2025.
//

import UIKit

class DaylightArcView: UIView {
    
    var sunriseTime: String = "--:--"
    var sunsetTime: String = "--:--"
    
    private let sunriseLabel = UILabel()
    private let sunsetLabel = UILabel()
    
    private let sunriseIconView = UIImageView(image: UIImage(named: "sunrise_icon"))
    private let sunsetIconView = UIImageView(image: UIImage(named: "sunset_icon"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = UIColor(red: 10/255, green: 60/255, blue: 170/255, alpha: 1)
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        backgroundColor = UIColor(red: 10/255, green: 60/255, blue: 170/255, alpha: 1)
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    private func setupViews() {
        [sunriseLabel, sunsetLabel].forEach {
            $0.font = .systemFont(ofSize: 12, weight: .medium)
            $0.textColor = .white
            $0.textAlignment = .center
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        [sunriseIconView, sunsetIconView].forEach {
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.height * 0.85)
        let radius = min(bounds.width * 0.5 - 20, bounds.height * 0.8)
        
        let delta: CGFloat = .pi / 16
        let startAngle = CGFloat.pi + delta
        let endAngle = -delta
        
        let startPoint = CGPoint(
            x: arcCenter.x + radius * cos(startAngle),
            y: arcCenter.y + radius * sin(startAngle)
        )
        let endPoint = CGPoint(
            x: arcCenter.x + radius * cos(endAngle),
            y: arcCenter.y + radius * sin(endAngle)
        )
        
        let sunriseX = max(8, min(bounds.width - 32, startPoint.x - 8))
        sunriseIconView.frame = CGRect(x: sunriseX, y: startPoint.y + 4, width: 24, height: 24)
        sunriseLabel.frame = CGRect(
            x: sunriseIconView.center.x - 30,
            y: sunriseIconView.frame.maxY + 2,
            width: 60,
            height: 16
        )
        
        let sunsetX = max(8, min(bounds.width - 32, endPoint.x - 16))
        sunsetIconView.frame = CGRect(x: sunsetX, y: endPoint.y + 4, width: 24, height: 24)
        sunsetLabel.frame = CGRect(
            x: sunsetIconView.center.x - 30,
            y: sunsetIconView.frame.maxY + 2,
            width: 60,
            height: 16
        )
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: rect.midX, y: rect.height * 0.85)
        let radius = min(rect.width * 0.5 - 20, rect.height * 0.8)
        
        let delta: CGFloat = .pi / 12
        let startAngle = CGFloat.pi + delta
        let endAngle = -delta
        
        context.setStrokeColor(UIColor.systemYellow.cgColor)
        context.setLineWidth(3)
        context.addArc(center: center,
                       radius: radius,
                       startAngle: startAngle,
                       endAngle: endAngle,
                       clockwise: false)
        context.strokePath()
    }
    
    func configure(sunrise: Date?, sunset: Date?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        
        if let sunrise = sunrise {
            sunriseTime = formatter.string(from: sunrise)
        }
        if let sunset = sunset {
            sunsetTime = formatter.string(from: sunset)
        }
        sunriseLabel.text = sunriseTime
        sunsetLabel.text = sunsetTime
        
        setNeedsLayout()
        setNeedsDisplay()
    }
}
