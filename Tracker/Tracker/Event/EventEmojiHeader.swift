//
//  EventEmojiHeader.swift
//  Tracker
//
//  Created by Bumbie on 20.12.2023.
//

import UIKit

final class EventEmojiHeader: UICollectionReusableView {
    static let id = "EventEmojiHeader"
    
    var headerText: String? {
        didSet {
            headerLabel.text = headerText
        }
    }
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .blackday
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
