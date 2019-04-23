
import Foundation
import FirebaseFirestore
import FirebaseCore

struct ResponseRecipient {
    var isSafe: Bool?
    var recipientName: String
    var recipientNumber: String
    var recipientDisplayNumber = "(***) ***-****"
    var id: String = ""
    var timestamp: Timestamp?

    init?(_ dict: NSDictionary) {
        guard
            let name = dict["name"] as? String,
            let number = dict["phoneNumber"] as? String
        else {
                return nil
        }

        self.recipientName = name
        self.recipientNumber = number
    }

    init?(_ document: QueryDocumentSnapshot) {
        let dict = document.data()

        guard
            let name = dict["recipientName"] as? String,
            let number = dict["recipient"] as? String,
            let isSafe = dict["response"] as? Bool,
            let syncOn = dict["syncOn"] as? Timestamp
        else {
            return nil
        }

        self.recipientName = name
        self.recipientNumber = number
        self.timestamp = syncOn
        self.isSafe = isSafe

        self.id = document.documentID
    }

    static func statusImage(status: Bool?) -> UIImage? {
        guard let _ = status else {
            return nil
        }

        let imageName = status! ? "yes" : "no"
        return UIImage(named: imageName)!
    }

    static func statusText(status: Bool?) -> String {
        guard let _ = status else {
            return "Undetermined"
        }

        return status! ? "Safe" : "Unsafe"
    }
}

struct Alert {
    var name: String
    var message: String
    var severity: Severity = .low
    var latLong: String
    var id: String
    var timestamp: Timestamp

    var recipients: [ResponseRecipient] = []

    init?(_ document: QueryDocumentSnapshot) {
        let dict = document.data()

        guard
            let name = dict["name"] as? String,
            let message = dict["message"] as? String,
            let severityString = dict["severity"] as? String,
            let latLong = dict["eventLocationGPS"] as? String,
            let syncOn = dict["syncOn"] as? Timestamp,
            let recipients = dict["recipients"] as? [NSDictionary]
        else {
            return nil
        }

        self.name = name
        self.message = message
        self.latLong = latLong
        self.timestamp = syncOn

        let charSet = CharacterSet.decimalDigits.inverted

        if
            let severityInt = Int(severityString.components(separatedBy: charSet).joined(separator: "")) as Int?,
            //  these are zero-indexed, Firebase data isn't
            let severity = Severity.init(rawValue: severityInt - 1)
        {
            self.severity = severity
        }

        self.id = document.documentID

        for recipientDict in recipients {
            if let recipient = ResponseRecipient(recipientDict) {
                self.recipients.append(recipient)
            }
        }
    }

    enum Severity: Int {
        case low
        case medium
        case high

        var backgroundColor: UIColor {
            switch self {
            case .low:
                return .yellow
            case .medium:
                return .orange
            case .high:
                return .red
            }
        }

        var textColor: UIColor {
            switch self {
            case .low, .medium:
                return .black
            case .high:
                return .white
            }
        }

        var title: String {
            switch self {
            case .low:
                return "1 - Low"
            case .medium:
                return "2 - Medium"
            case .high:
                return "3 - High"
            }
        }
    }
}
