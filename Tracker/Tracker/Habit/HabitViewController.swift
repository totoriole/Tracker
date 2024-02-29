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
    func showFirstStubScreen()
}

final class HabitViewController: UIViewController {
    
    var trackersViewController: TrackersActions?
    let cellReuseIdentifier = "HabitViewController"

    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    private var selectedDays: [Weekday] = []
    
    private let colors: [UIColor] = UIColor.selectionColors
    private let emoji: [String] = String.selectionEmojies
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let header: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Новая привычка"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        header.textColor = .blackday
        return header
    }()
    
    private let addTrackerName: UITextField = {
        let addTrackerName = UITextField()
        addTrackerName.translatesAutoresizingMaskIntoConstraints = false
        addTrackerName.placeholder = "Введите название трекера"
        addTrackerName.backgroundColor = .backgroundday
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
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.setTitle("Создать", for: .normal)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.isEnabled = false
        return createButton
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HabitEmojiCell.self, forCellWithReuseIdentifier: "HabitEmojiCell")
        collectionView.register(HabitEmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HabitEmojiHeader.id)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HabitColorCell.self, forCellWithReuseIdentifier: "HabitColorCell")
        collectionView.register(HabitColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HabitColorHeader.id)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteday
        addSubviews()
        activateConstraints()
        
        setupTrackerNameTextField()
        setupTrackersTableView()
        setupEmojiCollectionView()
        setupColorCollectionView()
    }

    private func setupTrackerNameTextField() {
        addTrackerName.delegate = self
    }

    private func setupTrackersTableView() {
        trackersTableView.delegate = self
        trackersTableView.dataSource = self
        trackersTableView.register(HabitViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        trackersTableView.layer.cornerRadius = 16
        trackersTableView.separatorStyle = .none
    }

    private func setupEmojiCollectionView() {
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupColorCollectionView() {
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(header)
        scrollView.addSubview(addTrackerName)
        scrollView.addSubview(trackersTableView)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorCollectionView)
        scrollView.addSubview(createButton)
        scrollView.addSubview(cancelButton)
    }
    
    private func activateConstraints() {
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
            trackersTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            trackersTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            trackersTableView.heightAnchor.constraint(equalToConstant: 150),
            emojiCollectionView.topAnchor.constraint(equalTo: trackersTableView.bottomAnchor, constant: 32),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 222),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 222),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            cancelButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: -4),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            createButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: colorCollectionView.centerXAnchor, constant: 4)
        ])
    }
    
    @objc private func didTapClean() {
        addTrackerName.text = ""
        clearButton.isHidden = true
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let text = addTrackerName.text, !text.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji else {
            return
        }
        
        let newTracker = Tracker(id: UUID(), title: text, color: color, emoji: emoji, schedule: self.selectedDays)
        trackersViewController?.appendTracker(tracker: newTracker)
        trackersViewController?.reload()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SelectedDays
extension HabitViewController: SelectedDays {
    func save(indicies: [Int]) {
        for index in indicies {
            self.selectedDays.append(Weekday.allCases[index])
            self.trackersTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension HabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.createTrackerViewController = self
            present(scheduleViewController, animated: true, completion: nil)
            selectedDays = []
        }
        trackersTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if !isLastCell {
            let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
            separatorView.backgroundColor = .greyYP
            cell.addSubview(separatorView)
        }
    }
}

// MARK: - UITableViewDataSource
extension HabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func textFieldDidChangeSelection(_ textField: UITextField) {
        clearButton.isHidden = textField.text?.isEmpty ?? true
        if textField.text?.isEmpty ?? false {
            createButton.isEnabled = false
            createButton.backgroundColor = .greyYP
        } else {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackday
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitEmojiCell", for: indexPath) as? HabitEmojiCell else {
                return UICollectionViewCell()
            }
            let emojiIndex = indexPath.item % emoji.count
            let selectedEmoji = emoji[emojiIndex]
            
            cell.emojiLabel.text = selectedEmoji
            cell.layer.cornerRadius = 16
            
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitColorCell", for: indexPath) as? HabitColorCell else {
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
    
    func collectionView(_ collectionView:UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == emojiCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HabitEmojiHeader.id, for: indexPath) as? HabitEmojiHeader else {
                return UICollectionReusableView()
            }
            header.headerText = "Emoji"
            return header
        } else if collectionView == colorCollectionView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HabitColorHeader.id, for: indexPath) as? HabitColorHeader else {
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
        let collectionViewWidth = collectionView.bounds.width - 36
        let cellWidth = collectionViewWidth / 6
        return CGSize(width: cellWidth, height: cellWidth)
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
            let cell = collectionView.cellForItem(at: indexPath) as? HabitEmojiCell
            cell?.backgroundColor = .greybackgroundElement
            
            selectedEmoji = cell?.emojiLabel.text
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? HabitColorCell
            cell?.layer.borderWidth = 3
            cell?.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            
            selectedColor = cell?.colorView.backgroundColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? HabitEmojiCell
            cell?.backgroundColor = .whiteday
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? HabitColorCell
            cell?.layer.borderWidth = 0
        }
    }
}
