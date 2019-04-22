
import Foundation
import UIKit

class AlertCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    func configure(withAlert alert: Alert) {
        self.titleLabel.text = alert.name
        self.messageLabel.text = alert.message
    }
}
