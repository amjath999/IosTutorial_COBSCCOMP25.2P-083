
import SwiftUI
import Combine

// MARK: - LIGHT IT UP GAME

struct LightItUpView: View {

    private let roundDuration = 60

    private let gameTimer = Timer.publish(
        every: 0.05,
        on: .main,
        in: .common
    ).autoconnect()

    // SAVE BEST SCORE

    @AppStorage("lightItUpBestScore")
    private var bestScore = 0

    // GAME VARIABLES

    @State private var score = 0
    @State private var timeLeft = 60
    @State private var lives = 3

    @State private var isPlaying = false
    @State private var gameOver = false
    @State private var didWin = false

    @State private var activeLevel = 1

    // TIMER VARIABLES

    @State private var roundStartTime: Date? = nil
    @State private var nextTargetTime: Date? = nil
    @State private var targetDeadline: Date? = nil

    // LIT CARDS

    @State private var litCards: Set<Int> = []

    // TAP FEEDBACK

    @State private var feedbackCard: Int? = nil
    @State private var feedbackIsCorrect = true

    // MARK: LEVEL SETTINGS

    private var numberOfCards: Int {

        switch activeLevel {

        case 1:
            return 3

        case 2:
            return 4

        case 3:
            return 6

        default:
            return 9
        }
    }

    private var numberOfColumns: Int {

        activeLevel == 2 ? 2 : 3
    }

    private var gridColumns: [GridItem] {

        Array(
            repeating: GridItem(
                .flexible(),
                spacing: 12
            ),
            count: numberOfColumns
        )
    }

    private var litWindow: TimeInterval {

        switch activeLevel {

        case 1:
            return 1.5

        case 2:
            return 1.2

        case 3:
            return 1.0

        default:
            return 0.8
        }
    }

    // DIFFERENT COLOUR FOR EACH LEVEL

    private var levelColor: Color {

        switch activeLevel {

        case 1:
            return .cyan

        case 2:
            return .green

        case 3:
            return .orange

        default:
            return .pink
        }
    }


    // MARK: MAIN GAME SCREEN

