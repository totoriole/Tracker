//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

protocol SelectedDays {
    func save(indicies: [Int])
}

final class ScheduleViewController: UIViewController {
    let scheduleCellReuseIdentifier = "ScheduleTableViewCell"
        var createTrackerViewController: SelectedDays?
}
