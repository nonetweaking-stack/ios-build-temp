import SwiftUI
import CodeScanner

struct PairingView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var pairingCode = ""
    @State private var hostAddress = ""
    @State private var showScanner = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "desktopcomputer.and.arrow.down")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding()
                
                Text("Connect to Your PC")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter the pairing code shown on your PC")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("PC IP Address")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g., 192.168.1.100", text: $hostAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Pairing Code")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("6-digit code", text: $pairingCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                }
                .padding(.horizontal)
                
                Button(action: { showScanner = true }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan QR Code")
                    }
                    .font(.headline)
                }
                .padding()
                
                Button(action: connect) {
                    Text("Connect")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canConnect ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!canConnect)
                .padding(.horizontal)
                
                if let error = connectionManager.lastError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("iOS-PC Bridge")
            .sheet(isPresented: $showScanner) {
                CodeScannerView(codeTypes: [.qr], completion: handleScan)
            }
        }
    }
    
    private var canConnect: Bool {
        pairingCode.count == 6 && !hostAddress.isEmpty
    }
    
    private func connect() {
        connectionManager.pair(withCode: pairingCode, host: hostAddress)
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        showScanner = false
        
        switch result {
        case .success(let scanResult):
            if let url = URL(string: scanResult.string),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                let queryItems = components.queryItems ?? []
                if let code = queryItems.first(where: { $0.name == "code" })?.value,
                   let host = queryItems.first(where: { $0.name == "host" })?.value {
                    pairingCode = code
                    hostAddress = host
                    connectionManager.pair(withCode: code, host: host)
                }
            }
        case .failure(let error):
            connectionManager.lastError = "QR scan failed: \(error.localizedDescription)"
        }
    }
}

struct PairingView_Previews: PreviewProvider {
    static var previews: some View {
        PairingView()
            .environmentObject(ConnectionManager())
    }
}
