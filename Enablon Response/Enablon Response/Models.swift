

import Foundation

struct Alert {
    var name: String

    init?(_ dict: NSDictionary) {
        guard let name = dict["name"] as? String else {
            return nil
        }

        self.name = name
    }
}

struct AlertResponse {
    
}
