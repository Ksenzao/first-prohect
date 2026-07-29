import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    @State private var scale = 0.8
    
    var body: some View {
        if isActive {
            // Переход на главный экран после загрузки (например, MainView())
            Text("Главный экран приложения") 
        } else {
            ZStack {
                // 1. Измененный фон: стильный градиент
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.45, blue: 0.35), // Теплый коралловый
                        Color(red: 0.95, green: 0.25, blue: 0.45)  // Насыщенный розовый
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 2. Декоративные иконки на фоне (паттерн)
                GeometryReader { proxy in
                    Canvas { context, size in
                        // Добавляем полупрозрачные иконки лапок по фону
                        let symbols = ["pawprint.fill", "heart.fill", "bone.fill"]
                        for i in 0..<15 {
                            let x = CGFloat.random(in: 0...size.width)
                            let y = CGFloat.random(in: 0...size.height)
                            let imageName = symbols[i % symbols.count]
                            
                            if let resolved = context.resolveSymbol(id: imageName) {
                                context.opacity = 0.12
                                context.draw(resolved, at: CGPoint(x: x, y: y))
                            }
                        }
                    } id: {
                        Image(systemName: "pawprint.fill").tag("pawprint.fill")
                        Image(systemName: "heart.fill").tag("heart.fill")
                        Image(systemName: "bone.fill").tag("bone.fill")
                    }
                }
                
                // 3. Логотип и название приложения (PetsDate)
                VStack(spacing: 16) {
                    // Иконка над названием
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                    
                    // Название
                    Text("PetsDate")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2) // Межбуквенный интервал
                    
                    // Слоган
                    Text("Найди друга своему питомцу")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.85))
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    // Анимация появления логотипа
                    withAnimation(.easeIn(duration: 1.0)) {
                        self.opacity = 1.0
                        self.scale = 1.0
                    }
                }
            }
            .onAppear {
                // Таймер задержки перед переходом на следующий экран (2.5 сек)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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
