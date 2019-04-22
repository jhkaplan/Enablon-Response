
import UIKit

class AlertDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var severityLabel: UILabel!

    @IBOutlet weak var severityColorView: UIView!

    var alert: Alert!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Alert Details"

        self.nameLabel.text = "\(self.alert.name)"
        self.messageLabel.text = "\(self.alert.message)"
//        self.locationLabel.text = "\(self.alert.latLong)"
        self.severityLabel.text =  "\(self.alert.severity.title)"
        
        if self.alert.severity.title == "1 - Low" {
            self.severityLabel.backgroundColor = UIColor.yellow
            print("1-low")
        } else if self.alert.severity.title == "2 - Medium" {
            self.severityLabel.backgroundColor = UIColor.orange
            self.severityLabel.textColor = UIColor.white
        } else {
            self.severityLabel.backgroundColor = UIColor.red
            self.severityLabel.textColor = UIColor.white
        }

//        self.severityColorView.backgroundColor = self.alert.severity.color
    }
}
