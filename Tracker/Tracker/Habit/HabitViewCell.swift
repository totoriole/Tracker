//
//  CreateTrackerViewCell.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

final class HabitViewCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let chevronImage = UIImageView()
        chevronImage.image = UIImage(named: "Chevron")
        chevronImage.tintColor = .greyYP
        chevronImage.translatesAutoresizingMaskIntoConstraints = false
        return chevronImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .backgroundday
        clipsToBounds = true
        addSubview(titleLabel)
        addSubview(chevronImage)
        configureConstraints()
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 24),
            chevronImage.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Обновляем содержимое ячейки таблицы новыми данными. Принимаем строку title и устанавливаем ее в качестве текста метки titleLabel. Таким образом, при вызове этого метода с новым заголовком, ячейка обновит свое содержимое.
    func update(with title: String) {
        titleLabel.text = title
    }
}
