
import UIKit
import FirebaseFirestore

class AlertDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var severityLabel: UILabel!

    @IBOutlet weak var severityColorView: UIView!

    var alert: Alert!
    var listener: ListenerRegistration?

    deinit {
        self.listener?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Alert Details"

        self.nameLabel.text = "\(self.alert.name)"
        self.messageLabel.text = "\(self.alert.message)"
        self.severityLabel.text =  "\(self.alert.severity.title)"

        //  you are using what is called 'magic strings' here - basically arbitrary strings
        //  that you are assuming your data will contain/be equal to.  This is a recipe for very brittle code.
        //  I took what you were using in the form builder: severity levels = [1,2,3] and turned this business
        //  login into what is called an Enumerable.
        //  Enumerable's are data types that can be 1 of a given set, basically the data type is
        //  analogous to the definition of the adjective.
        //  something like "DaysOfWeek" could be an example of that is enumerable

        //  YOUR OLD CODE:

        /*
        if self.alert.severity.title == "1 - Low" {
            You can ascribe properties to your enumerable values, instead of hard-coding these colors, we
            define a property on our enum called "textBackgroundColor".  Imagine this is a fully-fleshed-out
            application and our designer says "hey, we're changing the shade of color for all HIGH severity
            alerts to a brighter red.  Now we're stuck replacing however many hard-coded values you left us.

            self.severityLabel.backgroundColor = UIColor.yellow

        } else if self.alert.severity.title == "2 - Medium" {
            self.severityLabel.backgroundColor = UIColor.orange
            self.severityLabel.textColor = UIColor.white
        } else {
            self.severityLabel.backgroundColor = UIColor.red
            self.severityLabel.textColor = UIColor.white
        }
        */

        //  MY REFACTOR -> see how all the logic for presentation is contained in the Severity enum?
        //  There is a pheonemon in iOS called 'MVC' and it stands for "Massive View Controllers".
        //  Basically the iOS design paradigms are constructed in such a way that unless you are very well-versed in
        //  abstracting design patterns and utilizing data structures, you end up dropping a TON of non-viewController
        //  related logic into your view controllers.  Your code was about 10 lines of if/else and hard-coded data
        //  which I was able to replace with 2 lines of reusable, flexible code.

        self.severityLabel.backgroundColor = self.alert.severity.backgroundColor
        self.severityLabel.textColor = self.alert.severity.textColor

        self.getAllResponses { [weak self] (data) in
            guard let _ = self, let responses = data else {
                return
            }

            print(responses)
        }
    }
}

//  Firebase stuff
extension AlertDetailViewController {

    func getParentDocumentId() -> String {
        return self.alert.id.replacingOccurrences(of: "/safetyAlerts/", with: "")
    }

    func getAllResponses(completion: @escaping([Response]?) -> ()) {
        let db = Firestore.firestore()
        var data: [Response] = []

        let parentId = self.getParentDocumentId()
        let parentRef = db.collection("safetyAlerts").document(parentId)

        db.collection("safetyAlertsResponses").order(by: "syncOn", descending: true)
            .whereField("safetyAlert", isEqualTo: parentRef)
            .getDocuments { (snapShot, err) in
                if let _ = err {
                    completion(nil)
                } else {
                    for doc in snapShot!.documents {
                        if let response = Response(doc) {
                            data.append(response)
                        }
                    }

                    completion(data)
                }
            }
    }

//    func newResponseReceived(response: Response) {
//        print("got one!")
//
//        DispatchQueue.main.async {
////            self.tableView.beginUpdates()
////            self.alerts.insert(alert, at: 0)
////
////            let path = IndexPath(row: 0, section: 0)
////
////            self.tableView.insertRows(at: [path], with: .left)
////            self.tableView.endUpdates()
//        }
//    }

//    func listenForNewResponses(latestTimestamp: Timestamp) {
//        let db = Firestore.firestore()
//
//        self.listener = db.collection("safetyAlertsResponses")
//            .addSnapshotListener { [weak self] (snapShot, err) in
//                guard let _ = self else {
//                    return
//                }
//
//                if let _ = err {
//                    print("error")
//                    return
//                } else {
//                    for doc in snapShot!.documents {
//                        if let response = Response(doc) {
//                            self!.newResponseReceived(response: response)
//                        }
//                    }
//                }
//        }
//    }
}
