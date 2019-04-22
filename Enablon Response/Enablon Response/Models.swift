

import Foundation
import FirebaseFirestore
import FirebaseCore

struct Alert {
    var name: String
    var message: String
    var id: String

    init?(_ document: QueryDocumentSnapshot) {
        let dict = document.data()
        
        guard
            let name = dict["name"] as? String,
            let message = dict["message"] as? String
        else {
            return nil
        }

        self.name = name
        self.message = message
        self.id = document.documentID
    }
}

struct AlertResponse {
    
}
