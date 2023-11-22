//
//  Extensions.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit

extension UIColor {
    static let blueBground = UIColor(named: "BlueBackground") ?? defaultBackground
    static let whitebackground = UIColor(named: "White Background") ?? defaultBackground
    static let blackday = UIColor(named: "Black Day") ?? defaultBackground
    static let graybackgroundElement = UIColor(named: "BackgroundElementsGray")
    static let whiteday = UIColor(named: "White Day") ?? defaultForeground
    static let greyYP = UIColor(named: "Grey") ?? defaultForeground
    static let redtext = UIColor(named: "Red text") ?? defaultForeground
    static let backgroundday = UIColor(named: "Background Day") ?? defaultBackground
    
    
    static let defaultBackground = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    static let defaultForeground = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)


    static let selectionColors = [
        UIColor(named: "Color selection 1") ?? defaultForeground,
        UIColor(named: "Color selection 2") ?? defaultForeground,
        UIColor(named: "Color selection 3") ?? defaultForeground,
        UIColor(named: "Color selection 4") ?? defaultForeground,
        UIColor(named: "Color selection 5") ?? defaultForeground,
        UIColor(named: "Color selection 6") ?? defaultForeground,
        UIColor(named: "Color selection 7") ?? defaultForeground,
        UIColor(named: "Color selection 8") ?? defaultForeground,
        UIColor(named: "Color selection 9") ?? defaultForeground,
        UIColor(named: "Color selection 10") ?? defaultForeground,
        UIColor(named: "Color selection 11") ?? defaultForeground,
        UIColor(named: "Color selection 12") ?? defaultForeground,
        UIColor(named: "Color selection 13") ?? defaultForeground,
        UIColor(named: "Color selection 14") ?? defaultForeground,
        UIColor(named: "Color selection 15") ?? defaultForeground,
        UIColor(named: "Color selection 16") ?? defaultForeground,
        UIColor(named: "Color selection 17") ?? defaultForeground,
        UIColor(named: "Color selection 18") ?? defaultForeground
    ]
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

extension Int {
    func days() -> String {
        var ending = ""
        if "1".contains("\(self % 10)") {
            ending = "день"
        }
        
        if "234".contains("\(self % 10)") {
            ending = "дня"
        }
        
        if "567890".contains("\(self % 10)") {
            ending = "дней"
        }
        
        if 11...14 ~= self % 100 {
            ending = "дней"
        }
        return "\(self) " + ending
    }
}

extension UICollectionView {
    struct GeometricParams {
        let cellCount: CGFloat
        let leftInset: CGFloat
        let rightInset: CGFloat
        let cellSpacing: CGFloat
        let paddingWidth: CGFloat
        
        init(cellCount: CGFloat, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
            self.cellCount = cellCount
            self.leftInset = leftInset
            self.rightInset = rightInset
            self.cellSpacing = cellSpacing
            self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
        }
    }
}

extension String {
    static let selectionEmojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
}
