
import UIKit
import FirebaseFirestore

class AlertDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var severityLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var parentRef: DocumentReference!

    var alert: Alert!

    var responses: [ResponseRecipient] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    var listener: ListenerRegistration?

    deinit {
        self.listener?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //  this could be put in an init method, but we're using segues...
        //  which I don't normally like to use for this exact reason
        let db = Firestore.firestore()
        let parentId = self.getParentDocumentId()
        self.parentRef = db.collection("safetyAlerts").document(parentId)

//        self.title = "\(self.alert.name)"
        self.title = "Alert Details"

        self.nameLabel.text = "\(self.alert.name)"
        self.messageLabel.text = "\(self.alert.message)"
        self.severityLabel.text =  "\(self.alert.severity.title)"

        let nib = UINib(nibName: "ResponseTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: ResponseTableViewCell.identifier)

        //  you are using what is called 'magic strings' here - basically arbitrary strings
        //  that you are assuming your data will contain/be equal to.  This is a recipe for very brittle code.
        //  I took what you were using in the form builder: severity levels = [1,2,3] and turned this business
        //  logic into what's called an Enumerable.
        //  Enumerables are data types that can be one value of a given set, basically the data type is
        //  analogous to the definition of the adjective:  something enumerable is countable and finite
        //  something like "DaysOfWeek" could be an example of an enumerable data type

        //  YOUR OLD CODE:

        //  what happens if someone mistypes and you have "1 - low"?  Yikes!
        if self.alert.severity.title == "1 - Low" {
            //  You can ascribe properties to your enumerable values, instead of hard-coding these colors, we
            //  define a property on our enum called "textBackgroundColor".  Imagine this is a fully-fleshed-out
            //  application and our designer says "hey, we're changing the shade of color for all HIGH severity
            //  alerts to a brighter red.  Now we're stuck replacing however many hard-coded values you left us.
            self.severityLabel.backgroundColor = UIColor.yellow
            //  see how there is no color set here and we're setting in the other two cases?
            //  it's choppy logic that relies on the default text color

        } else if self.alert.severity.title == "2 - Medium" {
            self.severityLabel.backgroundColor = UIColor.orange
            self.severityLabel.textColor = UIColor.white
            //  let's say we add a fourth case: '4 - Chernobyl'.  All of a sudden, this if/else logic is incomplete
        } else {
            self.severityLabel.backgroundColor = UIColor.red
            self.severityLabel.textColor = UIColor.white
        }

        //  MY REFACTOR -> see how all the logic for presentation is contained in the Severity enum?
        //  There is a pheonemon in iOS called 'MVC' and it stands for "Massive View Controllers".
        //  Basically the iOS design paradigms are constructed in such a way that unless you are very well-versed in
        //  abstracting design patterns and utilizing data structures, you end up dropping a TON of non-viewController
        //  related logic into your view controllers.  Your code was about 10 lines of if/else and hard-coded data
        //  which I was able to replace with 2 lines of reusable, flexible code.  I was guilty of MVC for a long time,
        //  I am still recovering.  Lots of small files == good, a few 500-line files...not so good

        self.severityLabel.backgroundColor = self.alert.severity.backgroundColor
        self.severityLabel.textColor = self.alert.severity.textColor

        self.getAllResponses { [weak self] (data) in
            guard let _ = self, let responses = data else {
                return
            }

            self!.responses = responses

            var mostRecentTimestamp = Timestamp(date: Date())

            if let lastResponse = responses.last {
                mostRecentTimestamp = lastResponse.timestamp!
            }

            self!.listenForNewResponses(latestTimestamp: mostRecentTimestamp)
        }
    }
}

//  UITableView stuff
extension AlertDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alert.recipients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipient = self.alert.recipients[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ResponseTableViewCell.identifier) as! ResponseTableViewCell

        let isSafe = self.responses.filter { (rec) -> Bool in
            let isMatch = rec.recipientNumber == recipient.recipientNumber
            return isMatch
        }.first?.isSafe

        cell.configure(withRecipient: recipient, isSafe: isSafe)

        return cell
    }
}

//  Firebase stuff
extension AlertDetailViewController {

    func getParentDocumentId() -> String {
        return self.alert.id.replacingOccurrences(of: "/safetyAlerts/", with: "")
    }

    func getAllResponses(completion: @escaping([ResponseRecipient]?) -> ()) {
        let db = Firestore.firestore()
        var data: [ResponseRecipient] = []

        db.collection("safetyAlertsResponses")
            .order(by: "syncOn", descending: false)
            .whereField("safetyAlert", isEqualTo: self.parentRef)
            .getDocuments { (snapShot, err) in
                if let _ = err {
                    completion(nil)
                } else {
                    for doc in snapShot!.documents {
                        if let response = ResponseRecipient(doc) {
                            data.append(response)
                        }
                    }

                    completion(data)
                }
            }
    }

    func newResponseReceived(response: ResponseRecipient) {
        DispatchQueue.main.async {
            self.responses.append(response)
            self.tableView.reloadData()
        }
    }

    func listenForNewResponses(latestTimestamp: Timestamp) {
        let db = Firestore.firestore()

        self.listener = db.collection("safetyAlertsResponses")
            .whereField("syncOn", isGreaterThan: latestTimestamp)
            .whereField("safetyAlert", isEqualTo: self.parentRef)
            .addSnapshotListener { [weak self] (snapShot, err) in
                guard let _ = self else {
                    return
                }

                if let _ = err {
                    print("not good")
                } else {
                    for doc in snapShot!.documents {
                        if let response = ResponseRecipient(doc) {
                            self!.newResponseReceived(response: response)
                        }
                    }
                }
        }
    }
}
