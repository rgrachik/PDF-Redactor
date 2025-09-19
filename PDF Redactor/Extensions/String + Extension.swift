//
//  String + Extension.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import Foundation

extension String {
    
    static func getWord(by key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
