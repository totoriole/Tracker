//
//  Date+Extension.swift
//  Tracker
//
//  Created by Bumbie on 23.11.2023.
//

import UIKit

//extension Date {
//    static func from(year: Int, month: Int, day: Int) -> Date? {
//        let calendar = Calendar(identifier: .gregorian)
//        var dateComponents = DateComponents()
//        dateComponents.day = day
//        dateComponents.month = month
//        dateComponents.year = year
//        return calendar.date(from: dateComponents)
//    }
//    
//    static func from(date: Date) -> Date? {
//        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
//        
//        guard let day = components.day,
//              let month = components.month,
//              let year = components.year else {
//            return nil
//        }
//        return from(year: year, month: month, day: day)
//    }
//}
//
//
//
//extension UICollectionView {
//    struct GeometricParams {
//        let cellCount: CGFloat
//        let leftInset: CGFloat
//        let rightInset: CGFloat
//        let cellSpacing: CGFloat
//        let paddingWidth: CGFloat
//        
//        init(cellCount: CGFloat, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
//            self.cellCount = cellCount
//            self.leftInset = leftInset
//            self.rightInset = rightInset
//            self.cellSpacing = cellSpacing
//            self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
//        }
//    }
//}
