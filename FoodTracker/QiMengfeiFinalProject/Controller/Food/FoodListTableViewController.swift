//
//  FoodListTableViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/27.
//
//  multisection reference: https://www.youtube.com/watch?v=AHY09z-XS9s

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import UserNotifications

class FoodListTableViewController: UITableViewController {
    private var foodListModel = AllFoodListModel.sharedInstance
    private var allFoodList: [FoodTypeList]?
    var result: Food?
    var selected: IndexPath?
    
    let center = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        foodListModel = AllFoodListModel.sharedInstance
        loadFood() //to load all food list
        super.viewDidLoad()
        self.tableView.rowHeight = 70 //set the height of each row

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //ask permission to notification
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if (!granted) {
                return
            }
        }
        
        //schedule a notification every day to remind the user
        center.getNotificationSettings{ (settings) in
            
            if(settings.authorizationStatus == .authorized) {
               let content = UNMutableNotificationContent()
                content.title = "Your food is waiting for you"
                content.body = "Check what to eat today!"
                
                var dateComp = DateComponents()
                dateComp.hour = 12 //push notification every 12:00 pm
                dateComp.minute = 00
                let trigger = UNCalendarNotificationTrigger(
                         dateMatching: dateComp, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                self.center.add(request) { (error) in
                    if (error !=  nil) {
                        print (error ?? "no")
                        return
                    }
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        foodListModel = AllFoodListModel.sharedInstance
        loadFood()
    }
    
    func loadFood() {
        self.foodListModel.loadAllFood { allFoodList in
            DispatchQueue.main.async {
                self.allFoodList = allFoodList
                self.tableView.reloadData()
            }
            
        } //load all food
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return allFoodList?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFoodList?[section].getFoodList().count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //custom reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! FoodTableViewCell
        
        let foodList = allFoodList?[indexPath.section].getFoodList()
        let theFood = foodList?[indexPath.row]

        // Configure the cell...
        cell.nameLabel?.text = theFood?.getName()
        cell.dateLabel?.text = theFood?.getExpDate()
        cell.amountLabel?.text = "\(theFood?.getAmount() ?? 0)"
        cell.unitLabel?.text = theFood?.getUnit()

        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            foodListModel.remove(at: indexPath.row, typeIndex: indexPath.section) //remove the food from the model
            allFoodList = foodListModel.getAllFoodList()
            
            tableView.reloadData() //reload the food list
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allFoodList?[section].getType() //use food type as header for each section
    }
    
    //select a row and modify its information
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        result = foodListModel.food(at: indexPath.row, typeIndex: indexPath.section)
        selected = indexPath
        self.performSegue(withIdentifier: "modifySegue", sender: self)
    }
    
    //set the data in the modifying view first
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modifySegue" {
            let destination = segue.destination as! FoodDetailViewController
            destination.tempDate = result?.getExpDate() ?? ""
            destination.tempName = result?.getName() ?? ""
            destination.tempType = result?.getType() ?? ""
            destination.tempAmount = "\( result?.getAmount() ?? 0)"
            destination.tempUnit = result?.getUnit() ?? ""
            destination.downloadString = result?.getPhotoURL() ?? ""
            destination.selected = selected
        }
    }
}
