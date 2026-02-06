import SwiftUI
import Combine

struct SlotMachineAnimationView: View {
    @State private var spin = false

    // Example slot icons; you can customize with album covers or other images
    let slotIcons = [
        "music.note",
        "guitars",
        "headphones",
        "music.mic",
        "star.fill",
        "play.fill"
    ]

    @State private var firstIndex = 0
    @State private var secondIndex = 1
    @State private var thirdIndex = 2

    @State private var firstOffsetY: CGFloat = 0
    @State private var secondOffsetY: CGFloat = 0
    @State private var thirdOffsetY: CGFloat = 0

    @State private var isSpinning = false
    @State private var spinTimer: Timer?

    var body: some View {
        ZStack {
            // Blurred background overlay
            Color.black.opacity(0.45).ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 40) {
                Text("Revealing your song…")
                    .font(.title2)
                    .padding(.top, 40)
                    .foregroundStyle(.white)

                ZStack(alignment: .top) {
                    // Machine body with vibrant red fill, thick playful gold gradient border, shadow
                    RoundedRectangle(cornerRadius: 38)
                        .fill(Color(red: 0.85, green: 0.08, blue: 0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 38)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange, Color(white: 0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 8
                                )
                        )
                        .shadow(color: Color(red: 0.6, green: 0.1, blue: 0.1).opacity(0.8), radius: 14, x: 0, y: 8)
                        .frame(width: 340, height: 240)

                    // Semicircular arch on top with bulbs
                    ZStack {
                        // The red arch with gold stroke
                        Capsule()
                            .fill(Color(red: 0.85, green: 0.08, blue: 0.18))
                            .frame(width: 280, height: 80)
                            .offset(y: -36)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.yellow, Color.orange, Color(white: 0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 8
                                    )
                            )
                            .shadow(color: Color(red: 0.6, green: 0.1, blue: 0.1).opacity(0.7), radius: 8, x: 0, y: 4)

                        // Bulbs spaced along the arch with gold/yellow gradient
                        HStack(spacing: 20) {
                            ForEach(0..<9) { _ in
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.8, green: 0.7, blue: 0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom))
                                    .frame(width: 18, height: 18)
                                    .shadow(color: Color(red: 1, green: 0.85, blue: 0.3).opacity(0.9), radius: 3, x: 0, y: 0)
                            }
                        }
                        .frame(width: 260)
                        .offset(y: -36)
                    }

                    VStack(spacing: 28) {
                        // Light indicator at top with stronger red gradient fill and gold border
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.85, green: 0.08, blue: 0.18), Color(red: 0.6, green: 0.05, blue: 0.12)]),
                                startPoint: .top,
                                endPoint: .bottom))
                            .frame(width: 22, height: 22)
                            .overlay(
                                Circle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 8, height: 8)
                                    .offset(x: -5, y: -5)
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.yellow, Color.orange, Color(white: 0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: Color(red: 0.85, green: 0.08, blue: 0.18).opacity(0.7), radius: 5, x: 0, y: 0)

                        // Slot window background with thick cartoonish gold border and red fill
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.85, green: 0.08, blue: 0.18))
                            .frame(width: 312, height: 110)
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.yellow, Color.orange, Color(white: 0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 10
                                    )
                                    .blendMode(.normal)
                            )
                            .overlay(
                                HStack(spacing: 24) {
                                    // Each slot reel with cartoon style drum background and icon
                                    slotReelView(iconName: slotIcons[firstIndex], offsetY: firstOffsetY, color: .green)
                                    slotReelView(iconName: slotIcons[secondIndex], offsetY: secondOffsetY, color: .yellow)
                                    slotReelView(iconName: slotIcons[thirdIndex], offsetY: thirdOffsetY, color: .blue)
                                }
                                .padding(.horizontal, 12)
                            )
                    }
                    .frame(width: 312, height: 160)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: 340, maxHeight: 240)
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
            }
            .frame(maxWidth: 340, maxHeight: 300)
            .onAppear {
                startSpinning()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: spin)
    }

    @ViewBuilder
    func slotReelView(iconName: String, offsetY: CGFloat, color: Color) -> some View {
        ZStack {
            // Drum background behind each icon - capsule with vibrant red fill and thick gold border, shadow
            Capsule()
                .fill(Color(red: 0.85, green: 0.08, blue: 0.18))
                .frame(width: 92, height: 92)
                .shadow(color: Color(red: 0.6, green: 0.1, blue: 0.1).opacity(0.7), radius: 6, x: 0, y: 3)
                .overlay(
                    Capsule()
                        .stroke(Color(red: 1, green: 0.8, blue: 0.2), lineWidth: 5)
                )

            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color(red: 0.75, green: 0.6, blue: 0.15).opacity(0.7), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 1, green: 0.9, blue: 0.5), lineWidth: 2)
                )
                .foregroundStyle(color)
                .offset(y: offsetY)
        }
        .frame(width: 92, height: 92)
    }

    func startSpinning() {
        isSpinning = true

        // Spin animation runs for exactly 1.5 seconds (1500 ms)
        spinTimer?.invalidate()
        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            spinSlots()
        }

        // Stop spinning after 1.5 seconds - invalidate timer and reset offsets smoothly to zero
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            spinTimer?.invalidate()
            spinTimer = nil
            withAnimation(.easeOut(duration: 0.3)) {
                firstOffsetY = 0
                secondOffsetY = 0
                thirdOffsetY = 0
            }
            isSpinning = false
        }
    }

    func spinSlots() {
        // Cycle through the slot icons for a spinning effect
        firstIndex = (firstIndex + Int.random(in: 1...2)) % slotIcons.count
        secondIndex = (secondIndex + Int.random(in: 1...2)) % slotIcons.count
        thirdIndex = (thirdIndex + Int.random(in: 1...2)) % slotIcons.count

        // Animate vertical offsets with randomness to simulate reel motion
        withAnimation(.easeInOut(duration: 0.07)) {
            firstOffsetY = CGFloat.random(in: -6...6)
            secondOffsetY = CGFloat.random(in: -6...6)
            thirdOffsetY = CGFloat.random(in: -6...6)
        }
    }
}

#Preview {
    SlotMachineAnimationView()
}

