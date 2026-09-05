import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var dueDate: Date?
    var isDone: Bool
    var client: Client?
    var reminderDate: Date?
    var notificationID: UUID

    init(
        title: String,
        dueDate: Date? = nil,
        isDone: Bool = false,
        client: Client? = nil,
        reminderDate: Date? = nil
    ) {
        self.title = title
        self.dueDate = dueDate
        self.isDone = isDone
        self.client = client
        self.reminderDate = reminderDate
        self.notificationID = UUID()
    }
}
