//
//  SignupViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/27.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class SignupViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.isEnabled = false
        passwordTextField.textContentType = .oneTimeCode
        confirmTextField.textContentType = .oneTimeCode
        // Do any additional setup after loading the view.
    }
    
    //if any of the field is empty, the signup button is not enabled
    func enableSignupButton() {
        let name = nameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirmPW = confirmTextField.text!
        
        if (!email.isEmpty && !password.isEmpty && !name.isEmpty && !confirmPW.isEmpty) {
            signupButton.isEnabled = true
        } else {
            signupButton.isEnabled = false
        }
    }
    
    //the following five function: dismiss the keyboard and check if the signup button is enabled
    @IBAction func nameTFExit(_ sender: UITextField) {
        enableSignupButton()
        sender.resignFirstResponder()
    }
    
    @IBAction func emailTFExit(_ sender: UITextField) {
        enableSignupButton()
        sender.resignFirstResponder()
    }
    
    @IBAction func passwordTFExit(_ sender: UITextField) {
        enableSignupButton()
        sender.resignFirstResponder()
    }
    
    @IBAction func confirmTFExit(_ sender: UITextField) {
        enableSignupButton()
        sender.resignFirstResponder()
    }
    
    @IBAction func bgDidTapped(_ sender: Any) {
        enableSignupButton()
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmTextField.resignFirstResponder()
    }
    
    
    //when there are problems about the password, clean the password and confirm password field
    func pwHandleAction (action: UIAlertAction) {
        passwordTextField.text = nil
        confirmTextField.text = nil
        signupButton.isEnabled = false
    }
    
    //check if the password input is valid
    func isValidInput () -> Bool {
        let password = passwordTextField.text!
        let confirmPW = confirmTextField.text!
        if (password != confirmPW) { //if the confirm password is different from the password
            let alertController = UIAlertController(title: "Wrong confirm password!", message: "Confirm password does not match with the password. Please enter again!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: pwHandleAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        if (password.count < 6) { //if the password is less than 6 characters
            let alertController = UIAlertController(title: "Invalid password!", message: "The password must be 6 characters long or more.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: pwHandleAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func errorHandleAction (action: UIAlertAction) {
        nameTextField.text = nil
        emailTextField.text = nil
        passwordTextField.text = nil
        confirmTextField.text = nil
        signupButton.isEnabled = false
    }
    
    @IBAction func signupDidTapped(_ sender: Any) { //when the user tries to sign up
        let email = emailTextField.text!
        let name = nameTextField.text!
        let password = passwordTextField.text!
        if (isValidInput()) { //if the input is valid
            Auth.auth().createUser(withEmail: email, password: password) {[weak self]authResult, error in
                if let error = error {
                print(error)
                    let alertController = UIAlertController(title: "Sign up failed!", message: "This email might be registered before or is an invalid email. Please try another email.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: self?.errorHandleAction)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                return
                }
                
                if let userId = authResult?.user.uid { //if the user successfully create an account
                    let tempUser = UserInfo(name: name, email: email) //create a user variable
                    let tempList = [Food]() //create an empty food list
                    do {
                        //store the user variable in the firestore "users" collection
                        try Firestore.firestore().collection("users").document(userId).setData(from: tempUser)
                        //create a specific collection using userID to store the user's food list, each document is a type
                        try Firestore.firestore().collection(userId).document("Vegetables").setData(from: FoodTypeList(type: "Vegetables", foodlist: tempList))
                        try Firestore.firestore().collection(userId).document("Meat").setData(from: FoodTypeList(type: "Meat", foodlist: tempList))
                        try Firestore.firestore().collection(userId).document("Fruits").setData(from: FoodTypeList(type: "Fruits", foodlist: tempList))
                        try Firestore.firestore().collection(userId).document("Dairy&Egg").setData(from: FoodTypeList(type: "Dairy&Egg", foodlist: tempList))
                        try Firestore.firestore().collection(userId).document("Bakery").setData(from: FoodTypeList(type: "Bakery", foodlist: tempList))
                        try Firestore.firestore().collection(userId).document("Snacks").setData(from: FoodTypeList(type: "Snacks", foodlist: tempList))
                        try Firestore.firestore().collection(userId).document("Beverage").setData(from: FoodTypeList(type: "Beverage", foodlist: tempList))
                        try Firestore.firestore().collection(userId).document("Others").setData(from: FoodTypeList(type: "Others", foodlist: tempList))

                    } catch {
                        print("Error")
                    }
                }
                
                self?.performSegue(withIdentifier: "SignUpSegue", sender: nil) //after signing up succuessfully, jump to the food list
            }
        } else {
            return
        }
       
    }
    

}
