//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    // Отвечает за состояние выбранного дня
    var selectedDay: Bool = false
    
    private let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Переключатель для выбора дня недели
    private lazy var switchSchedule: UISwitch = {
        let switchSchedule = UISwitch()
        switchSchedule.onTintColor = UIColor.blueBground
        switchSchedule.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
        switchSchedule.translatesAutoresizingMaskIntoConstraints = false
        return switchSchedule
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .backgroundday
        clipsToBounds = true
        
        contentView.addSubview(dayOfWeekLabel)
        addSubview(switchSchedule)
        
        NSLayoutConstraint.activate([
            dayOfWeekLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dayOfWeekLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchSchedule.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switchSchedule.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    // Требуемый инициализатор при использовании storyboard или xib
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Обработчик события переключения (tapping) переключателя
    @objc private func didTapSwitch(_ sender: UISwitch) {
        self.selectedDay = sender.isOn
    }
    // Метод для обновления содержимого ячейки
    func update(with title: String) {
        dayOfWeekLabel.text = title
    }
}
