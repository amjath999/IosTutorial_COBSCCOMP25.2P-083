
import SwiftUI

// MARK: - INDIVIDUAL RISING BALLOON

struct RisingBalloon: View {

    let xPosition: CGFloat
    let size: CGFloat
    let delay: Double
    let duration: Double
    let emoji: String

    @State private var isRising = false

    var body: some View {

        GeometryReader { geometry in

            Text(emoji)
                .font(.system(size: size))
                .position(
                    x: geometry.size.width * xPosition,
                    y: isRising
                        ? -size
                        : geometry.size.height + size
                )
                .onAppear {

                    withAnimation(
                        .linear(duration: duration)
                            .delay(delay)
                            .repeatForever(autoreverses: false)
                    ) {

                        isRising = true
                    }
                }
        }
        .allowsHitTesting(false)
    }
}
