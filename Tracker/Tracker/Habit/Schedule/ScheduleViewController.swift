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
    
    private let scheduleCellReuseIdentifier = "ScheduleTableViewCell"
    var createTrackerViewController: SelectedDays?
    
    private let header: UILabel = {
        let header = UILabel()
        header.text = "Расписание"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        header.textColor = .blackday
        return header
    }()
    
    private let scheduleTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    private lazy var doneScheduleButton: UIButton = {
        let doneScheduleButton = UIButton(type: .custom)
        doneScheduleButton.setTitleColor(.whiteday, for: .normal)
        doneScheduleButton.backgroundColor = .blackday
        doneScheduleButton.layer.cornerRadius = 16
        doneScheduleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneScheduleButton.setTitle("Готово", for: .normal)
        doneScheduleButton.addTarget(self, action: #selector(doneScheduleButtonTapped), for: .touchUpInside)
        return doneScheduleButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteday

        [header, scheduleTableView, doneScheduleButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(ScheduleViewCell.self, forCellReuseIdentifier: scheduleCellReuseIdentifier)
        scheduleTableView.layer.cornerRadius = 16
        scheduleTableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scheduleTableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 30),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            doneScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneScheduleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneScheduleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneScheduleButtonTapped() {
        var selected: [Int] = []
        for (index, elem) in scheduleTableView.visibleCells.enumerated() {
            guard let cell = elem as? ScheduleViewCell else {
                return
            }
            if cell.selectedDay {
                selected.append(index)
            }
        }
        self.createTrackerViewController?.save(indicies: selected)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if !isLastCell {
            let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
            separatorView.backgroundColor = .greyYP
            cell.addSubview(separatorView)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        scheduleTableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: scheduleCellReuseIdentifier, for: indexPath) as? ScheduleViewCell else { return UITableViewCell() }
        
        let dayOfWeek = Weekday.allCases[indexPath.row]
        cell.update(with: "\(dayOfWeek.name)")
        
        return cell
    }
}
