import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)

            LoggingView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle.fill")
                }
                .tag(1)

            MedicationView()
                .tabItem {
                    Label("Medications", systemImage: "pills.fill")
                }
                .tag(2)

            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "chart.bar.doc.horizontal")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
}
