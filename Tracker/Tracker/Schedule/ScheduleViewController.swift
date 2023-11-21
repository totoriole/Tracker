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
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackday
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var doneScheduleButton: UIButton = {
        let scheduleButton = UIButton(type: .custom)
        scheduleButton.setTitleColor(.whiteday, for: .normal)
        scheduleButton.backgroundColor = .blackday
        scheduleButton.layer.cornerRadius = 16
        scheduleButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        scheduleButton.setTitle("Готово", for: .normal)
        scheduleButton.addTarget(self, action: #selector(didTapDoneScheduleButton), for: .touchUpInside)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        return scheduleButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteday
        configureViews()
        configureConstraints()
        
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.register(ScheduleCell.self, forCellReuseIdentifier: scheduleCellReuseIdentifier)
        scheduleTableView.layer.cornerRadius = 16
        scheduleTableView.separatorStyle = .none
    }
    
    private func configureViews() {
        view.addSubview(textLabel)
        view.addSubview(scheduleTableView)
        view.addSubview(doneScheduleButton)
    }
    
    func configureConstraints(){
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scheduleTableView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 30),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 524),
            doneScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneScheduleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneScheduleButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func didTapDoneScheduleButton() {
        var selected: [Int] = []
        for (index, elem) in scheduleTableView.visibleCells.enumerated() {
            guard let cell = elem as? ScheduleCell else {
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
        
        let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
        separatorView.backgroundColor = .greyYP
        
        cell.addSubview(separatorView)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: scheduleCellReuseIdentifier, for: indexPath) as? ScheduleCell else { return UITableViewCell() }
        
        return cell
    }
}
