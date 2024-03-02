//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

final class AddTrackerViewController: UIViewController {
    
    var trackerScreenViewController: TrackerScreenViewController?
    
    private lazy var header: UILabel = {
        let header = UILabel()
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Создание трекера"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        header.textColor = .blackday
        return header
    }()
    
    private lazy var habitButton: UIButton = {
        let habitButton = UIButton(type: .custom)
        view.addSubview(habitButton)
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.setTitleColor(.whiteday, for: .normal)
        habitButton.backgroundColor = .blackday
        habitButton.layer.cornerRadius = 16
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        return habitButton
    }()
    
    private lazy var irregularButton: UIButton = {
        let irregularButton = UIButton(type: .custom)
        view.addSubview(irregularButton)
        irregularButton.setTitleColor(.whiteday, for: .normal)
        irregularButton.backgroundColor = .blackday
        irregularButton.layer.cornerRadius = 16
        irregularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularButton.setTitle("Нерегулярное событие", for: .normal)
        irregularButton.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        irregularButton.translatesAutoresizingMaskIntoConstraints = false
        return irregularButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteday
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 295),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func habitButtonTapped() {
        let addHabit = HabitViewController()
        addHabit.trackerScreenViewController = self.trackerScreenViewController
        present(addHabit, animated: true)
    }
    
    @objc private func irregularButtonTapped() {
        let addEvent = IrregularEventViewController()
        addEvent.trackerScreenViewController = self.trackerScreenViewController
        present(addEvent, animated: true)
    }
}
