import Foundation
import SwiftData

@Model
final class TargetItem {
    var title: String
    var currentValue: Double
    var goalValue: Double
    var deadline: Date?
    var unit: String

    init(
        title: String,
        currentValue: Double,
        goalValue: Double,
        deadline: Date? = nil,
        unit: String = ""
    ) {
        self.title = title
        self.currentValue = currentValue
        self.goalValue = goalValue
        self.deadline = deadline
        self.unit = unit
    }

    var progress: Double {
        guard goalValue > 0 else { return 0 }
        return min(currentValue / goalValue, 1)
    }
}
