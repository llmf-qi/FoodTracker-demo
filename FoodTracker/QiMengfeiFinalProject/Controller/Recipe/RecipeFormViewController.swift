//
//  RecipeFormViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/5/1.
//
//  multiselection reference: https://www.youtube.com/watch?v=XRaugEmM7Tc&t=178s

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class RecipeFormViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    private var foodListModel = AllFoodListModel.sharedInstance
    private var allFoodList: [FoodTypeList]?
    @IBOutlet weak var foodTableView: UITableView!
    var nameList = [String]()
    let sort = ["random", "time", "missing ingredients", "calories"] //picker view for sorting
    var sortPickerView = UIPickerView()
    @IBOutlet weak var sortTextField: UITextField!
    
    
    override func viewDidLoad() {
        foodListModel = AllFoodListModel.sharedInstance
        loadFood() //to load all food list
        super.viewDidLoad()
        sortTextField.text = "ramdom"
        sortPickerView.delegate = self
        sortPickerView.dataSource = self
        sortTextField.inputView = sortPickerView
        sortTextField.inputAccessoryView = createToolbar() //alows user to dismiss the pickerview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        foodListModel = AllFoodListModel.sharedInstance
        loadFood()
    }
    
    func createToolbar() -> UIToolbar { //tool bar for sort picker, has a done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        return toolbar
    }
    
    @objc func donePressed() {
        self.view.endEditing(true) //dismiss the picker
    }
    
    func loadFood() { //load all food from firebase
        foodListModel.loadAllFood{allFoodList in
            DispatchQueue.main.async {
                self.allFoodList = allFoodList //store the food into the food lists
                self.foodTableView.reloadData()
            }
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allFoodList?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFoodList?[section].getFoodList().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = foodTableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath)
        
        let foodList = allFoodList?[indexPath.section].getFoodList()
        let theFood = foodList?[indexPath.row]

        // Configure the cell...
        cell.textLabel?.text = theFood?.getName()
        cell.detailTextLabel?.text = theFood?.getExpDate()
        cell.selectionStyle = .none
        cell.setSelected(false, animated: true)
        cell.accessoryType = .none //clear the accessoryType each time when the view is loaded
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allFoodList?[section].getType()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //when one row is selected, place a check mark
        foodTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { //deselect will celar the check mark
        foodTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    @IBAction func searchDidTapped(_ sender: Any) {
        nameList.removeAll() //remove the selected list stored before
        
        if let selectedFood = foodTableView.indexPathsForSelectedRows {
            for iPath in selectedFood {
                if let tempName = foodListModel.food(at: iPath.row, typeIndex: iPath.section)?.getName() {
                    nameList.append(tempName) //store the name of all selected food
                }
            }
        }
        
        let sortBy = sortTextField.text ?? "random"
        RecipeModel.shared.setSortBy(sortBy: sortBy) //set the recipe model
        RecipeModel.shared.setIngredient(ingredients: nameList)
        self.performSegue(withIdentifier: "recipeSegue", sender: nil) //lead to the recipe model
    }
}

extension RecipeFormViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sort.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sort[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sortTextField.text = sort[row]
        
    }
}
