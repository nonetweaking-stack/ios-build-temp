import SwiftUI
import PhotosUI

struct FileTransferView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @StateObject private var fileManager = FileTransferManager()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showImagePicker = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                HStack {
                    Circle()
                        .fill(connectionManager.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(connectionManager.connectionStatus)
                        .font(.caption)
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "arrow.up.doc.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Send to PC")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Photos and files will be saved to your Downloads folder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    HStack {
                        Image(systemName: "photo")
                        Text("Select Photos")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(connectionManager.isConnected ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(!connectionManager.isConnected)
                .padding(.horizontal)
                .onChange(of: selectedItems) { items in
                    handleSelectedItems(items)
                }
                
                if fileManager.isUploading {
                    VStack(spacing: 10) {
                        ProgressView(value: fileManager.uploadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        Text("Uploading...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                if let lastFile = fileManager.lastUploadedFile {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Sent: \(lastFile)")
                            .font(.caption)
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                if let error = fileManager.error {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Divider()
                    
                    Text("Clipboard Sync")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Button(action: syncClipboardToPC) {
                            VStack {
                                Image(systemName: "doc.on.clipboard")
                                Text("Send to PC")
                                    .font(.caption)
                            }
                        }
                        .disabled(!connectionManager.isConnected)
                        
                        Button(action: syncClipboardFromPC) {
                            VStack {
                                Image(systemName: "arrow.down.doc")
                                Text("Get from PC")
                                    .font(.caption)
                            }
                        }
                        .disabled(!connectionManager.isConnected)
                    }
                }
                .padding()
            }
            .navigationTitle("File Transfer")
            .alert("Upload Complete", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("File sent to your PC's Downloads folder")
            }
        }
    }
    
    private func handleSelectedItems(_ items: [PhotosPickerItem]) {
        guard let host = connectionManager.host else { return }
        
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        DispatchQueue.main.async {
                            fileManager.uploadFile(data: data, filename: "image_\(UUID().uuidString).jpg", host: host)
                            showSuccessAlert = true
                        }
                    }
                case .failure(let error):
                    fileManager.error = error.localizedDescription
                }
            }
        }
        
        selectedItems.removeAll()
    }
    
    private func syncClipboardToPC() {
        guard let host = connectionManager.host,
              let content = UIPasteboard.general.string else { return }
        
        let apiService = APIService(host: host)
        apiService.setClipboard(content: content)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &Set<AnyCancellable>())
    }
    
    private func syncClipboardFromPC() {
        guard let host = connectionManager.host else { return }
        
        let apiService = APIService(host: host)
        apiService.getClipboard()
            .sink(receiveCompletion: { _ in }, receiveValue: { content in
                UIPasteboard.general.string = content
            })
            .store(in: &Set<AnyCancellable>())
    }
}
