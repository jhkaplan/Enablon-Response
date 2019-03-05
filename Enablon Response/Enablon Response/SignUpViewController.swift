//
//  SignUpViewController.swift
//  Enablon Response
//
//  Created by Josh Kaplan on 3/5/19.
//  Copyright © 2019 Josh Kaplan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUpEmail: UITextField!
    @IBOutlet weak var signUpPasswordTF: UITextField!
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        guard let userEmail = signUpEmail.text else { return }
        guard let userPassword = signUpPasswordTF.text else { return }
        
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { user, error in
            if error == nil && user != nil {
                print("User created!")
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
