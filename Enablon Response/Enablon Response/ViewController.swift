//
//  ViewController.swift
//  Enablon Response
//
//  Created by Josh Kaplan on 2/15/19.
//  Copyright © 2019 Josh Kaplan. All rights reserved.
//

import UIKit
import Eureka

class ViewController: FormViewController {
    

    
    override func viewDidLoad() {
    
        
        
        navigationItem.title = "Enablon Response"
        
        super.viewDidLoad()
        
        createAlertForm()
        
    
    }

    
    func createAlertForm() {
        
        form +++ Section("Alert Info")
            
            <<< TextRow("AlertName") { row in
                row.title = "Alert Name"
                row.placeholder = "Alert Name"
        }
            <<< TextAreaRow("AlertMessage") { row in
                row.title = "Alert Message Body"
                row.placeholder = "Alert Message"
            }
            <<< CheckRow("ResponseRequiredBool") { row in
                row.title = "Response Required?"
        }
        
            <<< ActionSheetRow<String>() {
                $0.title = "Severity"
                $0.selectorTitle = "Select Severity"
                $0.options = ["1 - Low","2 - Medium","3 - High"]
//                $0.value = "Two"    // initially selected
        }
        
        form +++ Section("Select Message Recipients")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Select Locations"
                $0.options = ["SPF Australia","Chicago","Denver", "Paris"]
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
                    let responseSelection = responseRow!.value

                    
                    let locationSelection = self.form.rowBy(tag: "recipient").flatMap({ (row) -> String? in
                        if let row = row as? MultipleSelectorRow<String> {
                            return row.value?.joined(separator: ",")
                        }
                        return nil
                    })
                    
                    print(locationSelection ?? "Empty")
                    
                    print(nameValue!)
                    print(messageValue!)
                    print(responseSelection!)
                    print(locationSelection)

                    
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
                    
                    
                    func postToZapier() {
                        /* Send Zapier Webhook Call */
                        
                        let alertParameters = ["alertMessageText": messageValue!, "alertName": nameValue!, "alertRecipientLocation": locationSelection]
                        
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
