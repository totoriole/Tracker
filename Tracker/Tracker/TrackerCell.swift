//
//  TrackerCell.swift
//  Tracker
//
//  Created by Toto Tsipun on 07.11.2023.
//

import UIKit
// Протокол делегата для обработки действий с ячейкой трекера
protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    
    // Идентификатор ячейки — используется для регистрации и восстановления:
    static var reuseId = "cell"
    // Слабая ссылка на делегата
    weak var delegate: TrackerCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    private let trackersDaysAmount: UILabel = {
        let trackersDaysAmount = UILabel()
        trackersDaysAmount.frame = CGRect(x: 120, y: 106, width: 101, height: 18)
        trackersDaysAmount.translatesAutoresizingMaskIntoConstraints = false
        trackersDaysAmount.font = .systemFont(ofSize: 12, weight: .medium)
        trackersDaysAmount.textColor = .blackday
        return trackersDaysAmount
    }()
    
    private let trackerDescription: UILabel = {
        let trackerDescription = UILabel()
        trackerDescription.frame = CGRect(x: 120, y: 106, width: 143, height: 34)
        trackerDescription.translatesAutoresizingMaskIntoConstraints = false
        trackerDescription.font = .systemFont(ofSize: 12, weight: .medium)
        trackerDescription.textColor = .whiteday
        trackerDescription.numberOfLines = 0
        trackerDescription.lineBreakMode = .byWordWrapping
        trackerDescription.preferredMaxLayoutWidth = 143
        return trackerDescription
    }()
    
    private lazy var trackerCard: UIView = {
        let trackerCard = UIView()
        trackerCard.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.width * 0.55)
        trackerCard.layer.cornerRadius = 16
        return trackerCard
    }()
    
    private lazy var completedTrackerButton: UIButton = {
        let completedTrackerButton = UIButton(type: .custom)
        completedTrackerButton.frame = CGRect(x: 100, y: 100, width: 34, height: 34)
        completedTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        completedTrackerButton.addTarget(self, action: #selector(didTapCompletedTrackerButton), for: .touchUpInside)
        return completedTrackerButton
    }()
    
    private let emojiBackground: UIView = {
        let emojiBackground = UIView()
        emojiBackground.frame = CGRect(x: 12, y: 12, width: 24, height: 24)
        emojiBackground.backgroundColor = .whiteday
        emojiBackground.layer.cornerRadius = emojiBackground.frame.width / 2
        emojiBackground.layer.opacity = 0.3
        return emojiBackground
    }()
    
    private let trackerEmoji: UILabel = {
        let trackerEmoji = UILabel()
        trackerEmoji.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        trackerEmoji.translatesAutoresizingMaskIntoConstraints = false
        trackerEmoji.font = .systemFont(ofSize: 14, weight: .medium)
        return trackerEmoji
    }()
    
    // Конструктор:
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Настройка внешнего вида ячейки
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        // Настройка элементов интерфейса
        configureViews()
        configureConstraints()
    }
    // Метод, вызываемый при инициализации из интерфейса Builder (Storyboard, XIB и др.)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Метод для настройки содержимого ячейки на основе переданных данных
    func configure(tracker: Tracker, isCompletedToday: Bool, completedDays: Int, indexPath: IndexPath) {
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        self.trackerId = tracker.id
        self.trackerCard.backgroundColor = tracker.color
        trackerDescription.text = tracker.title
        trackerEmoji.text = tracker.emoji
        trackersDaysAmount.text = formatCompletedDays(completedDays)
        
        // Установка иконки на кнопке completedTrackerButton в зависимости от того, был ли трекер завершен в текущий день (isCompletedToday).
        let image = isCompletedToday ? (UIImage(named: "imageCreate")?.withTintColor(trackerCard.backgroundColor ?? .whiteday)) : (UIImage(named: "Pluse")?.withTintColor(trackerCard.backgroundColor ?? .whiteday))
        completedTrackerButton.setImage(image, for: .normal)
    }
    
    private func configureViews() {
        contentView.addSubview(trackersDaysAmount)
        contentView.addSubview(trackerCard)
        contentView.addSubview(completedTrackerButton)
        contentView.addSubview(emojiBackground)
        contentView.addSubview(trackerEmoji)
        contentView.addSubview(trackerDescription)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            trackersDaysAmount.topAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: 16),
            trackersDaysAmount.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            trackerDescription.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            trackerDescription.bottomAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: -12),
            completedTrackerButton.centerYAnchor.constraint(equalTo: trackersDaysAmount.centerYAnchor),
            completedTrackerButton.trailingAnchor.constraint(equalTo: trackerCard.trailingAnchor, constant: -12),
            trackerEmoji.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            trackerEmoji.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
        ])
    }
    // Приватный метод для форматирования строки с количеством завершенных дней в соответствии с русской грамматикой
    private func formatCompletedDays(_ completedDays: Int) -> String {
        let lastDigit = completedDays % 10
        let lastTwoDigits = completedDays % 100
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(completedDays) дней"
        }
        
        switch lastDigit {
        case 1:
            return "\(completedDays) день"
        case 2, 3, 4:
            return "\(completedDays) дня"
        default:
            return "\(completedDays) дней"
        }
    }
    // Обработчик нажатия на кнопку завершения трекера
    @objc private func didTapCompletedTrackerButton() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("no trackerId")
            return
        }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}
