import SwiftUI
import UIKit

struct PremiumBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.03, blue: 0.08),
                    Color(red: 0.12, green: 0.05, blue: 0.22),
                    Color(red: 0.01, green: 0.02, blue: 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            content
        }
    }
}

struct GlassCard<Content: View>: View {
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 18)
    }
}

struct PremiumButton: View {
    let title: String
    let systemImage: String
    var isLoading = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(
                LinearGradient(colors: [.purple, .cyan], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}

struct MetricPill: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(.cyan)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct QuickActionTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var tint: Color = .cyan

    var body: some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ProjectCard: View {
    let title: String
    let count: Int
    let createdAt: Date
    var thumbnailData: Data?

    var body: some View {
        HStack(spacing: 14) {
            ScreenshotThumb(data: thumbnailData)
                .frame(width: 66, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(count) screenshots")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct ScreenshotThumb: View {
    var data: Data?

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(colors: [.purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.85))
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        )
    }
}

struct ScreenshotCard: View {
    var data: Data?
    var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScreenshotThumb(data: data)
                .aspectRatio(0.72, contentMode: .fit)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct DesignVariationCard: View {
    let variation: DesignVariationPreview

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: variation.palette.compactMap(Color.init(hex:)),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 150)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.largeTitle)
                        Text(variation.style.label)
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(variation.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(variation.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct DeviceMockupView: View {
    var frame: DeviceFrame

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: frame == .appleWatch ? 38 : 28, style: .continuous)
                .fill(.black)
                .shadow(color: .cyan.opacity(0.35), radius: 28, x: 0, y: 18)

            RoundedRectangle(cornerRadius: frame == .appleWatch ? 30 : 20, style: .continuous)
                .fill(
                    LinearGradient(colors: [.purple.opacity(0.9), .cyan.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .padding(frame == .browserWindow ? 22 : 10)
                .overlay {
                    VStack(spacing: 10) {
                        Image(systemName: symbol)
                            .font(.largeTitle)
                        Text(frame.label)
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .accessibilityLabel("\(frame.label) mockup")
    }

    private var symbol: String {
        switch frame {
        case .iPhone: "iphone"
        case .iPad: "ipad"
        case .macBook: "laptopcomputer"
        case .desktop: "desktopcomputer"
        case .browserWindow: "macwindow"
        case .appleWatch: "applewatch"
        }
    }

    private var aspectRatio: CGFloat {
        switch frame {
        case .iPhone: 0.52
        case .iPad: 0.76
        case .macBook, .desktop, .browserWindow: 1.45
        case .appleWatch: 0.78
        }
    }
}

struct ExportCard: View {
    let format: ExportFormat
    let size: String
    let createdAt: Date

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "arrow.down.doc.fill")
                .font(.title3)
                .foregroundStyle(.cyan)
                .frame(width: 42, height: 42)
                .background(.cyan.opacity(0.16), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(format.label)
                    .font(.headline)
                Text(size)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Text(createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct GradientPicker: View {
    @Binding var colors: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brand colors")
                .font(.headline)
            HStack {
                ForEach(colors, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex) ?? .white)
                        .frame(width: 42, height: 42)
                        .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                }
                Spacer()
            }
        }
    }
}

struct BeforeAfterSlider: View {
    @State private var progress: CGFloat = 0.55

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                assetPreview(title: "After", colors: [.purple, .cyan])
                assetPreview(title: "Before", colors: [.gray.opacity(0.9), .black])
                    .frame(width: geometry.size.width * progress)
                    .clipped()

                Rectangle()
                    .fill(.white)
                    .frame(width: 3)
                    .offset(x: geometry.size.width * progress)

                Circle()
                    .fill(.white)
                    .frame(width: 38, height: 38)
                    .overlay(Image(systemName: "arrow.left.and.right").font(.caption).foregroundStyle(.black))
                    .offset(x: geometry.size.width * progress - 19)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        progress = min(max(value.location.x / max(geometry.size.width, 1), 0.05), 0.95)
                    }
            )
        }
        .frame(height: 360)
        .accessibilityLabel("Before and after transformation slider")
    }

    private func assetPreview(title: String, colors: [Color]) -> some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                VStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.18))
                        .frame(width: 160, height: 210)
                        .overlay {
                            VStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.35)).frame(height: 18)
                                RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.18)).frame(height: 74)
                                RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.25)).frame(height: 28)
                            }
                            .padding(22)
                        }
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
    }
}

struct VoicePromptComposer: View {
    @EnvironmentObject private var voiceInput: VoiceInputService
    @Binding var text: String

    let title: String
    let placeholder: String

    @State private var baseTextBeforeRecording = ""

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(title, systemImage: "text.bubble")
                        .font(.headline)
                    Spacer()
                    Button {
                        toggleRecording()
                    } label: {
                        Image(systemName: voiceInput.isRecording ? "stop.circle.fill" : "mic.fill")
                            .font(.title3)
                            .foregroundStyle(voiceInput.isRecording ? .red : .cyan)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.08), in: Circle())
                    }
                    .accessibilityLabel(voiceInput.isRecording ? "Stop voice input" : "Start voice input")
                }

                TextEditor(text: $text)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 18)
                                .padding(.leading, 16)
                                .allowsHitTesting(false)
                        }
                    }

                HStack(spacing: 8) {
                    Image(systemName: voiceInput.isRecording ? "waveform" : "keyboard")
                    Text(statusText)
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(voiceInput.isRecording ? .cyan : .secondary)
            }
        }
        .onChange(of: voiceInput.transcript) { _, newValue in
            guard voiceInput.isRecording, !newValue.isEmpty else { return }
            text = mergedText(base: baseTextBeforeRecording, transcript: newValue)
        }
    }

    private var statusText: String {
        if voiceInput.isRecording { return "Listening..." }
        if let error = voiceInput.errorMessage { return error }
        return "Type or dictate your prompt."
    }

    private func toggleRecording() {
        if voiceInput.isRecording {
            voiceInput.stopTranscribing()
        } else {
            baseTextBeforeRecording = text.trimmingCharacters(in: .whitespacesAndNewlines)
            voiceInput.resetTranscript()
            Task { await voiceInput.startTranscribing() }
        }
    }

    private func mergedText(base: String, transcript: String) -> String {
        guard !base.isEmpty else { return transcript }
        return "\(base) \(transcript)"
    }
}

struct UpgradeBanner: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [.purple.opacity(0.34), .cyan.opacity(0.16)], startPoint: .leading, endPoint: .trailing),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard let value = UInt64(cleaned, radix: 16) else { return nil }

        let red: Double
        let green: Double
        let blue: Double

        switch cleaned.count {
        case 6:
            red = Double((value & 0xFF0000) >> 16) / 255
            green = Double((value & 0x00FF00) >> 8) / 255
            blue = Double(value & 0x0000FF) / 255
        default:
            return nil
        }

        self.init(red: red, green: green, blue: blue)
    }
}
