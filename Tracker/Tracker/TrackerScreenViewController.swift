//
//  ViewController.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit

final class TrackerScreenViewController: UIViewController {

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var pluseButton: UIButton = {
        guard let image = UIImage(named: "PluseButton") else {
            assert(false, "Failed to create button image")
            assertionFailure("Failed to create button image")
        }
        let imageButton  = UIButton.systemButton(with: image, target: self, action: #selector(self.didTapPluseButton))
        imageButton.accessibilityIdentifier = "AddButton"
        imageButton.tintColor = .textandbuttonsElement
        imageButton.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        imageButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(-10), bottom: 0, right: 0)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        
        return imageButton
    }()
    
    private lazy var dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy" // Формат даты
        return formatter
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.backgroundColor = .whiteBackground
        picker.maximumDate = Date()
        
        if let currentLocale = Locale.current.languageCode {
            picker.locale = Locale(identifier: currentLocale)
        } else {
            picker.locale = Locale(identifier: "ru_RU")
        }// Установка локали для форматирования
        picker.calendar.firstWeekday = 2
        
        // Использование DateFormatter для отображения даты в сокращенном формате
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        // Обработка изменений в UIDatePicker
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        
        // Настройка положения и размеров
        picker.frame = CGRect(x: 0, y: 0, width: 100, height: 34) // размеры и положение
        
        return picker
    }()
    
    private var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .textandbuttonsElement
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private var initialTrackerImage: UIImageView = {
        let imageTracker = UIImageView()
        imageTracker.image = UIImage(named: "InitialIcons")
        imageTracker.translatesAutoresizingMaskIntoConstraints = false
        return imageTracker
    }()
    
    private var initialLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .textandbuttonsElement
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var plugTrackerImage: UIImageView = {
        let imagePlug = UIImageView()
        imagePlug.image = UIImage(named: "PlugIcons")
        imagePlug.translatesAutoresizingMaskIntoConstraints = false
        return imagePlug
    }()
    
    private var plugLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textColor = .textandbuttonsElement
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .whiteBackground
        configureViews()
        configureConstraints()
        showInitialOption()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: pluseButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    
    internal func configureViews() {
        view.addSubview(pluseButton)
        view.addSubview(datePicker)
        view.addSubview(textLabel)
        view.addSubview(searchBar)
        view.addSubview(initialTrackerImage)
        view.addSubview(initialLabel)
        view.addSubview(plugLabel)
        view.addSubview(plugTrackerImage)
        
    }
    
    internal func configureConstraints() {
        NSLayoutConstraint.activate([
            
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            initialTrackerImage.widthAnchor.constraint(equalToConstant: 80),
            initialTrackerImage.heightAnchor.constraint(equalToConstant: 80),
            initialTrackerImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            initialTrackerImage.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 220),
            
            initialLabel.topAnchor.constraint(equalTo: initialTrackerImage.bottomAnchor, constant: 8),
            initialLabel.centerXAnchor.constraint(equalTo: initialTrackerImage.centerXAnchor),
            
            plugTrackerImage.widthAnchor.constraint(equalToConstant: 80),
            plugTrackerImage.heightAnchor.constraint(equalToConstant: 80),
            plugTrackerImage.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            plugTrackerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugTrackerImage.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 220),
            
            plugLabel.topAnchor.constraint(equalTo: plugTrackerImage.bottomAnchor, constant: 8),
            plugLabel.centerXAnchor.constraint(equalTo: plugTrackerImage.centerXAnchor)
            
        ])
    }
    
    func showInitialOption() {
        initialLabel.isHidden = false
        initialTrackerImage.isHidden = false
        plugLabel.isHidden = true
        plugTrackerImage.isHidden = true
    }
    
    @objc
    internal func didTapPluseButton() {
        
    }
    
    //    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
    //        let calendar = Calendar.current
    //                let filterWeekday = calendar.component(.weekday, from: datePicker.date)
    //                self.selectedDate = filterWeekday
    //
    //    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
}

// MARK: - UICollectionViewDataSource
extension TrackerScreenViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifire, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerScreenViewController: UICollectionViewDelegateFlowLayout {
    
}
