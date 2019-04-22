

import UIKit

class ResponseTableViewCell: UITableViewCell {

    static let identifier = "ResponseCell"

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        //  this is constant, and I prefer to do styling here, and do layout in the Interface builder
        self.bottomLabel.textColor = .white
    }

    func configure(withResponse response: Response) {
        self.topLabel.text = "Name: \(response.recipientName)"
        self.middleLabel.text = "Number: \(response.recipientNumber)"

        self.bottomLabel.text = "Response: " + (response.isSafe ? "safe" : "not safe")
        self.bottomLabel.backgroundColor = response.statusColor
    }
}
