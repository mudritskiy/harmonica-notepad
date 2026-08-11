import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink(destination: BackupRestoreView(viewModel: BackupRestoreViewModel())) {
                Text("Backup & Restore")
            }
        }
        .navigationTitle("Settings")
    }
}
