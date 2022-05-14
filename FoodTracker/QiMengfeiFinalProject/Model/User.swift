//
//  User.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/27.
//

import Foundation

struct UserInfo: Codable {
    private var name: String
    private var email: String
    
    func getName() -> String {
        return name
    }
    
    func getEmail() -> String {
        return email
    }
    
    init(name: String, email: String) {
        self.name = name;
        self.email = email
    }
    
}
