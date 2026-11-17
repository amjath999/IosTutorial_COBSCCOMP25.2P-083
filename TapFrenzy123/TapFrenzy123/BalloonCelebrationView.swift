
import SwiftUI

// MARK: - BALLOON CELEBRATION

struct BalloonCelebrationView: View {

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                ForEach(0..<24, id: \.self) { index in

                    RisingBalloon(
                        xPosition: CGFloat((index * 37) % 84 + 8) / 100,
                        size: CGFloat(28 + (index % 4) * 10),
                        delay: Double(index % 8) * 0.2,
                        duration: 4.0 + Double(index % 5) * 0.6,
                        emoji: index % 7 == 0
                            ? "🎉"
                            : (index % 5 == 0 ? "✨" : "🎈")
                    )
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
