//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

final class AddTrackerViewController: UIViewController {
    // Ссылка на контроллер представления списка трекеров
    var trackerScreenViewController: TrackerScreenViewController?
    
    private lazy var textLabel: UILabel = {
        let header = UILabel()
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Создание трекера"
        header.font = .systemFont(ofSize: 16, weight: .medium)
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
        habitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        habitButton.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        return habitButton
    }()
    
    private lazy var irregularButton: UIButton = {
        let irregularButton = UIButton(type: .custom)
        view.addSubview(irregularButton)
        irregularButton.setTitleColor(.whiteday, for: .normal)
        irregularButton.backgroundColor = .blackday
        irregularButton.layer.cornerRadius = 16
        irregularButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        irregularButton.setTitle("Нерегулярное событие", for: .normal)
        irregularButton.addTarget(self, action: #selector(didTapIrregularButton), for: .touchUpInside)
        irregularButton.translatesAutoresizingMaskIntoConstraints = false
        return irregularButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteday
        configureConstraints()
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 295),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    // Обработчик нажатия на кнопку "Привычка"
    @objc private func didTapHabitButton() {
        // Создание экземпляра контроллера для создания привычки
        let addHabit = HabitViewController()
        // Передача ссылки на контроллер представления списка трекеров
        addHabit.trackersViewController = self.trackerScreenViewController
        // Отображение созданного контроллера
        present(addHabit, animated: true)
    }
    // Обработчик нажатия на кнопку "Нерегулярное событие"
    @objc private func didTapIrregularButton() {
        // Создание экземпляра контроллера для создания нерегулярного события
        let addEvent = IrregularEventViewController()
        // Передача ссылки на контроллер представления списка трекеров
        addEvent.trackerScreenViewController = self.trackerScreenViewController
        // Отображение созданного контроллера
        present(addEvent, animated: true)
    }
}
