import SwiftUI

struct MediaControlView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        VStack(spacing: 40) {
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
                HStack(spacing: 30) {
                    MediaButton(icon: "speaker.fill", action: { sendMedia(action: "mute") })
                    
                    VStack(spacing: 20) {
                        MediaButton(icon: "volume.up", size: 50, action: { sendMedia(action: "volume_up") })
                        
                        MediaButton(icon: "volume.down", size: 50, action: { sendMedia(action: "volume_down") })
                    }
                }
            }
            
            Divider()
                .padding(.horizontal, 40)
            
            HStack(spacing: 40) {
                MediaButton(icon: "backward.fill", size: 50, action: { sendMedia(action: "previous") })
                
                MediaButton(icon: "playpause.fill", size: 70, action: { sendMedia(action: "play_pause") })
                
                MediaButton(icon: "forward.fill", size: 50, action: { sendMedia(action: "next") })
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                QuickActionButton(label: "Mute", icon: "speaker.slash.fill") {
                    sendMedia(action: "mute")
                }
                
                QuickActionButton(label: "Screenshot", icon: "camera.fill") {
                    connectionManager.send(message: [
                        "type": "screenshot",
                        "data": [:]
                    ])
                }
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Media Control")
    }
    
    private func sendMedia(action: String) {
        connectionManager.send(message: [
            "type": "media_control",
            "data": ["action": action]
        ])
    }
}

struct MediaButton: View {
    let icon: String
    var size: CGFloat = 40
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(.primary)
                .frame(width: size * 2, height: size * 2)
                .background(Circle().fill(Color.secondary.opacity(0.2)))
        }
    }
}

struct QuickActionButton: View {
    let label: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .frame(width: 80, height: 80)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.15)))
        }
    }
}
