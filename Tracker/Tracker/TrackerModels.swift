//
//  TrackerModels.swift
//  Tracker
//
//  Created by Toto Tsipun on 10.11.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}


enum Weekday: String, CaseIterable, Comparable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saterday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortForm: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saterday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        guard let first = Self.allCases.firstIndex(of: lhs),
              let second = Self.allCases.firstIndex(of: rhs) 
        else { return false }
        return first < second
    }
}
