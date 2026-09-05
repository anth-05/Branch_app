import Foundation
import SwiftData

@Model
final class Client {
    var companyName: String
    var contactPerson: String
    var phone: String
    var email: String
    var address: String
    var logoSystemImage: String
    var logoTint: String
    var notes: String

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.client)
    var tasks: [TaskItem] = []

    @Relationship(deleteRule: .nullify, inverse: \PlannerEvent.client)
    var events: [PlannerEvent] = []

    init(
        companyName: String,
        contactPerson: String,
        phone: String,
        email: String,
        address: String,
        logoSystemImage: String = "building.2.fill",
        logoTint: String = "green",
        notes: String = ""
    ) {
        self.companyName = companyName
        self.contactPerson = contactPerson
        self.phone = phone
        self.email = email
        self.address = address
        self.logoSystemImage = logoSystemImage
        self.logoTint = logoTint
        self.notes = notes
    }
}
