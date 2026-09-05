import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var dueDate: Date?
    var isDone: Bool
    var client: Client?

    init(
        title: String,
        dueDate: Date? = nil,
        isDone: Bool = false,
        client: Client? = nil
    ) {
        self.title = title
        self.dueDate = dueDate
        self.isDone = isDone
        self.client = client
    }
}
