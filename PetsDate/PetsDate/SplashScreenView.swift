import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var scale = 0.8
    
    var body: some View {
        if isActive {
            OnboardingView()
        } else {
            ZStack {
                // Новый теплый естественный градиент
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color("AppBackground1"), location: 0.1),
                        Gradient.Stop(color: Color("AppBackground2"), location: 0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Фоновые иконки
                GeometryReader { proxy in
                    let symbols = ["pawprint.fill", "heart.fill", "bone.fill"]
                    ForEach(0..<15, id: \.self) { index in
                        Image(systemName: symbols[index % symbols.count])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white.opacity(0.25))
                            .position(
                                x: CGFloat((index * 67) % Int(proxy.size.width > 0 ? proxy.size.width : 300)),
                                y: CGFloat((index * 113) % Int(proxy.size.height > 0 ? proxy.size.height : 600))
                            )
                    }
                }
                
                // Логотип и название
                VStack(spacing: 16) {
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("AppAccent"))
                    
                    Text("PetsDate")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(Color("AppAccent"))
                        .tracking(2)
                    
                    Text("Найди друга своему питомцу")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.6))
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        self.opacity = 1.0
                        self.scale = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
