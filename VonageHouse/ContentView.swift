import SwiftUI
import NexmoClient
import AVFoundation

struct ContentView: View {
    @ObservedObject var authModel = AuthModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if authModel.loading {
                    ProgressView()
                    Text("Loading").padding(20)
                } else {
                    TextField("Name", text: $authModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .padding(20)
                    Button("Log in") {
                        authModel.login()
                    }
                    NavigationLink("", destination: RoomListView(),
                                   isActive: $authModel.connected).hidden()
                    
                }
            }.navigationTitle("VonageHouse 👋")
            .navigationBarBackButtonHidden(true)
        }.onAppear(perform: authModel.setup)
    }
}

final class AuthModel: NSObject, ObservableObject, NXMClientDelegate {
    @Published var loading = false
    @Published var connected = false
    
    var name = ""
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    func setup() {
        requestPermissionsIfNeeded()
    }
    
    func requestPermissionsIfNeeded() {
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { (isGranted) in
                print("Microphone permissions \(isGranted)")
            }
        }
    }
    
    func login() {
        loading = true
        
        RemoteLoader.load(urlString: "https://URL.ngrok.io/auth", body: Auth.Body(name: self.name), responseType: Auth.Response.self) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    NXMClient.shared.setDelegate(self)
                    NXMClient.shared.login(withAuthToken: response.jwt)
                }
            default:
                break
            }
        }
    }
    
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        switch status {
        case .connected:
            self.connected = true
            self.loading = false
        default:
            self.connected = false
            self.loading = false
        }
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        self.loading = false
        self.connected = false
    }
}
