//
//  ViewController.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit

final class TrackerScreenViewController: UIViewController {
    
    private var trackerStore = TrackerStore()
    private var trackerRecordStore = TrackerRecordStore()
    private(set) var categoryViewModel: CategoryViewModel = CategoryViewModel.shared
    
    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var selectedDate: Int?
    private var filterText: String?
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let header: UILabel = {
        let header = UILabel()
        header.text = "Трекеры"
        header.textColor = .blackday
        header.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return header
    }()
    
    private let searchTrackers: UISearchTextField = {
        let searchTrackers = UISearchTextField()
        searchTrackers.placeholder = "Поиск"
        return searchTrackers
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.calendar.firstWeekday = 2
        datePicker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
        return datePicker
    }()
    
    private let emptyTrackersLogo: UIImageView = {
        let emptyTrackersLogo = UIImageView()
        emptyTrackersLogo.image = UIImage(named: "Empty trackers")
        return emptyTrackersLogo
    }()
    
    private let emptyTrackersText: UILabel = {
        let emptyTrackersText = UILabel()
        emptyTrackersText.text = "Что будем отслеживать?"
        emptyTrackersText.textColor = .blackday
        emptyTrackersText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return emptyTrackersText
    }()
    
    private let emptySearch: UIImageView = {
        let emptySearch = UIImageView()
        emptySearch.image = UIImage(named: "empty search")
        return emptySearch
    }()
    
    private let emptySearchText: UILabel = {
        let emptySearchText = UILabel()
        emptySearchText.text = "Ничего не найдено"
        emptySearchText.textColor = .blackday
        emptySearchText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return emptySearchText
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let addTrackerButton = UIButton()
        addTrackerButton.setImage(UIImage(named: "Add tracker"), for: .normal)
        addTrackerButton.addTarget(self, action: #selector(didTapAddTracker), for: .touchUpInside)
        return addTrackerButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectCurrentDay()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        trackers = trackerStore.trackers
        completedTrackers = trackerRecordStore.trackerRecords
        categories = categoryViewModel.categories
        
        filterVisibleCategories()
        showFirstStubScreen()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(HeaderSectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderSectionView.id)
        collectionView.allowsMultipleSelection = false
        searchTrackers.delegate = self
        
        [header, searchTrackers, datePicker, emptyTrackersLogo, emptyTrackersText, emptySearch, emptySearchText, addTrackerButton, collectionView].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTrackers.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 7),
            searchTrackers.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTrackers.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            emptyTrackersLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyTrackersLogo.topAnchor.constraint(equalTo: searchTrackers.bottomAnchor, constant: 220),
            emptyTrackersLogo.heightAnchor.constraint(equalToConstant: 80),
            emptyTrackersLogo.widthAnchor.constraint(equalToConstant: 80),
            emptyTrackersText.centerXAnchor.constraint(equalTo: emptyTrackersLogo.centerXAnchor),
            emptyTrackersText.topAnchor.constraint(equalTo: emptyTrackersLogo.bottomAnchor, constant: 8),
            emptySearch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptySearch.topAnchor.constraint(equalTo: searchTrackers.bottomAnchor, constant: 220),
            emptySearch.heightAnchor.constraint(equalToConstant: 80),
            emptySearch.widthAnchor.constraint(equalToConstant: 80),
            emptySearchText.centerXAnchor.constraint(equalTo: emptySearch.centerXAnchor),
            emptySearchText.topAnchor.constraint(equalTo: emptySearch.bottomAnchor, constant: 8),
            collectionView.topAnchor.constraint(equalTo: searchTrackers.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func didTapAddTracker() {
        let addTracker = AddTrackerViewController()
        addTracker.trackerScreenViewController = self
        present(addTracker, animated: true, completion: nil)
    }
    
    @objc private func pickerChanged() {
        selectCurrentDay()
        filterTrackers()
    }
    
    private func selectCurrentDay() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        self.selectedDate = filterWeekday
    }
    
    private func filterTrackers() {
        filterVisibleCategories()
        showSecondStubScreen()
        collectionView.reloadData()
    }
    
    private func filterVisibleCategories() {
        visibleCategories = categories.map { category in
            TrackerCategory(header: category.header, trackers: category.trackers.filter { tracker in
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
        .filter { category in
            !category.trackers.isEmpty
        }
    }
}

// MARK: - TrackerStoreDelegate
extension TrackerScreenViewController: TrackerStoreDelegate {
    func store() {
        trackers = trackerStore.trackers
        collectionView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension TrackerScreenViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.filterText = textField.text
        filterTrackers()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - TrackersActions
extension TrackerScreenViewController: TrackersActions {
    func appendTracker(tracker: Tracker, category: String?) {
        guard let category = category else { return }
        try! self.trackerStore.addNewTracker(tracker)
        let foundCategory = self.categories.first { ctgry in
            ctgry.header == category
        }
        if foundCategory != nil {
            self.categories = self.categories.map { ctgry in
                if (ctgry.header == category) {
                    var updatedTrackers = ctgry.trackers
                    updatedTrackers.append(tracker)
                    return TrackerCategory(header: ctgry.header, trackers: updatedTrackers)
                } else {
                    return TrackerCategory(header: ctgry.header, trackers: ctgry.trackers)
                }
            }
        } else {
            self.categories.append(TrackerCategory(header: category, trackers: [tracker]))
        }
        filterTrackers()
    }
    
    func reload() {
        self.collectionView.reloadData()
    }
    
    func showFirstStubScreen() {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            emptySearch.isHidden = true
            emptySearchText.isHidden = true
        } else {
            collectionView.isHidden = false
            emptySearch.isHidden = false
            emptySearchText.isHidden = false
        }
    }
    
    func showSecondStubScreen() {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            emptyTrackersLogo.isHidden = true
            emptyTrackersText.isHidden = true
            emptySearch.isHidden = false
            emptySearchText.isHidden = false
        } else {
            collectionView.isHidden = false
            emptyTrackersLogo.isHidden = false
            emptyTrackersText.isHidden = false
            emptySearch.isHidden = true
            emptySearchText.isHidden = true
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView:UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderSectionView.id, for: indexPath) as? HeaderSectionView else {
            return UICollectionReusableView()
        }
        guard indexPath.section < visibleCategories.count else {
            return header
        }
        let headerText = visibleCategories[indexPath.section].header
        header.headerText = headerText
        return header
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.id == id && isSameDay
    }
}

// MARK: - TrackerCellDelegate
extension TrackerScreenViewController: TrackerRecordStoreDelegate {
    func storeRecord() {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}

extension TrackerScreenViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let currentDate = Date()
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        if calendar.compare(selectedDate, to: currentDate, toGranularity: .day) != .orderedDescending {
            let trackerRecord = TrackerRecord(id: id, date: selectedDate)
            try! self.trackerRecordStore.addNewTrackerRecord(trackerRecord)
        } else {
            return
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let toRemove = completedTrackers.first {
            isSameTrackerRecord(trackerRecord: $0, id: id)
        }
        try! self.trackerRecordStore.removeTrackerRecord(toRemove)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 5, height: (collectionView.bounds.width / 2 - 5) * 0.88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 47)
    }
}
