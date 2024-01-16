//
//  IrregularEventViewController.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func createNewTracker(tracker: Tracker, category: String?)
}

final class IrregularEventViewController: UIViewController {
    // Идентификатор ячейки в таблице
    let irregularEventCellReuseIdentifier = "IrregularEventTableViewCell"
    // Ссылка на объект делегата для передачи данных о созданном трекере
    var trackerScreenViewController: TrackersActions?
    private let trackerCategoryStore = TrackerCategoryStore()
    weak var delegate: CreateTrackerViewControllerDelegate?
    // Массив цветов для нерегулярных событий
    private let colors: [UIColor] = UIColor.selectionColors
    private let emojies: [String] = String.selectionEmojies
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    private var selectedCategory: String?
    private let testCategory = "Домашние дела" // удалить после реализации Категорий в 16-м спринте

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
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EventEmojiCell.self, forCellWithReuseIdentifier: "EventEmojiCell")
        collectionView.register(EventEmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventEmojiHeader.id)
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EventColorCell.self, forCellWithReuseIdentifier: "EventColorCell")
        collectionView.register(EventColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventColorHeader.id)
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
//        irregularEventTableView.layer.cornerRadius = 16
//        irregularEventTableView.separatorStyle = .none
    }
    
    private func configureViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(label)
        scrollView.addSubview(addEventName)
        scrollView.addSubview(irregularEventTableView)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorCollectionView)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 26),
            label.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 22),
            addEventName.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            addEventName.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            addEventName.heightAnchor.constraint(equalToConstant: 75),
            addEventName.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            addEventName.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            irregularEventTableView.topAnchor.constraint(equalTo: addEventName.bottomAnchor, constant: 24),
            irregularEventTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            irregularEventTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            irregularEventTableView.heightAnchor.constraint(equalToConstant: 149),
            emojiCollectionView.topAnchor.constraint(equalTo: irregularEventTableView.bottomAnchor, constant: 32),
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
            createButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            createButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: 4)
        ])
    }
    // Обработчик нажатия на кнопку очистки текстового поля
    @objc private func didTapClean() {
        addEventName.text = ""
        cleanButton.isHidden = true
    }
    // Обработчик нажатия на кнопку отмены
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    // Обработчик нажатия на кнопку создания события
    @objc private func didTapCreateButton() {
        // Проверка, что текстовое поле не пустое
        guard let text = addEventName.text, !text.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor else {
            return
        }
        // Создание нового трекера и передача его в TrackerScreenViewController
        // Создание нового объекта трекера
        let newEvent = Tracker(trackerID: UUID(), title: text, color: color, emoji: emoji, schedule: Weekday.allCases)
        delegate?.createNewTracker(tracker: newEvent, category: selectedCategory)
        // Добавление нового трекера к trackerScreenViewController
//        trackerScreenViewController?.appendTracker(tracker: newEvent)
        do {
            try trackerCategoryStore.addNewTrackerToCategory(to: testCategory, tracker: newEvent)
        } catch {
            print("Error create new tracker to category: \(ErrorCreateNewTracker.errorCreatNewEvent)")
        }
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

// MARK: - UICollectionViewDataSource
extension IrregularEventViewController: UICollectionViewDataSource {
//    количество элементов (ячеек) в секции.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
//    настраиваем ячейку для отображения эмодзи или цвета
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Создаем и настраиваем ячейки для emoji
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventEmojiCell", for: indexPath) as? EventEmojiCell else {
                return UICollectionViewCell()
            }
            let emojiIndex = indexPath.item % emojies.count
            let selectedEmoji = emojies[emojiIndex]
            
            cell.emojiLabel.text = selectedEmoji
            cell.layer.cornerRadius = 16
            
            return cell
            // Создаем и настраиваем ячейки для цвета
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventColorCell", for: indexPath) as? EventColorCell else {
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
        // Создаем и настраиваем заголовок для emoji
        if collectionView == emojiCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EventEmojiHeader.id, for: indexPath) as? EventEmojiHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Emoji"
            return header
        // Создаем и настраиваем заголовок для цвета
        } else if collectionView == colorCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EventColorHeader.id, for: indexPath) as? EventColorHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Цвет"
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension IrregularEventViewController: UICollectionViewDelegateFlowLayout {
//    размер каждой ячейки в коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width-36
//        для создания шести ячеек в строке
        let cellWidth = collectionViewWidth/6
        return CGSize(width: cellWidth, height: cellWidth)
    }
//    минимальный интервал между ячейками внутри одной строки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
//    минимальный интервал между строками коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
//    размер заголовка секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
//    внутренние отступы для секции коллекции, устанавливаем только верхний отступ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - UICollectionViewDelegate
extension IrregularEventViewController: UICollectionViewDelegate {
//    Этот метод вызывается, когда пользователь выбирает элемент в коллекции
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            // Обработка выбора в emojiCollectionView
            let cell = collectionView.cellForItem(at: indexPath) as? EventEmojiCell
            cell?.backgroundColor = .backgroundday
            selectedEmoji = cell?.emojiLabel.text
        } else if collectionView == colorCollectionView {
            // Обработка выбора в colorCollectionView
            let cell = collectionView.cellForItem(at: indexPath) as? EventColorCell
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            selectedColor = cell?.colorView.backgroundColor
        }
    }
    
//    Этот метод вызывается, когда пользователь снимает выбор с элемента в коллекции
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            // Обработка снятия выбора в emojiCollectionView
            let cell = collectionView.cellForItem(at: indexPath) as? EventEmojiCell
            cell?.backgroundColor = .whitebackground
        } else if collectionView == colorCollectionView {
            // Обработка снятия выбора в colorCollectionView
            let cell = collectionView.cellForItem(at: indexPath) as? EventColorCell
            cell?.layer.borderWidth = 0
        }
    }
}

extension IrregularEventViewController {
    enum ErrorCreateNewTracker: Error {
        case errorCreatNewEvent
    }
}

