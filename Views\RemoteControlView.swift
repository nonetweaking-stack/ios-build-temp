import SwiftUI

struct RemoteControlView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var typedText = ""
    @State private var showKeyboard = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Circle()
                    .fill(connectionManager.isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(connectionManager.connectionStatus)
                    .font(.caption)
                Spacer()
                Button("Unpair") {
                    connectionManager.unpair()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.horizontal)
            
            TrackpadView()
                .frame(height: 250)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button(action: { sendClick(button: "left") }) {
                    Text("Left Click")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: { sendClick(button: "right") }) {
                    Text("Right Click")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            HStack {
                Button(action: { sendScroll(clicks: 3) }) {
                    Image(systemName: "chevron.up")
                        .font(.title2)
                }
                .frame(maxWidth: .infinity)
                
                Text("Scroll")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: { sendScroll(clicks: -3) }) {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            VStack(spacing: 10) {
                HStack {
                    TextField("Type here...", text: $typedText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Send") {
                        sendText()
                    }
                    .disabled(typedText.isEmpty)
                }
                
                HStack(spacing: 10) {
                    ShortcutButton(label: "Copy", keys: ["ctrl", "c"])
                    ShortcutButton(label: "Paste", keys: ["ctrl", "v"])
                    ShortcutButton(label: "Undo", keys: ["ctrl", "z"])
                    ShortcutButton(label: "Enter", keys: ["return"])
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
        .navigationTitle("Remote Control")
    }
    
    private func sendClick(button: String) {
        connectionManager.send(message: [
            "type": "mouse_click",
            "data": ["button": button, "clicks": 1]
        ])
    }
    
    private func sendScroll(clicks: Int) {
        connectionManager.send(message: [
            "type": "mouse_scroll",
            "data": ["clicks": clicks]
        ])
    }
    
    private func sendText() {
        connectionManager.send(message: [
            "type": "type_text",
            "data": ["text": typedText]
        ])
        typedText = ""
    }
}

struct ShortcutButton: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    let label: String
    let keys: [String]
    
    var body: some View {
        Button(action: {
            connectionManager.send(message: [
                "type": "key_shortcut",
                "data": ["keys": keys]
            ])
        }) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(6)
        }
    }
}
