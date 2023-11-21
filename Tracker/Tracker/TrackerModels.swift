//
//  TrackerModels.swift
//  Tracker
//
//  Created by Toto Tsipun on 10.11.2023.
//

import UIKit

struct Tracker {
    let id = UUID()
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
}
enum Weekday: Int, CaseIterable {
    
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var name: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
}

extension Weekday: Comparable {
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        guard
            let first = Self.allCases.firstIndex(of: lhs),
            let second = Self.allCases.firstIndex(of: rhs)
        else {
            return false
        }
        return first < second
    }
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}

