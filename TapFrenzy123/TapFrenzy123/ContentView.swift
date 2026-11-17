
import SwiftUI

// MARK: - HOME SCREEN

struct ContentView: View {

    var body: some View {

        NavigationStack {

            ZStack {

                Color.black.ignoresSafeArea()

                VStack(spacing: 30) {

                    Spacer()

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 65))
                        .foregroundColor(.cyan)

                    Text("MY GAME")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    Text("Choose your game mode")
                        .font(.title3)
                        .foregroundColor(.gray)

                    Spacer()

                    NavigationLink {
                        TapFrenzyView()
                    } label: {

                        modeButton(
                            title: "TAP FRENZY",
                            subtitle: "Tap as fast as you can",
                            symbol: "hand.tap.fill",
                            tint: .cyan
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        LightItUpView()
                    } label: {

                        modeButton(
                            title: "LIGHT IT UP",
                            subtitle: "Find and tap the glowing cards",
                            symbol: "bolt.fill",
                            tint: .orange
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Select a mode to play")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    // HOME BUTTON DESIGN

    private func modeButton(
        title: String,
        subtitle: String,
        symbol: String,
        tint: Color
    ) -> some View {

        HStack(spacing: 16) {

            Image(systemName: symbol)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 60, height: 60)
                .background(tint.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 15))

            VStack(alignment: .leading, spacing: 6) {

                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(tint.opacity(0.4), lineWidth: 1)
        }
    }
}

// MARK: - PREVIEW

#Preview {
    ContentView()
}
