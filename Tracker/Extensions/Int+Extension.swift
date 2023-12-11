//
//  IntExtension.swift
//  Tracker
//
//  Created by Bumbie on 22.11.2023.
//

import UIKit

extension Int {
    func days() -> String {
        var ending = ""
        if "1".contains("\(self % 10)") {
            ending = "день"
        }
        
        if "234".contains("\(self % 10)") {
            ending = "дня"
        }
        
        if "567890".contains("\(self % 10)") {
            ending = "дней"
        }
        
        if 11...14 ~= self % 100 {
            ending = "дней"
        }
        return "\(self) " + ending
    }
}
