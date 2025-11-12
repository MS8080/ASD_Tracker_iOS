import SwiftUI

struct MedicationView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Medications")
                    .font(.largeTitle)
                    .padding()
                
                Text("Track your medications here")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Medications")
        }
    }
}

#Preview {
    MedicationView()
}
