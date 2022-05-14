//
//  Util.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/29.
//

import Foundation

class Util { //supporting class with help functions
    public func monthConvert(month: String) -> Int {
        switch month {
        case "Jan":
            return 1
        case "Feb":
            return 2
        case "Mar":
            return 3
        case "Apr":
            return 4
        case "May":
            return 5
        case "Jun":
            return 6
        case "Jul":
            return 7
        case "Aug":
            return 8
        case "Sep":
            return 9
        case "Oct":
            return 10
        case "Nov":
            return 11
        case "Dec":
            return 12
        default:
            return 0
        }
    }
    
    public func typeIndex(type: String) -> Int {
        switch type {
        case "Vegetables":
            return 0
        case "Meat":
            return 1
        case "Fruits":
            return 2
        case "Dairy&Egg":
            return 3
        case "Bakery":
            return 4
        case "Snacks":
            return 5
        case "Beverage":
            return 6
        case "Others":
            return 7
        default:
            return 7
        }
    }
}
