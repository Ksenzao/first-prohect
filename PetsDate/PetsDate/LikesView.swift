import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LikesView: View {
    @State private var likedByProfiles: [PetProfile] = []
    @State private var isLoading: Bool = false
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        NavigationView {
            ZStack {
                PetsBackground()
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Кто вас лайкнул 🐾")
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
                    } else if likedByProfiles.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "heart.slash.fill")
                                .font(.system(size: 50))
                                .foregroundColor(appAccent.opacity(0.5))
                            Text("Пока нет новых лайков")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(txtColor)
                            Text("Ваша анкета появится у других пользователей!")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(likedByProfiles) { profile in
                                    likeCard(for: profile)
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
            fetchUnmatchedLikes()
        }
    }
    
    private func likeCard(for profile: PetProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.95, green: 0.85, blue: 0.75))
                    .frame(height: 160)
                
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 50))
                    .foregroundColor(appAccent.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .cornerRadius(20)
                
                Text(profile.petName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(12)
            }
            
            Text("\(profile.breed.isEmpty ? "Без породы" : profile.breed) • \(profile.ownerCity)")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.gray)
                .lineLimit(1)
                .padding(.horizontal, 4)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Загрузка лайков ИСКЛЮЧАЯ совпадения (мэтчи)
    private func fetchUnmatchedLikes() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            self.likedByProfiles = []
            return
        }
        
        isLoading = true
        let db = Firestore.firestore()
        
        // 1. Получаем все входящие лайки (кто лайкнул меня)
        db.collection("likes").whereField("to", isEqualTo: currentUid).getDocuments { incomingSnapshot, error in
            guard let incomingDocs = incomingSnapshot?.documents, error == nil else {
                self.isLoading = false
                return
            }
            
            let sendersWhoLikedMe = Set(incomingDocs.compactMap { $0.data()["from"] as? String })
            
            if sendersWhoLikedMe.isEmpty {
                self.isLoading = false
                self.likedByProfiles = []
                return
            }
            
            // 2. Получаем свои исходящие лайки (кого лайкнул я)
            db.collection("likes").whereField("from", isEqualTo: currentUid).getDocuments { outgoingSnapshot, _ in
                let myLikes = Set(outgoingSnapshot?.documents.compactMap { $0.data()["to"] as? String } ?? [])
                
                // 3. Фильтруем: оставляем ТОЛЬКО тех, кого мы ЕЩЁ НЕ лайкнули (не мэтч)
                let unmatchedSenders = Array(sendersWhoLikedMe.subtracting(myLikes))
                
                if unmatchedSenders.isEmpty {
                    Task { @MainActor in
                        self.isLoading = false
                        self.likedByProfiles = []
                    }
                    return
                }
                
                // 4. Подгружаем профили питомцев
                var loadedProfiles: [PetProfile] = []
                let group = DispatchGroup()
                
                for uid in unmatchedSenders {
                    group.enter()
                    FirestoreService.shared.fetchPetProfile(userId: uid) { result in
                        if case .success(let profile) = result {
                            loadedProfiles.append(profile)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.isLoading = false
                    self.likedByProfiles = loadedProfiles
                }
            }
        }
    }
}
