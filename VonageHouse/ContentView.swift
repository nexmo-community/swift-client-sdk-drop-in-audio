//
//  ContentView.swift
//  VonageHouse
//
//  Created by Abdulhakim Ajetunmobi on 03/02/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var roomModel = RoomModel()
    
    var body: some View {
        VStack {
            List(roomModel.results, id: \.id) { item in
                VStack(alignment: .leading) {
                    NavigationLink(destination: RoomView(convID: item.id, convName: item.displayName)) {
                        Text(item.displayName)
                    }
                }
            }.onAppear(perform: roomModel.loadRooms)
            Button("Create room") {
                roomModel.showingCreateModal.toggle()
            }
            NavigationLink("", destination: RoomView(convID: roomModel.convID ?? "", convName: roomModel.roomName),
                           isActive: $roomModel.hasConv).hidden()
        }
        .navigationTitle("VonageCottage 👋")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing:
                                Button("Refresh") {
                                    roomModel.loadRooms()
                                }
        )
        .sheet(isPresented: $roomModel.showingCreateModal, content: {
            CreateRoomModal(roomModel: roomModel)
        })
    }
}

struct CreateRoomModal: View {
    @ObservedObject var roomModel: RoomModel
    
    var body: some View {
        if !roomModel.loading {
            VStack {
                TextField("Enter the room name", text: $roomModel.roomName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(20)
                Button("Create room") {
                    roomModel.loading = true
                    roomModel.createRoom()
                }
            }
        } else {
            ProgressView()
        }
    }
    
    
}

final class RoomModel: ObservableObject {
    @Published var results = [RoomResponse]()
    @Published var loading: Bool = false
    @Published var showingCreateModal = false
    @Published var hasConv = false
    
    var convID: String? = nil
    var roomName: String = ""
    
    func loadRooms() {
        RemoteLoader.load(urlString: "https://URL.ngrok.io/rooms", body: Optional<String>.none, responseType: [RoomResponse].self) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.results = response
                }
            default:
                break
            }
        }
    }
    
    func createRoom() {
        RemoteLoader.load(urlString: "https://URL.ngrok.io/rooms", body: CreateRoom.Body(displayName: self.roomName), responseType: CreateRoom.Response.self) { result in
            switch result {
            case .success(let response):
                self.convID = response.id
                DispatchQueue.main.async {
                    self.hasConv = true
                    self.loading = false
                    self.showingCreateModal = false
                }
            default:
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
