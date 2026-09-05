import Foundation
import SwiftData

@Model
final class PlannerEvent {
    var title: String
    var date: Date
    var notes: String
    var client: Client?

    init(
        title: String,
        date: Date,
        notes: String = "",
        client: Client? = nil
    ) {
        self.title = title
        self.date = date
        self.notes = notes
        self.client = client
    }
}
