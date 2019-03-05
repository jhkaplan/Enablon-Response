//
//  ViewController.swift
//  Enablon Response
//
//  Created by Josh Kaplan on 2/15/19.
//  Copyright © 2019 Josh Kaplan. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class CreateAlertVC: FormViewController {
    
    let userEmail = Auth.auth().currentUser?.email
    

    
    override func viewDidLoad() {
    
        
        
        navigationItem.title = "Create Alert"
        
        super.viewDidLoad()
        
        createAlertForm()
        
    
    }

    @IBAction func signOutButtonTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func createAlertForm() {
        
        let responseOption1Default = "I'm Safe"
        let responseOption2Default = "I Need Assistance"
        
        
        form +++ Section("Alert Info")
            
            <<< TextRow("AlertName") { row in
                row.title = "Alert Name"
                row.placeholder = "Alert Name"
        }
            <<< TextAreaRow("AlertMessage") { row in
                row.title = "Alert Message Body"
                row.placeholder = "Alert Message"
            }
        
            <<< ActionSheetRow<String>() {
                $0.title = "Severity"
                $0.tag = "Severity"
                $0.selectorTitle = "Select Severity"
                $0.options = ["1 - Low","2 - Medium","3 - High"]
//                $0.value = "Two"    // initially selected
        }
        
        form +++ Section("Response Options")
            <<< CheckRow("ResponseRequiredBool") { row in
                row.title = "Response Required?"
        }
            <<< TextRow("Response1") { row in
                row.hidden = Condition.function(["ResponseRequiredBool"], { form in
                    return !((form.rowBy(tag: "ResponseRequiredBool") as? CheckRow)?.value ?? false)
                })
                row.title = "Press 1 for"
                row.value = responseOption1Default
        }
        
            <<< TextRow("Response2") { row in
                row.hidden = Condition.function(["ResponseRequiredBool"], { form in
                    return !((form.rowBy(tag: "ResponseRequiredBool") as? CheckRow)?.value ?? false)
                })
                row.title = "Press 2 for"
                row.value = responseOption2Default
        }
        
        form +++ Section("Select Message Recipients")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Select Locations"
                $0.options = ["CHI - Silver Runs", "DEN - Whiteleaf","PAR - Bluesky", "PER - North Star"]
                $0.tag = "recipient"
            }
        
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "Send Alert"
                }.onCellSelection({ (cell, row) in
                    let alertMessage: TextAreaRow! = self.form.rowBy(tag: "AlertMessage")
                    let messageValue = alertMessage!.value
                    
                    let nameRow: TextRow! = self.form.rowBy(tag: "AlertName")
                    let nameValue = nameRow!.value
                    
                    let responseRow: CheckRow! = self.form.rowBy(tag: "ResponseRequiredBool")
                    let responseSelection = responseRow!.value ?? false
                    
                    let responseOpt1Row: TextRow! = self.form.rowBy(tag: "Response1")
                    guard let responseOpt1 = responseOpt1Row!.value else { return }
                    
                    let responseOpt2Row: TextRow! = self.form.rowBy(tag: "Response2")
                    guard let responseOpt2 = responseOpt2Row!.value else { return }

                    
                    let locationSelection = self.form.rowBy(tag: "recipient").flatMap({ (row) -> String? in
                        if let row = row as? MultipleSelectorRow<String> {
                            return row.value?.joined(separator: ",")
                        }
                        return nil
                    })
                    
                    guard let alertSeverity = self.form.rowBy(tag: "Severity")?.baseValue else { return }
                    
                    print(locationSelection ?? "Empty")
                    
                    print(nameValue!)
                    print(messageValue!)
                    print(responseSelection)
                    print(locationSelection!)
                    print(alertSeverity)
                    print(responseOpt1)
                    print(responseOpt2)
                    print(self.userEmail!)

                    
                    /* Send Alert */
                    
                    let alert = UIAlertController(title: "Alert Sent", message: "Your alert named \(nameValue!) has been sent!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    /* End Send Alert */
                    
                    /* Clear Form */
                    
                    self.form.rowBy(tag: "AlertMessage")?.baseValue = ""
                    self.form.rowBy(tag: "AlertName")?.baseValue = ""
                    self.form.rowBy(tag: "ResponseRequiredBool")?.baseValue = nil
                    self.form.rowBy(tag: "recipient")?.baseValue = ""
                    self.form.rowBy(tag: "Severity")?.baseValue = ""
                    self.form.rowBy(tag: "Response1")?.baseValue = responseOption1Default
                    self.form.rowBy(tag: "Response2")?.baseValue = responseOption2Default
                    
                    
                    func postToZapier() {
                        /* Send Zapier Webhook Call */
                        
                        let alertParameters = ["alertMessageText": messageValue!, "alertName": nameValue!, "alertRecipientLocation": locationSelection, "responseRequired": responseSelection, "severity": alertSeverity, "responseOpt1": responseOpt1, "responseOpt2": responseOpt2, "userEmail": self.userEmail!] as [String : Any]
                        
                        guard let devURL = URL(string: "https://hooks.zapier.com/hooks/catch/2853627/p5e7iz/") else { return }
                        
                        guard let prodURL = URL(string: "https://hooks.zapier.com/hooks/catch/2853627/p2moc4/") else { return }
                        
                        var request =  URLRequest(url: prodURL)
                        
                        request.httpMethod = "POST"
                        guard let httpBody = try? JSONSerialization.data(withJSONObject: alertParameters, options: []) else {
                            return }
                        request.httpBody = httpBody
                        
                        let session = URLSession.shared
                        session.dataTask(with: request) { (data, response, error) in
                            if let response = response {
                                print(response)
                            }
                            
                            if let data = data {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                                    print(json)
                                } catch {
                                    print(error)
                                }
                            }
                            }.resume()
                        
                    }
                    
                postToZapier()

                })

        
    }
}
