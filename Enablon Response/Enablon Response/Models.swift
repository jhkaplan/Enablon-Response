
import Foundation
import FirebaseFirestore
import FirebaseCore

struct Response {
    var isSafe: Bool
    var recipientName: String
    var recipientNumber: String
    var id: String
    var timestamp: Timestamp

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
}

struct Alert {
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

    var name: String
    var message: String
    var severity: Severity = .low
    var latLong: String
    var id: String
    var timestamp: Timestamp

    init?(_ document: QueryDocumentSnapshot) {
        let dict = document.data()

        guard
            let name = dict["name"] as? String,
            let message = dict["message"] as? String,
            let severityString = dict["severity"] as? String,
            let latLong = dict["eventLocationGPS"] as? String,
            let syncOn = dict["syncOn"] as? Timestamp
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
    }
}
