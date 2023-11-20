//
//  TrackerCell.swift
//  Tracker
//
//  Created by Toto Tsipun on 07.11.2023.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    // Идентификатор ячейки — используется для регистрации и восстановления:
    static let identifire = "cell"
    // Конструктор:
    override init(frame: CGRect) {
        super .init(frame: frame)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
