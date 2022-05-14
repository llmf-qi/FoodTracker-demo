//
//  AllFoodListModel.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/29.
//

import Foundation
import Firebase

class AllFoodListModel: NSObject, AllFoodListProtocol {
    
    static let sharedInstance = AllFoodListModel()
    private var userID = ""
    let util = Util()
    let types = ["Vegetables", "Meat", "Fruits", "Dairy&Egg", "Bakery", "Snacks", "Beverage", "Others"]
    
    
    var allFoodList = [FoodTypeList]()
    
    //private var tempList: FoodTypeList? = nil
    
    override init() {
        let tempFood = Food(name: "", type: "", amount: 0, unit: "", expDate: "", photoURL: "")
        let fakeList = [tempFood]
        let temp = FoodTypeList(type: "temp", foodlist: fakeList)
        allFoodList = Array(repeating: temp, count: 8) //initialize foodlist with 8 types
        
    }
    
    func loadAllFood(completion: @escaping ([FoodTypeList]) -> Void) { //read and store data to each list item
        let user = Auth.auth().currentUser!
        userID = user.uid
        
        var docRef = Firestore.firestore().collection(userID).document("Vegetables")
        docRef.getDocument(as: FoodTypeList.self) { result in
            switch result {
            case .success(let tempList):
                self.allFoodList[0] = tempList
                completion(self.allFoodList)
            case .failure(_):
                print ("Error decoding vege")
            }
        }
        docRef = Firestore.firestore().collection(userID).document("Meat")
        docRef.getDocument(as: FoodTypeList.self) { result in
            switch result {
            case .success(let tempList):
                self.allFoodList[1] = tempList
                completion(self.allFoodList)
            case .failure(_):
                print ("Error decoding meat")
            }
        }
        docRef = Firestore.firestore().collection(userID).document("Fruits")
        docRef.getDocument(as: FoodTypeList.self) { result in
            switch result {
            case .success(let tempList):
                self.allFoodList[2] = tempList
                completion(self.allFoodList)
            case .failure(_):
                print ("Error decoding fruit")
            }
        }
        docRef = Firestore.firestore().collection(userID).document("Dairy&Egg")
        docRef.getDocument(as: FoodTypeList.self) { result in
            switch result {
            case .success(let tempList):
                self.allFoodList[3] = tempList
                completion(self.allFoodList)
            case .failure(_):
                print ("Error decoding de")
            }
        }
        docRef = Firestore.firestore().collection(userID).document("Bakery")
        docRef.getDocument(as: FoodTypeList.self) { result in
            switch result {
            case .success(let tempList):
                self.allFoodList[4] = tempList
                completion(self.allFoodList)
            case .failure(_):
                print ("Error decoding bakery")
            }
        }
        docRef = Firestore.firestore().collection(userID).document("Snacks")
        docRef.getDocument(as: FoodTypeList.self) { result in
            switch result {
            case .success(let tempList):
                self.allFoodList[5] = tempList
                completion(self.allFoodList)
            case .failure(_):
                print ("Error decoding snack")
            }
        }
        docRef = Firestore.firestore().collection(userID).document("Beverage")
        docRef.getDocument(as: FoodTypeList.self) { result in
            switch result {
            case .success(let tempList):
                self.allFoodList[6] = tempList
                completion(self.allFoodList)
            case .failure(_):
                print ("Error decoding beverage")
            }
        }
        docRef = Firestore.firestore().collection(userID).document("Others")
        docRef.getDocument(as: FoodTypeList.self) { result in
            switch result {
            case .success(let tempList):
                self.allFoodList[7] = tempList
                completion(self.allFoodList)
            case .failure(_):
                print ("Error decoding others")
            }
        }
        
    }
    
    func getAllFoodList() -> [FoodTypeList] {
        return allFoodList
    }
    
    //select food at specific loc
    func food(at index: Int, typeIndex: Int) -> Food? {
        //let typeIndex = util.typeIndex(type: type)
        let foodList = allFoodList[typeIndex].getFoodList()
        if (index >= 0 && index < foodList.count) {
            return foodList[index]
        }
        return nil
    }
    
    //food insert at specific loc, update the model
    func insert(insertFood: Food) {
        let type = insertFood.getType()
        let typeIndex = util.typeIndex(type: type)
        var foodList = allFoodList[typeIndex].getFoodList()
        foodList.append(insertFood)
        foodList.sort()
        allFoodList[typeIndex] = FoodTypeList(type: type, foodlist: foodList) //update the model
        save(foodList: allFoodList[typeIndex]) //update the firestore
    }
    
    
    //food remove at specific loc, update the model
    func remove(at index: Int, typeIndex: Int) {
        var foodList = allFoodList[typeIndex].getFoodList()
        if (!foodList.isEmpty) {
            if (index >= 0 && index <= foodList.count - 1) {
                foodList.remove(at: index)
            }
        }
        allFoodList[typeIndex] = FoodTypeList(type: types[typeIndex], foodlist: foodList) //update the model
        save(foodList: allFoodList[typeIndex]) //update the firestore
    }
    
    //function to save every update
    func save(foodList: FoodTypeList){
        let type = foodList.getType()
        do {
            try Firestore.firestore().collection(userID).document(type).setData(from: foodList, merge: true)
        } catch {
            print("update Error")
        }
        
        return
    }
    
    //check in one specific type list, if a food with the same name exist. same name will cause the photo being covered
    func checkIfSameExist(foodName: String, foodType: String) -> Bool {
        let typeIndex = util.typeIndex(type: foodType)
        let tempfoodList = allFoodList[typeIndex].getFoodList()
        if (tempfoodList.isEmpty) {
            return false
        } else {
            for i in 0...tempfoodList.count - 1 {
                if (foodName.lowercased() == tempfoodList[i].getName().lowercased()) {
                    return true
                }
            }
        }
        
        return false;
    }
}

