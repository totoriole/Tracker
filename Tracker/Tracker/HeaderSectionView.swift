//
//  HeaderSectionView.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

final class HeaderSectionView: UICollectionReusableView {
    static let id = "header"
    var headerText: String? {
        didSet {
            titleLabel.text = headerText
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackday
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

