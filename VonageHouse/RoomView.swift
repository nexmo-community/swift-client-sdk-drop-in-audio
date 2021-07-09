import SwiftUI
import NexmoClient
import AVFoundation

struct MemberView: View {
    var memberName: String
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color.gray)
                .frame(width: 75, height: 75)
            Text(memberName)
        }
    }
}

struct RoomView: View {
    @StateObject var conversationModel = ConversationModel()
    @Environment(\.presentationMode) var presentationMode
    
    var convID: String
    var convName: String
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if conversationModel.loading {
                ProgressView()
                Text("Loading").padding(20)
            } else {
                VStack {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 75) {
                            ForEach(conversationModel.members, id: \.self) { member in
                                MemberView(memberName: member.name)
                            }
                        }
                    }
                    Button("Leave room") {
                        conversationModel.leaveConversation(completion: { presentationMode.wrappedValue.dismiss() })
                    }
                }
            }
        }.navigationTitle(convName)
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: {
            conversationModel.loadConversation(convID: convID)
        })
    }
}

final class ConversationModel: NSObject, ObservableObject, NXMConversationDelegate {
    @Published var loading = false
    @Published var members = [Member]()
    
    private var conversation: NXMConversation?
    private let currentUsername: String? = NXMClient.shared.user?.name
    
    func loadConversation(convID: String) {
        guard conversation == nil else { return }
        
        loading = true
        NXMClient.shared.getConversationWithUuid(convID) { error, conversation in
            self.conversation = conversation
            self.conversation?.delegate = self

            self.conversation?.join { [weak self] error, memberId in
                guard let self = self else { return }
                self.conversation?.getMembersPage(withPageSize: 100, order: .asc) { error, membersPage in
                    DispatchQueue.main.async {
                        guard let membersPage = membersPage else { return }
                        self.members = membersPage.memberSummaries.map { self.memberFrom($0) }

                        if !self.members.contains(where: { $0.name == self.currentUsername }) {
                            if let id = memberId, let name = self.currentUsername {
                                self.members.append(Member(id: id, name: name))
                            }
                        }
                        self.loading = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.conversation?.enableMedia()
                    }
                }
            }
        }
    }
    
    func leaveConversation(completion: () -> Void) {
        self.conversation?.disableMedia()
        self.conversation?.leave(nil)
        completion()
    }
    
    func memberFrom(_ event: NXMMemberEvent) -> Member {
        return Member(id: event.fromMemberId, name: event.embeddedInfo?.user.name ?? "")
    }
    
    func memberFrom(_ nxmMemberSummary: NXMMemberSummary) -> Member {
        return Member(id: nxmMemberSummary.memberUuid, name: nxmMemberSummary.user.name)
    }
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMMemberEvent) {
        let member = memberFrom(event)
        switch event.state {
        case .joined:
            guard !self.members.contains(member),
                  self.currentUsername != member.name else { break }
            self.members.append(member)
        case .left:
            guard self.members.contains(member),
                  let memberIndex = self.members.firstIndex(of: member) else { break }
            self.members.remove(at: memberIndex)
        default:
            break
        }
    }
    
    func conversation(_ conversation: NXMConversation, didReceive error: Error) {
        print(error.localizedDescription)
    }
}
