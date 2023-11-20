//
//  Extensions.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit

extension UIColor {
    static let blueBground = UIColor(named: "BlueBackground")
    static let whiteBG = UIColor(named: "WhiteBackground")
    static let textandbuttonsElement = UIColor(named: "TextandbuttonsElements")
    static let backgroundElement = UIColor(named: "BackgroundElements")
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        return calendar.date(from: dateComponents)
    }
    
    static func from(date: Date) -> Date? {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)

        guard let day = components.day,
              let month = components.month,
              let year = components.year else {
            return nil
        }
        return from(year: year, month: month, day: day)
    }
}
