
import SwiftUI
import Combine

// MARK: - TAP FRENZY GAME

struct TapFrenzyView: View {

    @State private var score = 0

    @AppStorage("tapFrenzyBestScore")
    private var bestScore = 0

    @State private var timeLeft = 10
    @State private var isPlaying = false
    @State private var gameOver = false

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {

        ZStack {

            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {

                Text("TAP FRENZY")
                    .font(.largeTitle.bold())
                    .foregroundColor(.cyan)

                Text("Tap as fast as you can!")
                    .foregroundColor(.gray)

                HStack {

                    VStack {

                        Text("SCORE")
                            .foregroundColor(.gray)

                        Text("\(score)")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                    }

                    Spacer()

                    VStack {

                        Text("BEST")
                            .foregroundColor(.gray)

                        Text("\(bestScore)")
                            .font(.largeTitle.bold())
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)

                Text("TIME: \(timeLeft)s")
                    .font(.title.bold())
                    .foregroundColor(.cyan)

                Spacer()

                if gameOver {

                    Text("GAME OVER!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.red)

                    Text("Your Score: \(score)")
                        .font(.title2)
                        .foregroundColor(.white)

                    Button("PLAY AGAIN") {
                        resetGame()
                    }
                    .font(.title2.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)

                } else {

                    Button {

                        if !isPlaying {
                            isPlaying = true
                        }

                        score += 1

                        if score > bestScore {
                            bestScore = score
                        }

                    } label: {

                        VStack(spacing: 15) {

                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 45))

                            Text("TAP ME")
                                .font(.largeTitle.bold())
                        }
                        .foregroundColor(.white)
                        .frame(width: 200, height: 200)
                        .background(Color.blue)
                        .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text("Best Score: \(bestScore)")
                    .foregroundColor(.yellow)
            }
            .padding()
        }
        .onReceive(timer) { _ in

            if isPlaying && !gameOver {

                if timeLeft > 0 {
                    timeLeft -= 1
                }

                if timeLeft == 0 {
                    gameOver = true
                    isPlaying = false
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // RESET TAP FRENZY

    private func resetGame() {

        score = 0
        timeLeft = 10
        isPlaying = false
        gameOver = false
    }
}
