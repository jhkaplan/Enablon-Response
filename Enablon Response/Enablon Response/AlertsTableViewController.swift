
import UIKit

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
        
        FirebaseService.getAllAlerts { [weak self] (data) in
            guard let alerts = data, let _ = self else {
                print("failed to fetch data")
                return
            }

            self!.alerts = alerts
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.alerts != nil ? self.alerts!.count : 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell

        let alert = self.alerts![indexPath.row]
        cell.configure(withAlert: alert)

        return cell
    }

    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
