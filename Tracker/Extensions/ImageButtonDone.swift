//
//  ImageButtonDone.swift
//  Tracker
//
//  Created by Bumbie on 22.11.2023.
//

import UIKit

final class ImageDone: UIImage {
//    КАК СОЗДАТЬ КНОПКУ DONE??
    let imageCreate: UIImage = {
        var image = UIImage(named: "imageDone")
        // Создайте изображение для основы кнопки
        let baseImage = UIImage(named: "Done")
        
        // Создайте изображение, которое вы хотите наложить
        let overlayImage = UIImage(named: "Done1")
        
        // Рассчитайте размеры изображений и их позицию на кнопке
        let imageSize = CGSize(width: 34, height: 34)
        let imageOrigin = CGPoint(x: 10, y: 10)  // Указываете нужные координаты
        
        // Создайте контекст для рисования
        UIGraphicsBeginImageContextWithOptions(baseImage!.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        // Нарисуйте основное изображение
        baseImage?.draw(in: CGRect(x: 0, y: 0, width: baseImage!.size.width, height: baseImage!.size.height))
        
        // Нарисуйте изображение, которое вы хотите наложить
        overlayImage?.draw(in: CGRect(origin: imageOrigin, size: imageSize))
        
        // Получите итоговое изображение из контекста
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()!
        // Завершите рисование
        UIGraphicsEndImageContext()
        
        image = combinedImage
        
        return image ?? overlayImage!
    }()
}
