
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

        self.nameLabel.text = "Name: \(self.alert.name)"
        self.messageLabel.text = "Message: \(self.alert.message)"
        self.locationLabel.text = "Location: \(self.alert.latLong)"
        self.severityLabel.text =  "Severity: \(self.alert.severity.title)"

        self.severityColorView.backgroundColor = self.alert.severity.color
    }
}
