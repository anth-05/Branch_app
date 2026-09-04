import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Branch")
                .font(.largeTitle.bold())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
