//
//  HabitViewController.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

// MARK: - Протокол для действий с трекерами
protocol TrackersActions {
    func appendTracker(tracker: Tracker)
    func reload()
    func showFirstScreen()
}

final class HabitViewController: UIViewController {
    
    var trackersViewController: TrackersActions? // представляет объект, соответствующий протоколу TrackersActions. Это позволяет взаимодействовать с другим контроллером, реализующим этот протокол.
    let cellReuseIdentifier = "CreateTrackersTableViewCell"
    
    private var selectedDays: [Weekday] = []
    private let colors: [UIColor] = UIColor.selectionColors
    private let emojies: [String] = String.selectionEmojies
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    
    private let header: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Новая привычка"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.textColor = .blackday
        return header
    }()
    
    private let addTrackerName: UITextField = {
        let addTrackerName = UITextField()
        addTrackerName.placeholder = "Введите название трекера"
        addTrackerName.backgroundColor = .backgroundday
        addTrackerName.layer.cornerRadius = 16
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        addTrackerName.leftView = leftView
        addTrackerName.leftViewMode = .always
        addTrackerName.keyboardType = .default
        addTrackerName.returnKeyType = .done
        addTrackerName.becomeFirstResponder()
        addTrackerName.translatesAutoresizingMaskIntoConstraints = false
        return addTrackerName
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitleColor(.redtext, for: .normal)
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor.redtext.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private let trackersTableView: UITableView = {
        let trackersTableView = UITableView()
        trackersTableView.layer.cornerRadius = 16
        trackersTableView.separatorStyle = .none
        trackersTableView.translatesAutoresizingMaskIntoConstraints = false
        return trackersTableView
    }()
    
    private lazy var clearButton: UIButton = {
        let clearButton = UIButton(type: .custom)
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(didTapClean), for: .touchUpInside)
        clearButton.isHidden = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
        paddingView.addSubview(clearButton)
        addTrackerName.rightView = paddingView
        addTrackerName.rightViewMode = .whileEditing
        return clearButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton: UIButton = UIButton(type: .custom)
        createButton.setTitleColor(.whiteday, for: .normal)
        createButton.backgroundColor = .greyYP
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitle("Создать", for: .normal)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.isEnabled = false
        return createButton
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EmojiViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.register(EmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiHeader.id)
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(ColorViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.register(ColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ColorHeader.id)
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Начальная настройка
        view.backgroundColor = .whiteday
        configureViews()
        configureConstraints()
        // Настройка делегатов и таблицы
        addTrackerName.delegate = self
        trackersTableView.delegate = self
        trackersTableView.dataSource = self
        trackersTableView.register(HabitViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        //        trackersTableView.layer.cornerRadius = 16
        //        trackersTableView.separatorStyle = .none
    }
    // MARK: - Конфигурация пользовательского интерфейса
    // Добавление элементов пользовательского интерфейса в иерархию представлений
    private func configureViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(header)
        scrollView.addSubview(addTrackerName)
        scrollView.addSubview(trackersTableView)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorCollectionView)
    }
    // Настройка ограничений автоматического макетирования
    func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            header.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            header.heightAnchor.constraint(equalToConstant: 22),
            addTrackerName.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            addTrackerName.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            addTrackerName.heightAnchor.constraint(equalToConstant: 75),
            addTrackerName.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            addTrackerName.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            trackersTableView.topAnchor.constraint(equalTo: addTrackerName.bottomAnchor, constant: 24),
            trackersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: 149),
            emojiCollectionView.topAnchor.constraint(equalTo: trackersTableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 222),
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 222),
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: -4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -34),
            createButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: 4)
        ])
    }
    // MARK: - Обработчики действий кнопок
    @objc private func didTapClean() {
        // Действие для очистки текстового поля
        addTrackerName.text = ""
        clearButton.isHidden = true
    }
    
    @objc private func didTapCancelButton() {
        // Действие для закрытия контроллера представления
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        // Действие для создания нового трекера и уведомления родительского контроллера
        guard let text = addTrackerName.text, !text.isEmpty, let color = selectedColor, let emoji = selectedEmoji else {
            return
        }
        let newTracker = Tracker(title: text, color: color, emoji: emoji, schedule: self.selectedDays)
        trackersViewController?.appendTracker(tracker: newTracker)
        trackersViewController?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SelectedDays
extension HabitViewController: SelectedDays {
    func save(indicies: [Int]) {
        // Реализация сохранения выбранных дней
        for index in indicies {
            self.selectedDays.append(Weekday.allCases[index])
        }
    }
}

// MARK: - UITableViewDelegate
extension HabitViewController: UITableViewDelegate {
    // Устанавливаем высоту ячейки в таблице
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    // Обрабатываем выбор ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            // Создаем экземпляр ScheduleViewController и устанавливаем свойство createTrackerViewController
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.createTrackerViewController = self
            // Показываем ScheduleViewController
            present(scheduleViewController, animated: true, completion: nil)
        }
        // Снимаем выделение с выбранной ячейки
        trackersTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Вызывается перед отображением ячейки
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Создаем и добавляем разделительную линию внизу ячейки
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
        separatorView.backgroundColor = .greyYP
        cell.addSubview(separatorView)
    }
}

// MARK: - UITableViewDataSource
extension HabitViewController: UITableViewDataSource {
    // Количество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    // Возвращаем ячейку для определенного индекса
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создаем и конфигурируем ячейку для таблицы
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? HabitViewCell else { return UITableViewCell() }
        // Обновляем содержимое ячейки в зависимости от индекса
        if indexPath.row == 0 {
            cell.update(with: "Категория")
        } else if indexPath.row == 1 {
            cell.update(with: "Расписание")
        }
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension HabitViewController: UITextFieldDelegate {
    // Вызывается при изменении текста в текстовом поле
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // Скрываем или показываем кнопку очистки в зависимости от наличия текста в поле
        clearButton.isHidden = textField.text?.isEmpty ?? true
        // Включаем или отключаем кнопку создания в зависимости от наличия текста в поле
        if textField.text?.isEmpty ?? false {
            createButton.isEnabled = false
            createButton.backgroundColor = .greyYP
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackday
        }
    }
    // Вызывается при нажатии клавиши Return на клавиатуре
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Завершаем редактирование текстового поля
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension HabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiViewCell else {
                return UICollectionViewCell()
            }
            let emojiIndex = indexPath.item % emojies.count
            let selectedEmoji = emojies[emojiIndex]
            
            cell.emojiLabel.text = selectedEmoji
            cell.layer.cornerRadius = 16
            
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorViewCell else {
                return UICollectionViewCell()
            }
            let colorIndex = indexPath.item % colors.count
            let selectedColor = colors[colorIndex]
            
            cell.colorView.backgroundColor = selectedColor
            cell.layer.cornerRadius = 8
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == emojiCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiHeader.id, for: indexPath) as? EmojiHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Emoji"
            return header
        } else if collectionView == colorCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ColorHeader.id, for: indexPath) as? ColorHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Цвет"
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width-36
        let cellWidth = collectionViewWidth/6
        return CGSize(width: collectionViewWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - UICollectionViewDelegate
extension HabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiViewCell
            cell?.backgroundColor = .backgroundday
            
            selectedEmoji = cell?.emojiLabel.text
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorViewCell
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            selectedColor = cell?.colorView.backgroundColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiViewCell
            cell?.backgroundColor = .whitebackground
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorViewCell
            cell?.layer.borderWidth = 0
        }
    }
}

