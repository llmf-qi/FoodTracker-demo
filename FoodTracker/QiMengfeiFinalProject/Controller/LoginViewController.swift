//
//  LoginViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/26.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signinButton.isEnabled = false
    }
    
    //only when email and password field is filled, the login button is enabled
    func enableSigninButton() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        if (!email.isEmpty && !password.isEmpty) {
            signinButton.isEnabled = true
        } else {
            signinButton.isEnabled = false
        }
    }
    
    //tap return in the keyboard, dissmiss the keyboard, check if the signin button can be enabled
    @IBAction func emailTextFieldExit(_ sender: UITextField) {
        enableSigninButton()
        sender.resignFirstResponder()
    }
    
    //same as the previous func
    @IBAction func passwordTextFieldExit(_ sender: UITextField) {
        enableSigninButton()
        sender.resignFirstResponder()
    }
    
    //if tap the background, dissmiss the keyboard and check if signin button can be enabled
    @IBAction func bgDidTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        enableSigninButton()
    }
    
    //when alert happened, clean the password and email field
    func handleAction (action: UIAlertAction) {
        passwordTextField.text = nil
        emailTextField.text = nil
        signinButton.isEnabled = false
    }
    
    @IBAction func signinDidTapped(_ sender: Any) { //when the user try to sign in
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if email.isEmpty || password.isEmpty {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) {[weak self]authResult, error in
                if let error = error { //if the user failed to login, send alert
                    print(error)
                    let alertController = UIAlertController(title: "Invalid Email/Password!", message: "Please check your email and password!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: self?.handleAction)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                    return
                }
            self?.performSegue(withIdentifier: "SignInSegue", sender: nil) //if the user login successfully, jump to the list screen
        }
        
        
    }

}
