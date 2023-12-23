//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Bumbie on 23.12.2023.
//

import UIKit

// Дополнительный код для преобразования, чтобы enum Weekday правильно работал с Core Data
@objc
final class DaysValueTransformer: ValueTransformer {
    //Переопределим свойства, которые описывают тип данных для хранения в Transformable и укажем системе, что нам нужна конвертация в две стороны: для записи и для чтения
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    // кодируем [Weekday]
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Weekday] else { return nil }
        return try? JSONEncoder().encode(days)
    }
    // раскодируем [Weekday]
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([Weekday].self, from: data as Data)
    }
    
    static func register() {
        // Регистрируем кастомный трансформер и сообщим о нём системе
        ValueTransformer.setValueTransformer(DaysValueTransformer(), forName: NSValueTransformerName(String(describing: DaysValueTransformer.self)))
    }
}