    var body: some View {

        ZStack {

            Color.black.ignoresSafeArea()

            // BALLOONS BEHIND THE WINNING SCREEN

            if gameOver && didWin {

                BalloonCelebrationView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            VStack(spacing: 22) {

                Text("LIGHT IT UP")
                    .font(.largeTitle.bold())
                    .foregroundColor(.orange)

                Text("Tap the glowing cards!")
                    .foregroundColor(.gray)

                // SCORE, LEVEL AND LIVES

                HStack(spacing: 10) {

                    statCard(
                        title: "SCORE",
                        value: "\(score)",
                        tint: .white
                    )

                    statCard(
                        title: "LEVEL",
                        value: "\(activeLevel)",
                        tint: levelColor
                    )

                    statCard(
                        title: "LIVES",
                        value: "\(lives)",
                        tint: .red
                    )
                }

                // TIME

                Text("TIME LEFT: \(timeLeft)s")
                    .font(.title2.bold())
                    .foregroundColor(.cyan)

                // RESULT SCREEN

                if gameOver {

                    Spacer()

                    VStack(spacing: 18) {

                        if didWin {

                            Text("🏆")
                                .font(.system(size: 76))

                            Text("🎉 YOU WON! 🎉")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.center)

                            Text("Amazing! You survived all 60 seconds!")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.green)

                        } else {

                            Text("💔")
                                .font(.system(size: 65))

                            Text("GAME OVER")
                                .font(.largeTitle.bold())
                                .foregroundColor(.red)

                            Text("You lost all your lives. Try again!")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }

                        Text("FINAL SCORE")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("\(score)")
                            .font(.system(size: 55, weight: .bold))
                            .foregroundColor(.white)

                        Text("🏆 BEST SCORE: \(bestScore)")
                            .foregroundColor(.yellow)

                        // PLAY AGAIN BUTTON

                        Button {

                            resetRound()

                        } label: {

                            HStack {

                                Image(systemName: "arrow.clockwise")

                                Text("PLAY AGAIN")
                                    .fontWeight(.bold)
                            }
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [.green, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(18)
                        }
                    }
                    .padding()

                    Spacer()

                } else {

                    // START INSTRUCTIONS

                    if !isPlaying {

                        Text("Tap any card to start")
                            .font(.headline)
                            .foregroundColor(.yellow)

                    } else {

                        Text("Find the glowing card before it disappears")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // CARD GRID

                    LazyVGrid(
                        columns: gridColumns,
                        spacing: 14
                    ) {

                        ForEach(
                            0..<numberOfCards,
                            id: \.self
                        ) { index in

                            Button {

                                handleCardTap(index)

                            } label: {

                                RoundedRectangle(cornerRadius: 18)
                                    .fill(cardColor(for: index))
                                    .frame(height: 78)

                                    .overlay {

                                        Image(
                                            systemName: litCards.contains(index)
                                                ? "bolt.fill"
                                                : "circle"
                                        )
                                        .font(
                                            .system(
                                                size: litCards.contains(index) ? 27 : 13,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundColor(
                                            litCards.contains(index)
                                                ? .black
                                                : .white.opacity(0.15)
                                        )
                                    }

                                    .overlay {

                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                litCards.contains(index)
                                                    ? Color.white.opacity(0.8)
                                                    : Color.white.opacity(0.1),
                                                lineWidth: litCards.contains(index) ? 2 : 1
                                            )
                                    }

                                    .shadow(
                                        color: litCards.contains(index)
                                            ? levelColor.opacity(0.5)
                                            : .clear,
                                        radius: 12
                                    )

                                    .scaleEffect(
                                        litCards.contains(index) ? 1.05 : 1.0
                                    )

                                    .animation(
                                        .easeInOut(duration: 0.15),
                                        value: litCards.contains(index)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 10)

                    Spacer(minLength: 10)

                    Text("BEST SCORE: \(bestScore)")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
        }

        // GAME TIMER

        .onReceive(gameTimer) { now in
            updateGame(at: now)
        }

        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }


    // MARK: STATUS CARD

    private func statCard(
        title: String,
        value: String,
        tint: Color
    ) -> some View {

        VStack(spacing: 8) {

            Text(title)
                .font(.caption.bold())
                .foregroundColor(.gray)

            Text(value)
                .font(.title.bold())
                .foregroundColor(tint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }


    // MARK: CARD COLOUR

    private func cardColor(for index: Int) -> Color {

        if feedbackCard == index {
            return feedbackIsCorrect ? .green : .red
        }

        if litCards.contains(index) {
            return levelColor
        }

        return Color.white.opacity(0.09)
    }


    // MARK: START ROUND

    private func startRound() {

        score = 0
        lives = 3
        timeLeft = roundDuration
        activeLevel = 1

        litCards.removeAll()
        feedbackCard = nil
        targetDeadline = nil

        didWin = false
        gameOver = false

        roundStartTime = Date()

        nextTargetTime = Date().addingTimeInterval(0.5)

        isPlaying = true
    }


    // MARK: HANDLE CARD TAP

    private func handleCardTap(_ index: Int) {

        // FIRST TAP STARTS THE GAME

        if !isPlaying && !gameOver {

            startRound()
            return
        }

        guard isPlaying && !gameOver else {
            return
        }

        // CORRECT TAP

        if litCards.contains(index) {

            score += 1

            showFeedback(
                for: index,
                correct: true
            )

            litCards.remove(index)

            // LEVEL 4 REQUIRES BOTH LIT CARDS TO BE TAPPED

            if litCards.isEmpty {

                targetDeadline = nil

                nextTargetTime = Date().addingTimeInterval(0.4)
            }

        } else {

            // WRONG TAP

            showFeedback(
                for: index,
                correct: false
            )

            loseLife(at: Date())
        }
    }


    // MARK: TAP FEEDBACK

    private func showFeedback(
        for index: Int,
        correct: Bool
    ) {

        feedbackCard = index
        feedbackIsCorrect = correct

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.25
        ) {

            if feedbackCard == index {
                feedbackCard = nil
            }
        }
    }


    // MARK: UPDATE GAME TIMER AND LEVELS

    private func updateGame(at now: Date) {

        guard isPlaying,
              let startTime = roundStartTime else {
            return
        }

        let elapsed = now.timeIntervalSince(startTime)

        // COMPLETE 60 SECONDS = WIN

        if elapsed >= Double(roundDuration) {

            timeLeft = 0

            finishRound(won: true)

            return
        }

        timeLeft = max(
            0,
            roundDuration - Int(elapsed)
        )

        // AUTOMATIC LEVEL PROGRESSION

        let newLevel = levelForElapsed(elapsed)

        if newLevel != activeLevel {

            activeLevel = newLevel

            litCards.removeAll()
            targetDeadline = nil

            nextTargetTime = now.addingTimeInterval(0.5)
        }

        // CHECK MISSED CARDS

        if !litCards.isEmpty {

            if let deadline = targetDeadline,
               now >= deadline {

                loseLife(at: now)
            }

        } else if let nextTime = nextTargetTime,
                  now >= nextTime {

            lightUpCards(at: now)
        }
    }


    // MARK: LEVEL PROGRESSION

    private func levelForElapsed(_ elapsed: TimeInterval) -> Int {

        if elapsed < 15 {
            return 1

        } else if elapsed < 30 {
            return 2

        } else if elapsed < 45 {
            return 3

        } else {
            return 4
        }
    }


    // MARK: LIGHT UP RANDOM CARDS

    private func lightUpCards(at now: Date) {

        var selectedCards: Set<Int> = []

        // LEVEL 4 LIGHTS UP TWO CARDS

        let numberToLight = activeLevel == 4 ? 2 : 1

        while selectedCards.count < numberToLight {

            let randomIndex = Int.random(
                in: 0..<numberOfCards
            )

            selectedCards.insert(randomIndex)
        }

        litCards = selectedCards

        targetDeadline = now.addingTimeInterval(litWindow)

        nextTargetTime = nil
    }


    // MARK: LOSE LIFE

    private func loseLife(at now: Date) {

        lives = max(0, lives - 1)

        litCards.removeAll()

        targetDeadline = nil

        if lives == 0 {

            // ALL LIVES LOST = GAME OVER

            finishRound(won: false)

        } else {

            nextTargetTime = now.addingTimeInterval(0.45)
        }
    }


    // MARK: FINISH ROUND

    private func finishRound(won: Bool) {

        isPlaying = false
        gameOver = true

        didWin = won

        litCards.removeAll()

        targetDeadline = nil
        nextTargetTime = nil

        // UPDATE BEST SCORE

        if score > bestScore {
            bestScore = score
        }
    }


    // MARK: PLAY AGAIN

    private func resetRound() {

        score = 0
        timeLeft = roundDuration
        lives = 3

        activeLevel = 1

        isPlaying = false
        gameOver = false
        didWin = false

        roundStartTime = nil
        nextTargetTime = nil
        targetDeadline = nil

        litCards.removeAll()
        feedbackCard = nil
    }
}
