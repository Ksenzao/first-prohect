import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatsListView: View {
    @State private var activeChats: [PetProfile] = []
    @State private var isLoading: Bool = false
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        NavigationView {
            ZStack {
                PetsBackground()
                
                VStack(spacing: 16) {
                    // Хедер
                    HStack {
                        Text("Сообщения 💬")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundColor(txtColor)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    if isLoading {
                        Spacer()
                        ProgressView().tint(appAccent)
                        Spacer()
                    } else if activeChats.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 50))
                                .foregroundColor(appAccent.opacity(0.5))
                            Text("Пока нет активных чатов")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(txtColor)
                            Text("Ставьте лайки, чтобы найти взаимное совпадение!")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(activeChats) { profile in
                                    NavigationLink(destination: ChatDetailView(targetProfile: profile)) {
                                        chatRow(for: profile)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 90)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            fetchChats()
        }
    }
    
    private func chatRow(for profile: PetProfile) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(appAccent.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 24))
                        .foregroundColor(appAccent)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.petName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(txtColor)
                
                Text("Нажмите, чтобы открыть диалог")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
    
    private func fetchChats() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            loadMockChats()
            return
        }
        
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("chats").whereField("participants", arrayContains: currentUid).getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else {
                Task { @MainActor in
                    self.loadMockChats()
                }
                return
            }
            
            var targetUids: [String] = []
            for doc in docs {
                if let participants = doc.data()["participants"] as? [String] {
                    if let partner = participants.first(where: { $0 != currentUid }) {
                        targetUids.append(partner)
                    }
                }
            }
            
            if targetUids.isEmpty {
                Task { @MainActor in
                    self.loadMockChats()
                }
                return
            }
            
            var loadedProfiles: [PetProfile] = []
            let group = DispatchGroup()
            
            for uid in targetUids {
                group.enter()
                if uid.hasPrefix("mock") {
                    var mock = PetProfile()
                    mock.id = uid
                    mock.ownerUid = uid
                    mock.petName = uid == "mock1" ? "Боливар" : "Луна"
                    mock.breed = uid == "mock1" ? "Лабрадор" : "Хаски"
                    loadedProfiles.append(mock)
                    group.leave()
                } else {
                    FirestoreService.shared.fetchPetProfile(userId: uid) { result in
                        if case .success(let profile) = result {
                            loadedProfiles.append(profile)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.isLoading = false
                self.activeChats = loadedProfiles.isEmpty ? self.getMockProfiles() : loadedProfiles
            }
        }
    }
    
    private func loadMockChats() {
        self.isLoading = false
        self.activeChats = getMockProfiles()
    }
    
    private func getMockProfiles() -> [PetProfile] {
        var mock1 = PetProfile()
        mock1.id = "mock1"
        mock1.ownerUid = "mock1"
        mock1.petName = "Боливар"
        mock1.breed = "Лабрадор"
        mock1.ownerCity = "Минск"
        return [mock1]
    }
}
