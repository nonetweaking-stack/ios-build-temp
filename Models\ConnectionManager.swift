import Foundation
import Combine

class ConnectionManager: ObservableObject {
    @Published var isPaired = false
    @Published var isConnected = false
    @Published var connectionStatus = "Not Connected"
    @Published var pairedDeviceId: String?
    @Published var host: String?
    @Published var lastError: String?
    
    private var webSocketService: WebSocketService?
    private var apiService: APIService?
    private var cancellables = Set<AnyCancellable>()
    
    func pair(withCode code: String, host: String) {
        self.host = host
        self.apiService = APIService(host: host)
        
        apiService?.pairDevice(code: code)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.lastError = error.localizedDescription
                }
            }, receiveValue: { response in
                if response.success {
                    self.pairedDeviceId = response.deviceId
                    self.isPaired = true
                    self.connect()
                } else {
                    self.lastError = response.error ?? "Pairing failed"
                }
            })
            .store(in: &cancellables)
    }
    
    func connect() {
        guard let host = host, let deviceId = pairedDeviceId else { return }
        
        webSocketService = WebSocketService(host: host, deviceId: deviceId)
        webSocketService?.connect()
        
        webSocketService?.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { isConnected in
                self.isConnected = isConnected
                self.connectionStatus = isConnected ? "Connected" : "Disconnected"
            }
            .store(in: &cancellables)
    }
    
    func disconnect() {
        webSocketService?.disconnect()
        webSocketService = nil
        isConnected = false
        connectionStatus = "Disconnected"
    }
    
    func unpair() {
        disconnect()
        isPaired = false
        pairedDeviceId = nil
        host = nil
        apiService = nil
    }
    
    func send(message: [String: Any]) {
        webSocketService?.send(message: message)
    }
}

struct PairResponse: Codable {
    let success: Bool
    let deviceId: String?
    let error: String?
}
