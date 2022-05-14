//
//  Food.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/27.
//

import Foundation

struct Food: Comparable, Codable {
    private var name: String
    private var type: String
    private var amount: Int
    private var unit: String
    private var expDate: String
    private var photoURL: String
    
    func getName() -> String{
        return name
    }
    
    func getType() -> String{
        return type
    }
    
    func getAmount() -> Int {
        return amount
    }
    
    func getUnit() -> String{
        return unit
    }
    
    func getExpDate() -> String{
        return expDate
    }
    
    func getPhotoURL() -> String {
        return photoURL
    }
    
    init(name: String, type: String, amount: Int, unit: String, expDate: String, photoURL: String) {
        self.name = name
        self.type = type
        self.amount = amount
        self.unit = unit
        self.expDate = expDate
        self.photoURL = photoURL
    }
    
    //compare food according to their expiration date, eg: Apr 11, 2022
    static func < (lhs: Food, rhs: Food) -> Bool {
        let strLeft = lhs.getExpDate()
        let strRight = rhs.getExpDate()
        let leftCompo = strLeft.components(separatedBy: ", ")
        let rightCompo = strRight.components(separatedBy: ", ")
        if (leftCompo[1] < rightCompo[1]) { //first compare the year
            return true
        } else if (leftCompo[1] > rightCompo[1]) {
            return false
        } else {
            let leftDay = leftCompo[0].components(separatedBy: " ")
            let rightDay = rightCompo[0].components(separatedBy: " ")
            let util = Util()
            if (util.monthConvert(month: leftDay[0]) < util.monthConvert(month: rightDay[0])) { //then compare month
                return true
            } else if (util.monthConvert(month: leftDay[0]) > util.monthConvert(month: rightDay[0])){
                return false
            } else {
                if (leftDay[1] >= rightDay[1]) { //finally compare day
                    return false
                } else if (leftDay[1] < rightDay[1]) {
                    return true
                }
            }
        }
                    
        return false
    }
    
    
    
    
}
