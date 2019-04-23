
import UIKit
import FirebaseFirestore

struct CellData {
    let alertName : String?
    let alertMessage : String?
}

class AlertsTableViewController: UITableViewController {

    var listener: ListenerRegistration?
    
    var alerts: [Alert] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    deinit {
        self.listener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Enablon Alerts"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.getAllAlerts { [weak self] (data) in
            guard let alerts = data, let _ = self else {
                print("failed to fetch data")
                return
            }

            self!.alerts = alerts
            var mostRecentTimestamp = Timestamp(date: Date())

            if let firstAlert = alerts.first {
                mostRecentTimestamp = firstAlert.timestamp
            }

            self!.listenForNewAlerts(latestTimestamp: mostRecentTimestamp)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alerts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
        cell.tag = indexPath.row

        let alert = self.alerts[indexPath.row]
        cell.configure(withAlert: alert)

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else {
            return
        }

        if let detailVC = segue.destination as? AlertDetailViewController {
            let alert = self.alerts[cell.tag]
            detailVC.alert = alert
        }
    }
}

//  Firebase stuff
extension AlertsTableViewController {

    func getAllAlerts(completion: @escaping([Alert]?) -> ()) {
        let db = Firestore.firestore()
        var data: [Alert] = []

        db.collection("safetyAlerts").order(by: "syncOn", descending: true).getDocuments { (snapShot, err) in
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
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.alerts.insert(alert, at: 0)

            let path = IndexPath(row: 0, section: 0)

            self.tableView.insertRows(at: [path], with: .left)
            self.tableView.endUpdates()
        }
    }

    func listenForNewAlerts(latestTimestamp: Timestamp) {
        let db = Firestore.firestore()

        self.listener = db.collection("safetyAlerts")
            .whereField("syncOn", isGreaterThan: latestTimestamp)
            .addSnapshotListener { [weak self] (snapShot, err) in
                guard let _ = self else {
                    return
                }

                if let _ = err {
                    print("error")
                    return
                } else {
                    for doc in snapShot!.documents {
                        if let alert = Alert(doc) {
                            self!.newAlertReceived(alert: alert)
                        }
                    }
                }
        }
    }
}
