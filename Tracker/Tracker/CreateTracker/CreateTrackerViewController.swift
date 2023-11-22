//
//  CreateTrackerViewController.swift
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

final class CreateTrackerViewController: UIViewController {
    
    var trackersViewController: TrackersActions? // представляет объект, соответствующий протоколу TrackersActions. Это позволяет взаимодействовать с другим контроллером, реализующим этот протокол.
    let cellReuseIdentifier = "CreateTrackersTableViewCell"
    
    private var selectedDays: [Weekday] = []
    private let colors: [UIColor] = UIColor.selection
    
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
        addTrackerName.translatesAutoresizingMaskIntoConstraints = false
        addTrackerName.placeholder = "Введите название трекера"
        addTrackerName.backgroundColor = .whiteBackground
        addTrackerName.layer.cornerRadius = 16
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        addTrackerName.leftView = leftView
        addTrackerName.leftViewMode = .always
        addTrackerName.keyboardType = .default
        addTrackerName.returnKeyType = .done
        addTrackerName.becomeFirstResponder()
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
        trackersTableView.translatesAutoresizingMaskIntoConstraints = false
        return trackersTableView
    }()
    
    private lazy var clearButton: UIButton = {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(named: "cleanKeyboard"), for: .normal)
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
        trackersTableView.register(CreateTrackerViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        trackersTableView.layer.cornerRadius = 16
        trackersTableView.separatorStyle = .none
    }
// MARK: - Конфигурация пользовательского интерфейса
    // Добавление элементов пользовательского интерфейса в иерархию представлений
    private func configureViews() {
        view.addSubview(header)
        view.addSubview(addTrackerName)
        view.addSubview(trackersTableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    // Настройка ограничений автоматического макетирования
    func configureConstraints() {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTrackerName.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            addTrackerName.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            addTrackerName.heightAnchor.constraint(equalToConstant: 75),
            addTrackerName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addTrackerName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersTableView.topAnchor.constraint(equalTo: addTrackerName.bottomAnchor, constant: 24),
            trackersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: 149),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.width/2) - 4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (view.frame.width/2) + 4)
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
        guard let text = addTrackerName.text, !text.isEmpty else {
            return
        }
        let newTracker = Tracker(title: text, color: colors[Int.random(in: 0..<self.colors.count)], emoji: "😜", schedule: self.selectedDays)
        trackersViewController?.appendTracker(tracker: newTracker)
        trackersViewController?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SelectedDays
extension CreateTrackerViewController: SelectedDays {
    func save(indicies: [Int]) {
        // Реализация сохранения выбранных дней
        for index in indicies {
            self.selectedDays.append(Weekday.allCases[index])
        }
    }
}

// MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
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
extension CreateTrackerViewController: UITableViewDataSource {
    // Количество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    // Возвращаем ячейку для определенного индекса
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создаем и конфигурируем ячейку для таблицы
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? CreateTrackerViewCell else { return UITableViewCell() }
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
extension CreateTrackerViewController: UITextFieldDelegate {
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
