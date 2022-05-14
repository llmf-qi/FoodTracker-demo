//
//  ViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/25.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener{[weak self]auth, user in
            if user == nil {
                self?.performSegue(withIdentifier: "outSegue", sender: nil) //if no user currently login, go to the login page
            } else {
                self?.performSegue(withIdentifier: "inSegue", sender: nil) //if there's a user login, go to the food list page
            }
        
        }
    }


}

