//
//  IrregularEventViewController.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

final class IrregularEventViewController: UIViewController {
    // Идентификатор ячейки в таблице
    let irregularEventCellReuseIdentifier = "IrregularEventTableViewCell"
    // Ссылка на объект делегата для передачи данных о созданном трекере
    var trackerScreenViewController: TrackersActions?
    // Массив цветов для нерегулярных событий
    private let colors: [UIColor] = UIColor.selectionColors
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .blackday
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addEventName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .backgroundday
        textField.layer.cornerRadius = 16
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = view
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        textField.keyboardType = .default
        textField.becomeFirstResponder()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let irregularEventTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.redtext, for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.redtext.cgColor
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Отменить", for: .normal)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cleanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "cleanKeyboard"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapClean), for: .touchUpInside)
        button.isHidden = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 17))
        paddingView.addSubview(button)
        addEventName.rightView = paddingView
        addEventName.rightViewMode = .whileEditing
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.whiteday, for: .normal)
        button.backgroundColor = .greyYP
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Создать", for: .normal)
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whitebackground
        configureViews()
        configureConstraints()
        // Настройка делегата текстового поля и таблицы
        addEventName.delegate = self
        irregularEventTableView.delegate = self
        irregularEventTableView.dataSource = self
        irregularEventTableView.register(IrregularEventCell.self, forCellReuseIdentifier: irregularEventCellReuseIdentifier)
        irregularEventTableView.layer.cornerRadius = 16
        irregularEventTableView.separatorStyle = .none
    }
    
    private func configureViews() {
        view.addSubview(label)
        view.addSubview(addEventName)
        view.addSubview(irregularEventTableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addEventName.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            addEventName.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            addEventName.heightAnchor.constraint(equalToConstant: 75),
            addEventName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addEventName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            irregularEventTableView.topAnchor.constraint(equalTo: addEventName.bottomAnchor, constant: 24),
            irregularEventTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            irregularEventTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            irregularEventTableView.heightAnchor.constraint(equalToConstant: 75),
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
    // Обработчик нажатия на кнопку очистки текстового поля
    @objc private func didTapClean() {
        addEventName.text = ""
    }
    // Обработчик нажатия на кнопку отмены
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    // Обработчик нажатия на кнопку создания события
    @objc private func didTapCreateButton() {
        // Проверка, что текстовое поле не пустое
        guard let text = addEventName.text, !text.isEmpty else {
            return
        }
        // Создание нового трекера и передача его в TrackerScreenViewController
        // Создание нового объекта трекера
        let newEvent = Tracker(title: text, color: colors[Int.random(in: 0..<self.colors.count)], emoji: "👍", schedule: Weekday.allCases)
        // Добавление нового трекера к trackerScreenViewController
        trackerScreenViewController?.appendTracker(tracker: newEvent)
        // Перезагружаем данные в представлении, чтобы отобразить новый трекер
        trackerScreenViewController?.reload()
        // Закрытие текущего контроллера
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension IrregularEventViewController: UITableViewDelegate {
    // высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    // Снятие выделения с выбранной ячейки после того, как пользователь её выберет.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        irregularEventTableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension IrregularEventViewController: UITableViewDataSource {
    // Количество строк в указанной секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // Создаем и возвращаем ячейку для указанной секции и индекса.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: irregularEventCellReuseIdentifier, for: indexPath) as! IrregularEventCell
        // Используем ячейку IrregularEventCell, и устанавливаем текст "Категория"
        cell.titleLabel.text = "Категория"
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension IrregularEventViewController: UITextFieldDelegate {
    // Вызываем при изменении текста в текстовом поле. . Также настраивается доступность и цвет кнопки создания (createButton) в зависимости от наличия текста.
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // Определяем, пусто ли текстовое поле, и соответственно, скрываем или показываем кнопку очистки (cleanButton)
        cleanButton.isHidden = textField.text?.isEmpty ?? true
        if textField.text?.isEmpty ?? false {
            createButton.isEnabled = false
            createButton.backgroundColor = .greyYP
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackday
        }
    }
    // Вызывается при нажатии на клавишу Return на клавиатуре
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Скрываем клавиатуру, вызывая метод resignFirstResponder()
        textField.resignFirstResponder()
        return true
    }
}
