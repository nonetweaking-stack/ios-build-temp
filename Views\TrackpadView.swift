import SwiftUI

struct TrackpadView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    @State private var lastLocation: CGPoint?
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                VStack {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Touch to move cursor")
                        .foregroundColor(.gray)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if let last = lastLocation {
                            let deltaX = value.location.x - last.x
                            let deltaY = value.location.y - last.y
                            
                            connectionManager.send(message: [
                                "type": "mouse_move",
                                "data": [
                                    "dx": Int(deltaX * 2),
                                    "dy": Int(deltaY * 2)
                                ]
                            ])
                        }
                        lastLocation = value.location
                    }
                    .onEnded { _ in
                        lastLocation = nil
                        
                        if !isDragging {
                            connectionManager.send(message: [
                                "type": "mouse_click",
                                "data": ["button": "left", "clicks": 1]
                            ])
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        isDragging = true
                        connectionManager.send(message: [
                            "type": "mouse_click",
                            "data": ["button": "left"]
                        ])
                    }
            )
        }
    }
}
