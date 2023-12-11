//
//  HeaderSectionView.swift
//  Tracker
//
//  Created by Bumbie on 21.11.2023.
//

import UIKit

final class HeaderSectionView: UICollectionReusableView {
    // Статический идентификатор, используемый для регистрации и восстановления представления
    static let id = "header"
    // Переменная для установки текста заголовка, с использованием наблюдателя didSet
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
    // Конструктор
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        ])
    }
    // Обязательный метод инициализации для случаев, когда представление создается из интерфейса Builder (Storyboard, XIB и др.)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

