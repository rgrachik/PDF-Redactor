//
//  UserDefaultsManager.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import Foundation

enum UserDefaultsKeys: String {
    case isOnboarded = "isOnboarded"
}

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    func set(_ value: Bool, forKey key: UserDefaultsKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    func getBool(forKey key: UserDefaultsKeys) -> Bool {
        UserDefaults.standard.bool(forKey: key.rawValue)
    }
}
