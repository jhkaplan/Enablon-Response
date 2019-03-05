//
//  SignInVC.swift
//  Enablon Response
//
//  Created by Josh Kaplan on 3/5/19.
//  Copyright © 2019 Josh Kaplan. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import FirebaseAuth

class SignInVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser {
            self.performSegue(withIdentifier: "signedInSegue", sender: self)
        }
    }
    
    @IBAction func loginButtontapped(_ sender: Any) {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                print("Signed In!")
                self.performSegue(withIdentifier: "signedInSegue", sender: self)
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
        
    }
    

    
    
}
