
import UIKit
import FirebaseFirestore

struct CellData {
    let alertName : String?
    let alertMessage : String?
}

class AlertsTableViewController: UITableViewController {
    
    var alerts: [Alert]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Safety Alerts"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.getAllAlerts { [weak self] (data) in
            guard let alerts = data, let _ = self else {
                print("failed to fetch data")
                return
            }

            self!.alerts = alerts
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alerts != nil ? self.alerts!.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
        cell.tag = indexPath.row

        let alert = self.alerts![indexPath.row]
        cell.configure(withAlert: alert)

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else {
            return
        }

        if let detailVC = segue.destination as? AlertDetailViewController {
            let alert = self.alerts![cell.tag]
            detailVC.alert = alert
        }
    }
}

//  Firebase stuff
extension AlertsTableViewController {

    func getAllAlerts(completion: @escaping([Alert]?) -> ()) {
        let db = Firestore.firestore()
        var data: [Alert] = []

        db.collection("safetyAlerts").getDocuments { (snapShot, err) in
            if let _ = err {
                completion(nil)
            } else {
                for doc in snapShot!.documents {
                    if let alert = Alert(doc) {
                        data.append(alert)
                    }
                }

                completion(data)
            }
        }
    }

    func newAlertReceived(alert: Alert) {

    }

    func listenForNewAlerts() {
        let db = Firestore.firestore()

        db.collection("safetyAlerts")
    }
}
