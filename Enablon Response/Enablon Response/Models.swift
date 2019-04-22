
import Foundation
import FirebaseFirestore
import FirebaseCore

struct Alert {
    enum Severity: Int {
        case low
        case medium
        case high

        var color: UIColor {
            switch self {
                case .low:
                    return .yellow
                case .medium:
                    return .orange
                case .high:
                    return .red
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
