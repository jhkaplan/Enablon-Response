

import UIKit

class ResponseTableViewCell: UITableViewCell {

    static let identifier = "ResponseCell"

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!

    @IBOutlet weak var statusImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(withRecipient recipient: ResponseRecipient, isSafe: Bool?) {
        self.topLabel.text = "Name: \(recipient.recipientName)"
        self.middleLabel.text = "Number: \(recipient.recipientDisplayNumber)"

        self.statusImageView.image = ResponseRecipient.statusImage(status: isSafe)
        self.bottomLabel.text = "Response status: \(ResponseRecipient.statusText(status: isSafe))"
    }
}
