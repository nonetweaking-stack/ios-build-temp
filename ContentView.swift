import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectionManager: ConnectionManager
    
    var body: some View {
        NavigationView {
            Group {
                if connectionManager.isPaired {
                    MainTabView()
                } else {
                    PairingView()
                }
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            RemoteControlView()
                .tabItem {
                    Label("Remote", systemImage: "cursorarrow.click.2")
                }
            
            MediaControlView()
                .tabItem {
                    Label("Media", systemImage: "play.circle")
                }
            
            PresentationView()
                .tabItem {
                    Label("Slides", systemImage: "play.rectangle")
                }
            
            FileTransferView()
                .tabItem {
                    Label("Files", systemImage: "folder")
                }
        }
    }
}
