import Foundation
import Combine

class WebSocketService: ObservableObject {
    @Published var isConnected = false
    @Published var lastMessage: [String: Any]?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let host: String
    private let deviceId: String
    private var pingTimer: Timer?
    
    init(host: String, deviceId: String) {
        self.host = host
        self.deviceId = deviceId
    }
    
    func connect() {
        guard let url = URL(string: "ws://\(host):8000/ws/\(deviceId)") else { return }
        
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        
        webSocketTask?.resume()
        isConnected = true
        
        receiveMessage()
        startPingTimer()
    }
    
    func disconnect() {
        pingTimer?.invalidate()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        isConnected = false
    }
    
    func send(message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let string = String(data: data, encoding: .utf8) else { return }
        
        webSocketTask?.send(.string(string)) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        DispatchQueue.main.async {
                            self?.lastMessage = json
                        }
                    }
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    break
                }
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                DispatchQueue.main.async {
                    self?.isConnected = false
                }
            }
        }
    }
    
    private func startPingTimer() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.send(message: ["type": "ping"])
        }
    }
}
