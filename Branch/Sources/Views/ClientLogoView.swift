import SwiftUI

struct ClientLogoView: View {
    let client: Client
    var size: CGFloat = 44

    private var tint: Color {
        switch client.logoTint {
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        default: return .gray
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.15))
            Image(systemName: client.logoSystemImage)
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ClientLogoView(client: Client(companyName: "Acme", contactPerson: "A", phone: "1", email: "a@a.com", address: "x"))
}
