import SwiftUI

struct PresentationView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
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
            
            VStack(spacing: 30) {
                PresentationButton(icon: "arrow.up", label: "Previous") {
                    sendPresentation(action: "previous")
                }
                .frame(height: 120)
                
                HStack(spacing: 20) {
                    PresentationButton(icon: "play.fill", label: "Start") {
                        sendPresentation(action: "start")
                    }
                    
                    PresentationButton(icon: "arrow.down", label: "Next") {
                        sendPresentation(action: "next")
                    }
                }
                .frame(height: 120)
                
                HStack(spacing: 20) {
                    PresentationButton(icon: "escape", label: "End") {
                        sendPresentation(action: "end")
                    }
                    
                    PresentationButton(icon: "circle.fill", label: "Blank") {
                        sendPresentation(action: "blank")
                    }
                }
                .frame(height: 80)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 10) {
                Text("Tips:")
                    .font(.caption)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    Label("Tap to click", systemImage: "hand.tap")
                        .font(.caption)
                    Label("Swipe to move", systemImage: "arrow.up.and.down")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 20)
        }
        .navigationTitle("Presentation")
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -50 {
                        sendPresentation(action: "next")
                    } else if value.translation.height > 50 {
                        sendPresentation(action: "previous")
                    }
                }
        )
    }
    
    private func sendPresentation(action: String) {
        connectionManager.send(message: [
            "type": "presentation_control",
            "data": ["action": action]
        ])
    }
}

struct PresentationButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                Text(label)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.primary)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue.opacity(0.1)))
        }
    }
}
