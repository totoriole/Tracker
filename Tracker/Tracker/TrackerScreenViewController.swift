//
//  ViewController.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit

final class TrackerScreenViewController: UIViewController {
    
    private var trackers: [Tracker] = [] // массив для хранения привычек
    private var categories: [TrackerCategory] = [] // массив для категорий привычек
    private var completedTrackers: [TrackerRecord] = [] // массив выполненых трекеоров
    private var visibleCategories: [TrackerCategory] = [] // отображаемые категории
    private var currentDate = Date()
    
    private var selectedDate: Int? //для фильтрации трекеров в соответствии с выбранным пользователем днем недели.
    private var filterText: String? // для определения, какие трекеры должны быть отображены в коллекции в соответствии с введенным пользователем запросом. Обновляется когда пользователь вводит текст в поле поиска
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var pluseButton: UIButton = {
        guard let image = UIImage(named: "PluseButton") else {
            assert(false, "Failed to create button image")
            assertionFailure("Failed to create button image")
        }
        let imageButton  = UIButton.systemButton(with: image, target: self, action: #selector(self.didTapPluseButton))
        imageButton.accessibilityIdentifier = "AddButton"
        imageButton.tintColor = .blackday
        imageButton.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        imageButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(-10), bottom: 0, right: 0)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        return imageButton
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_Ru")
        picker.calendar.firstWeekday = 2
        picker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .blackday
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchTracker: UISearchTextField = {
        let search = UISearchTextField()
        search.placeholder = "Поиск"
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private let initialTrackerImage: UIImageView = {
        let imageTracker = UIImageView()
        imageTracker.image = UIImage(named: "InitialIcons")
        imageTracker.translatesAutoresizingMaskIntoConstraints = false
        return imageTracker
    }()
    
    private let initialLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .blackday
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plugTrackerImage: UIImageView = {
        let imagePlug = UIImageView()
        imagePlug.image = UIImage(named: "PlugIcons")
        imagePlug.translatesAutoresizingMaskIntoConstraints = false
        return imagePlug
    }()
    
    private let plugLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textColor = .blackday
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whitebackground
        selectCurrentDay() // Выбор текущего дня и настройка отображения
        configureViews()
        configureConstraints()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: pluseButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        print("Before appending category: \(categories)")
        let category = TrackerCategory(title: "Домашние дела", trackers: trackers) // Тестовый пример - создание категории с трекерами
        categories.append(category)
        print("After appending category: \(categories)")
        showFirstScreen()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(HeaderSectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderSectionView.id)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        searchTracker.delegate = self
        
    }
    
    private func configureViews() {
        view.addSubview(pluseButton)
        view.addSubview(datePicker)
        view.addSubview(textLabel)
        view.addSubview(searchTracker)
        view.addSubview(initialTrackerImage)
        view.addSubview(initialLabel)
        view.addSubview(plugLabel)
        view.addSubview(plugTrackerImage)
        view.addSubview(collectionView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTracker.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 7),
            searchTracker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTracker.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            initialTrackerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialTrackerImage.topAnchor.constraint(equalTo: searchTracker.bottomAnchor, constant: 220),
            initialTrackerImage.heightAnchor.constraint(equalToConstant: 80),
            initialTrackerImage.widthAnchor.constraint(equalToConstant: 80),
            initialLabel.centerXAnchor.constraint(equalTo: initialTrackerImage.centerXAnchor),
            initialLabel.topAnchor.constraint(equalTo: initialTrackerImage.bottomAnchor, constant: 8),
            plugTrackerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugTrackerImage.topAnchor.constraint(equalTo: searchTracker.bottomAnchor, constant: 220),
            plugTrackerImage.heightAnchor.constraint(equalToConstant: 80),
            plugTrackerImage.widthAnchor.constraint(equalToConstant: 80),
            plugLabel.topAnchor.constraint(equalTo: plugTrackerImage.bottomAnchor, constant: 8),
            plugLabel.centerXAnchor.constraint(equalTo: plugTrackerImage.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: searchTracker.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    // Обновление выбранного дня недели в соответствии с выбором пользователя
    private func selectCurrentDay() {
        let calendar = Calendar.current
        // Определение номера текущего дня недели с помощью DatePicker
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        // Обновление выбранного дня недели
        self.selectedDate = filterWeekday
    }
    
    // Фильтрация трекеров в соответствии с выбранным днем недели и текстом поиска
    private func filterTrackers() {
        // Фильтрация и обновление отображаемых категорий и трекеров
        visibleCategories = categories.map { category in
            TrackerCategory(title: category.title, trackers: category.trackers.filter { tracker in
                // Фильтрация по расписанию и названию трекера
                let scheduleContains = tracker.schedule?.contains { day in
                    guard let currentDay = self.selectedDate else {
                        return true
                    }
                    return day.rawValue == currentDay
                } ?? false
                let titleContains = tracker.title.contains(self.filterText ?? "") || (self.filterText ?? "").isEmpty
                return scheduleContains && titleContains
            })
        }
        // Удаление пустых категорий и обновление экрана
        .filter { category in
            !category.trackers.isEmpty
        }
        showNextScreen()
        
        collectionView.reloadData()
    }
    
    @objc private func didTapPluseButton() {
        let addTracker = AddTrackerViewController()
        addTracker.trackerScreenViewController = self
        present(addTracker, animated: true, completion: nil)
    }
    
    @objc private func pickerChanged() {
        selectCurrentDay()
        filterTrackers()
    }
}

// MARK: - UITextFieldDelegate
// Обработка изменения значения текстового поля поиска
extension TrackerScreenViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // Обновление текста для фильтрации и запуск фильтрации трекеров
        self.filterText = textField.text
        filterTrackers()
    }
    // для скрытия клавиатуры после ввода текста в текстовом поле
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - TrackersActions
// Добавление нового трекера и обновление экрана
extension TrackerScreenViewController: TrackersActions {
    func appendTracker(tracker: Tracker) {
        self.trackers.append(tracker) // Добавление трекера в массив
        // Обновление массива категорий с учетом нового трекера
        self.categories = self.categories.map { category in
            var updatedTrackers = category.trackers
            updatedTrackers.append(tracker)
            return TrackerCategory(title: category.title, trackers: updatedTrackers)
        }
        // Запуск фильтрации и обновление экрана
        filterTrackers()
    }
    // Обновление данных и перезагрузка коллекции
    func reload() {
        self.collectionView.reloadData()
    }
    // Отображение экрана если нет наличия трекеров
    func showFirstScreen() {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            plugTrackerImage.isHidden = true
            plugLabel.isHidden = true
        } else {
            collectionView.isHidden = false
            initialTrackerImage.isHidden = false
            initialLabel.isHidden = false
        }
    }
    
    // Отображение экрана если есть видимые категории
    func showNextScreen() {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            initialTrackerImage.isHidden = true
            initialLabel.isHidden = true
            plugTrackerImage.isHidden = false
            plugLabel.isHidden = false
        } else {
            collectionView.isHidden = false
            initialTrackerImage.isHidden = false
            initialLabel.isHidden = false
            plugTrackerImage.isHidden = true
            plugLabel.isHidden = true
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerScreenViewController: UICollectionViewDataSource {
    // Количество ячеек в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    // Создаем и настраиваем ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count
        cell.configure(tracker: tracker, isCompletedToday: isCompletedToday, completedDays: completedDays, indexPath: indexPath)
        
        return cell
    }
    // Количество секций в коллекции
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    // Создаем и настраиваем заголовок секции
    func collectionView(_ collectionView:UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderSectionView.id, for: indexPath) as? HeaderSectionView else {
            return UICollectionReusableView()
        }
        // Получаем текст заголовка из видимых категорий
        guard indexPath.section < visibleCategories.count else {
            return header
        }
        let headerText = visibleCategories[indexPath.section].title
        header.headerText = headerText
        return header
    }
    // Проверка, завершен ли трекер в текущий день
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    // Проверка, является ли запись трекера одинаковой
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.id == id && isSameDay
    }
}

// MARK: - TrackerCellDelegate
extension TrackerScreenViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        // Получение текущей даты и выбранной даты
//        let currentDate = Date()
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        // Проверка, что выбранная дата не позднее текущей
        if calendar.compare(selectedDate, to: currentDate, toGranularity: .day) != .orderedDescending {
            // Создание записи о завершении трекера и добавление в массив завершенных
            let trackerRecord = TrackerRecord(id: id, date: selectedDate)
            completedTrackers.append(trackerRecord)
            // Обновление соответствующей ячейки в коллекции
            collectionView.reloadItems(at: [indexPath])
        } else {
            return // Если выбранная дата позднее текущей, прерываем выполнение функции
        }
    }
    // Обработка отмены завершения трекера
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        // Удаление всех записей о завершении трекера с данным идентификатором
        completedTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
        // Обновление соответствующей ячейки в коллекции
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerScreenViewController: UICollectionViewDelegateFlowLayout {
    // Расчет размера ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 5, height: (collectionView.bounds.width / 2 - 5) * 0.88)
    }
    // Установка минимального интервала между ячейками в секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    // Установка минимального интервала между строками в секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    // Установка размера заголовка секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 47)
    }
}
