import SwiftUI

struct PetsBackground: View {
    var body: some View {
        ZStack {
            // Тёплый градиентный фон
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.96, blue: 0.93),
                    Color(red: 0.95, green: 0.97, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Легкие фоновые лапки
            GeometryReader { geo in
                Group {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.35).opacity(0.06))
                        .rotationEffect(.degrees(-25))
                        .position(x: geo.size.width * 0.15, y: geo.size.height * 0.12)
                    
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.35).opacity(0.05))
                        .rotationEffect(.degrees(15))
                        .position(x: geo.size.width * 0.85, y: geo.size.height * 0.28)
                    
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.35).opacity(0.07))
                        .rotationEffect(.degrees(-10))
                        .position(x: geo.size.width * 0.1, y: geo.size.height * 0.75)
                    
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 52))
                        .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.35).opacity(0.04))
                        .rotationEffect(.degrees(30))
                        .position(x: geo.size.width * 0.88, y: geo.size.height * 0.82)
                }
            }
        }
    }
}
