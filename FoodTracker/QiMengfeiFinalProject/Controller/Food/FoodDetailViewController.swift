//
//  FoodDetailViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/27.
//
//  connect input field with picker view reference: https://www.youtube.com/watch?v=FKuNwHZzJlA
//  picker view with tool bar reference: https://www.youtube.com/watch?v=chROnJIF7dY
//  upload photo to firestorage and download it reference: https://www.youtube.com/watch?v=TAF6cPZxmmI

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseStorageSwift

class FoodDetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var userID = ""
    var imageURL = ""
    var downloadString = ""
    var tempName = ""
    var tempDate = ""
    var tempType = ""
    var tempAmount = ""
    var tempUnit = ""
    var selected: IndexPath?

    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var foodTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var foodImage: UIImageView!
    
    @IBOutlet weak var uploadIndicator: UIActivityIndicatorView!
    
    
    //for type picker
    let types = ["Vegetables", "Meat", "Fruits", "Dairy&Egg", "Bakery", "Snacks", "Beverage", "Others"]
    
    var typePickerView = UIPickerView()
    var datePickerView = UIDatePicker()
    
    private let storage = Storage.storage().reference() //firebase storage for photo
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser! //get the current user in order to access the photo storage
        userID = user.uid
        saveButton.isEnabled = false
        uploadIndicator.isHidden = true
        
        typePickerView.delegate = self
        typePickerView.dataSource = self
        typeTextField.inputView = typePickerView //type textfield is input with select view
        typeTextField.text = "Vegetables"
        
        //set date picker
        datePickerView.preferredDatePickerStyle = .wheels
        datePickerView.datePickerMode = .date //does not need time
        datePickerView.minimumDate = Date() //since it's expiration date, the date cannot be earlier than current date
        dateTextField.inputView = datePickerView
        dateTextField.inputAccessoryView = createToolbar()
        
        if (!downloadString.isEmpty) { //if the user select an exsiting row with photo download url
            imageURL = downloadString
            guard let url = URL(string: downloadString) else { //change it from string to url
                return
            }

            //get the photo data from the url
            let task = URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                
                //sync in the main thread
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.foodImage.image = image
                }

            })
            task.resume()
        }
        
        //if the user select an exsiting row, filled the textfield with selected food info
        if (!tempUnit.isEmpty && !tempDate.isEmpty && !tempName.isEmpty && !tempType.isEmpty && !tempAmount.isEmpty) {
            unitTextField.text = tempUnit
            dateTextField.text = tempDate
            foodTextField.text = tempName
            typeTextField.text = tempType
            amountTextField.text = tempAmount
            saveIsEnabled()
        }
        
    }
    
    func createToolbar() -> UIToolbar { //tool bar for date picker, has a done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        return toolbar
    }
    
    //if one of the field is empty, the save button is not enabled
    func saveIsEnabled() {
        let food = foodTextField.text!
        let type = typeTextField.text!
        let amount = amountTextField.text!
        let unit = unitTextField.text!
        let date = dateTextField.text!
        
        if (food.isEmpty || type.isEmpty || amount.isEmpty || unit.isEmpty || date.isEmpty || imageURL.isEmpty) {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    //when done button on the tool bar is pressed, fill the textfield with the selected date
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current //current timezone
        dateFormatter.dateStyle = .medium //eg: Apr 30, 2022
        dateFormatter.timeStyle = .none //no time
        
        self.dateTextField.text = dateFormatter.string(from: datePickerView.date)
        saveIsEnabled() //check if save button is enabled
        self.view.endEditing(true) //dismiss the picker
    }
    
    //the following five functions: check if the save button is enabled, dismiss the keyboard
    @IBAction func bgDidTapped(_ sender: Any) {
        saveIsEnabled()
        typeTextField.resignFirstResponder()
        foodTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        unitTextField.resignFirstResponder()
        dateTextField.resignFirstResponder()
    }
    
    @IBAction func foodExit(_ sender: UITextField) {
        saveIsEnabled()
        sender.resignFirstResponder()
    }
    
    @IBAction func amountExit(_ sender: UITextField) {
        saveIsEnabled()
        sender.resignFirstResponder()
    }
    
    @IBAction func unitExit(_ sender: UITextField) {
        saveIsEnabled()
        sender.resignFirstResponder()
    }
    
    //handle the situation that the user did not enter a food name before selecting a photo, becuase the photo is sotored using the name of the food
    func imageHandleAction(action: UIAlertAction) {
        foodTextField.becomeFirstResponder()
    }
    
    @IBAction func selectDidTapped(_ sender: Any) {
        if (foodTextField.text!.isEmpty) { //if the user did not enter a food name before selecting a photo
            let alertController = UIAlertController(title: "Missing Food Name!", message: "Please enter food name first.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: imageHandleAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        saveButton.isEnabled = false
        let picker = UIImagePickerController() //open the image picker controller
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        guard let imageData = image.pngData() else {
            return
        }
        uploadIndicator.isHidden = false
        foodImage.image = image
        
        //store the photo in the storage reference with userID and type folder, name the photo with the food name
        let ref = storage.child("\(userID)/\(typeTextField.text!)/\(foodTextField.text!).png")
        
        //upload the photo data to the storage
        ref.putData(imageData, metadata: nil, completion: {_, error in
            guard error == nil else {
                print ("failed to upload")
                return
            }
            
            //get the download url
            ref.downloadURL { url, error in
                guard let url = url, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    let urlString = url.absoluteString
                    self.imageURL = urlString
                    self.saveIsEnabled()
                    self.uploadIndicator.isHidden = true
                }
            }
            
        })
        
        //saveIsEnabled()
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        saveIsEnabled()
    }
    
    //handle the situation that one type has two same food names
    func nameHandleAction(action: UIAlertAction) {
        foodTextField.text = ""
        foodTextField.becomeFirstResponder()
    }
    
    @IBAction func saveDidTapped(_ sender: Any) {
        let food = foodTextField.text!
        let type = typeTextField.text!
        let amount = amountTextField.text!
        let unit = unitTextField.text!
        let date = dateTextField.text!
        
        //if the food exist previously, remove it
        if ((selected?.row != nil) && (selected?.section != nil)) {
            AllFoodListModel.sharedInstance.remove(at: selected!.row, typeIndex: selected!.section)
        }
        
        //if same food name exist, alert
        if (AllFoodListModel.sharedInstance.checkIfSameExist(foodName: food, foodType: type)) {
            let alertController = UIAlertController(title: "Contain same food in this category!", message: "Please modify the original food or change the food name. eg: apple -> apple ver2", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nameHandleAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        //create a food variable
        let tempFood = Food(name: food, type: type, amount: Int(amount) ?? 0, unit: unit, expDate: date, photoURL: imageURL)
        
        //store the created food
        AllFoodListModel.sharedInstance.insert(insertFood: tempFood)

        
        //jump to the previous list
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
}

//food type picker initializer
extension FoodDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = types[row]
        
    }
    
    
}


