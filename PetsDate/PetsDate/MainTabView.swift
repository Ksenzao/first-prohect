import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MainTabView: View {
    var onLogout: () -> Void
    @State private var selectedTab: Int = 0
    
    // Бейджи
    @State private var likesCount: Int = 0
    @State private var unreadMessagesCount: Int = 0
    
    @State private var likesListener: ListenerRegistration? = nil
    @State private var chatsListener: ListenerRegistration? = nil
    
    private let db = Firestore.firestore()
    
    let appAccent = Color(red: 0.95, green: 0.5, blue: 0.2)
    let txtColor = Color(red: 0.3, green: 0.2, blue: 0.15)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    MainSwipeView()
                case 1:
                    LikesView()
                case 2:
                    ChatsListView()
                case 3:
                    UserProfileView(onLogout: {
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print("⚠️ Ошибка выхода: \(error.localizedDescription)")
                        }
                        onLogout()
                    })
                default:
                    MainSwipeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            customTabBar
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            listenToLikesCount()
            listenToUnreadMessages()
        }
    }
    
    // MARK: - Подписка на только НЕВЗАИМНЫЕ лайки
    private func listenToLikesCount() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        likesListener?.remove()
        
        likesListener = db.collection("likes")
            .whereField("to", isEqualTo: currentUid)
            .addSnapshotListener { snapshot, _ in
                guard let incomingDocs = snapshot?.documents else { return }
                let senders = Set(incomingDocs.compactMap { $0.data()["from"] as? String })
                
                db.collection("likes").whereField("from", isEqualTo: currentUid).getDocuments { outSnapshot, _ in
                    let myLikes = Set(outSnapshot?.documents.compactMap { $0.data()["to"] as? String } ?? [])
                    let unmatched = senders.subtracting(myLikes)
                    
                    Task { @MainActor in
                        self.likesCount = unmatched.count
                    }
                }
            }
    }
    
    // MARK: - Подписка на сообщения
    private func listenToUnreadMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        chatsListener?.remove()
        
        chatsListener = db.collection("chats")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                
                Task { @MainActor in
                    // Покажем уведомление, если есть хотя бы 1 активный диалог
                    self.unreadMessagesCount = docs.count
                }
            }
    }
    
    // MARK: - Таб-бар
    private var customTabBar: some View {
        HStack(spacing: 4) {
            tabButton(title: "Поиск", icon: "pawprint.fill", tabIndex: 0)
            tabButton(title: "Лайки", icon: "heart.fill", tabIndex: 1, badgeCount: likesCount)
            tabButton(title: "Чаты", icon: "bubble.left.and.bubble.right.fill", tabIndex: 2, badgeCount: unreadMessagesCount)
            tabButton(title: "Профиль", icon: "person.fill", tabIndex: 3)
        }
        .padding(6)
        .background(Color.white.opacity(0.95))
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
    
    private func tabButton(title: String, icon: String, tabIndex: Int, badgeCount: Int = 0) -> some View {
        let isSelected = selectedTab == tabIndex
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tabIndex
            }
        }) {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                    
                    if badgeCount > 0 {
                        Text("\(badgeCount > 99 ? "99+" : "\(badgeCount)")")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 10, y: -6)
                    }
                }
                
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? appAccent : .gray)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(
                Capsule()
                    .fill(isSelected ? appAccent.opacity(0.12) : Color.clear)
            )
        }
    }
}
