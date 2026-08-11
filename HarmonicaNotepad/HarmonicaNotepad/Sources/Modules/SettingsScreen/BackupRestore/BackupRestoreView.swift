import SwiftUI
import UniformTypeIdentifiers

struct BackupRestoreView: View {
    @Bindable private var _viewModel: BackupRestoreViewModel
    @Environment(\.modelContext) private var _context
    @Environment(AppNavigationModel.self) private var _appNavigation
    @State private var _isExporterPresented = false
    @State private var _isImporterPresented = false

    init(viewModel: BackupRestoreViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        List {
            Section("Export") {
                if let exportFileURL = _viewModel.exportFileURL {
                    Button("Save Backup File") {
                        _isExporterPresented = true
                    }
                    ShareLink(item: exportFileURL) {
                        Text("Share Backup")
                    }
                }
            }
            Section("Restore") {
                Button("Restore from Backup…", role: .destructive) {
                    _isImporterPresented = true
                }
            }
        }
        .navigationTitle("Backup & Restore")
        .onAppear {
            _viewModel.modelContext = _context
            _viewModel.refreshExportArtifacts()
            _viewModel.onRestoreCompleted = {
                _appNavigation.mainRouter.popToRoot()
                _appNavigation.songsLists.popToRoot()
                _appNavigation.favoriteRouter.popToRoot()
                _appNavigation.searchList.popToRoot()
                _appNavigation.selectedTab = .songs
            }
        }
        .fileExporter(
            isPresented: $_isExporterPresented,
            item: _viewModel.exportFileURL,
            contentTypes: [.json],
            defaultFilename: "harmonica-backup"
        ) { result in
            if case .failure(let error) = result {
                _viewModel.reportFileOperationFailure(error)
            }
        }
        .fileImporter(
            isPresented: $_isImporterPresented,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
                case .success(let url):
                    _viewModel.prepareRestore(from: url)
                case .failure(let error):
                    _viewModel.reportFileOperationFailure(error)
            }
        }
        .alertInfo(isPresented: $_viewModel.showAlert, _viewModel.alertInfo)
    }
}
