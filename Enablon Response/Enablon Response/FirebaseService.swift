
import Foundation
import FirebaseFirestore

class FirebaseService {
    static func getAllAlerts(completion: @escaping([Alert]?) -> ()) {
        let db = Firestore.firestore()
        var data: [Alert] = []

        db.collection("safetyAlerts").getDocuments { (snapShot, err) in
            if let _ = err {
                print("yikes", err)
                completion(nil)
            } else {
                for doc in snapShot!.documents {
                    let dict = doc.data()

                    if let alert = Alert(doc) {
                        data.append(alert)
                    }
                }

                completion(data)
            }
        }
    }
}
