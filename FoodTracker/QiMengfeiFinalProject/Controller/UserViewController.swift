//
//  UserViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/27.
//

import UIKit
import Firebase

class UserViewController: UIViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser! //get current login user
        let userID = user.uid
        
        //get the collection of users' info, get the specific document reference using userID
        let docRef = Firestore.firestore().collection("users").document(userID)
        
        //if user information is read successfully
        docRef.getDocument(as: UserInfo.self) { result in
            switch result {
            case .success(let user):
                self.userNameLabel.text = "Name: " + user.getName()
                self.userEmailLabel.text = "Email: " + user.getEmail()
            case .failure(_):
                print ("Error decoding")
            }
        }
    }
    
    @IBAction func signOutDidTapped(_ sender: Any) { //if the user want to sign out
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "SignOutSegue", sender: nil) //if signout successfully, jump to the login page
        } catch let signoutError as NSError {
            let alertController = UIAlertController(title: "Oops!", message: "Sign out failed, please try again!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            print(signoutError)
            return
        }
    }

}
