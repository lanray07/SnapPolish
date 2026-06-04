import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct ScreenshotImportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var status = "Ready to import screenshots"

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Screenshot Import",
                        subtitle: "Bring in app screens, web captures, dashboards, or social posts."
                    )

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        GlassCard {
                            VStack(spacing: 18) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.cyan)
                                Text("Choose from Photo Library")
                                    .font(.title3.weight(.bold))
                                Text(status)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 220)
                        }
                    }
                    .buttonStyle(.plain)

                    if imageData != nil {
                        ScreenshotCard(data: imageData, title: "Imported screenshot")
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        placeholderTile("Camera Roll", "photo.stack", "Native picker")
                        placeholderTile("Drag and Drop", "rectangle.and.hand.point.up.left", "iPad placeholder")
                        placeholderTile("Batch Upload", "square.stack.3d.up", "Coming soon")
                        placeholderTile("Web Capture", "globe", "Capture placeholder")
                    }
                }
                .padding(20)
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else {
                    status = "Could not read that image."
                    return
                }

                imageData = data
                status = "Screenshot imported and stored offline."
                modelContext.insert(ScreenshotAsset(imageData: data))
                modelContext.insert(Project(title: "Screenshot polish", screenshotCount: 1, thumbnailData: data))
                try? modelContext.save()
            }
        }
    }
}

struct PolishEngineView: View {
    @StateObject private var viewModel = PolishStudioViewModel()

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "AI Screenshot Polish",
                        subtitle: "Generate premium visual directions with mock AI enabled by default."
                    )

                    stylePicker(selection: $viewModel.selectedStyle)

                    PremiumButton(
                        title: viewModel.isGenerating ? "Generating..." : "Generate variations",
                        systemImage: "wand.and.stars",
                        isLoading: viewModel.isGenerating
                    ) {
                        Task { await viewModel.generate() }
                    }

                    if viewModel.variations.isEmpty {
                        BeforeAfterSlider()
                    } else {
                        ForEach(viewModel.variations) { variation in
                            DesignVariationCard(variation: variation)
                        }
                    }

                    suggestions(for: viewModel.selectedStyle)
                }
                .padding(20)
            }
            .navigationTitle("Polish")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GlowUpView: View {
    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "One Tap Glow-Up",
                        subtitle: "A viral before and after preview for sharing the transformation."
                    )
                    BeforeAfterSlider()
                    PremiumButton(title: "Create glow-up", systemImage: "sparkles") {}
                    GlassCard {
                        Label("Exports as a shareable before and after asset.", systemImage: "square.and.arrow.up")
                            .font(.headline)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Glow-Up")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DeviceMockupGeneratorView: View {
    @StateObject private var viewModel = MockupViewModel()

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Device Mockups",
                        subtitle: "Wrap screenshots in polished devices with reflections, depth, and glow."
                    )

                    Picker("Device", selection: $viewModel.selectedFrame) {
                        ForEach(DeviceFrame.allCases) { frame in
                            Text(frame.label).tag(frame)
                        }
                    }
                    .pickerStyle(.segmented)

                    DeviceMockupView(frame: viewModel.selectedFrame)
                        .padding(.horizontal, 24)

                    PremiumButton(
                        title: viewModel.isGenerating ? "Generating..." : "Generate mockup set",
                        systemImage: "macbook.and.iphone",
                        isLoading: viewModel.isGenerating
                    ) {
                        Task { await viewModel.generate() }
                    }

                    ForEach(viewModel.mockups) { mockup in
                        DesignVariationCard(variation: mockup)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Mockups")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SocialMediaGeneratorView: View {
    @StateObject private var viewModel = SocialContentViewModel()

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "AI Social Generator",
                        subtitle: "Create X, LinkedIn, Instagram, Threads, and Pinterest visuals."
                    )

                    VoicePromptComposer(
                        text: $viewModel.prompt,
                        title: "Launch prompt",
                        placeholder: "Say or type the product, feature, audience, and tone..."
                    )

                    Picker("Platform", selection: $viewModel.selectedPlatform) {
                        ForEach(SocialPlatform.allCases) { platform in
                            Text(platform.label).tag(platform)
                        }
                    }
                    .pickerStyle(.segmented)

                    PremiumButton(
                        title: viewModel.isGenerating ? "Generating..." : "Generate social assets",
                        systemImage: "megaphone",
                        isLoading: viewModel.isGenerating
                    ) {
                        Task { await viewModel.generate() }
                    }

                    ForEach(viewModel.assets) { asset in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label(asset.platform.label, systemImage: "sparkles")
                                        .font(.headline)
                                    Spacer()
                                    Text(asset.outputSize)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(asset.title)
                                    .font(.title3.bold())
                                Text(asset.caption)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Social")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HeadlineGeneratorView: View {
    @StateObject private var viewModel = HeadlineGeneratorViewModel()

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "AI Headlines",
                        subtitle: "Dictate rough ideas and turn them into premium launch copy."
                    )

                    VoicePromptComposer(
                        text: $viewModel.prompt,
                        title: "Headline brief",
                        placeholder: "Describe the screenshot, feature, audience, or launch moment..."
                    )

                    PremiumButton(
                        title: viewModel.isGenerating ? "Generating..." : "Generate headlines",
                        systemImage: "text.quote",
                        isLoading: viewModel.isGenerating
                    ) {
                        Task { await viewModel.generate() }
                    }

                    ForEach(viewModel.headlines, id: \.self) { headline in
                        HStack(spacing: 12) {
                            Text(headline)
                                .font(.headline)
                            Spacer()
                            Button {
                                UIPasteboard.general.string = headline
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundStyle(.cyan)
                            }
                            .accessibilityLabel("Copy headline")
                        }
                        .padding(16)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
                .padding(20)
            }
            .navigationTitle("Headlines")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CarouselBuilderView: View {
    @StateObject private var viewModel = CarouselBuilderViewModel()

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Carousel Builder",
                        subtitle: "Generate educational slides, feature showcases, and product walkthroughs."
                    )

                    VoicePromptComposer(
                        text: $viewModel.prompt,
                        title: "Carousel idea",
                        placeholder: "Dictate a product walkthrough, teaching angle, or launch story..."
                    )

                    PremiumButton(
                        title: viewModel.isGenerating ? "Generating..." : "Generate carousel",
                        systemImage: "rectangle.stack",
                        isLoading: viewModel.isGenerating
                    ) {
                        Task { await viewModel.generate() }
                    }

                    ForEach(viewModel.slides) { slide in
                        GlassCard {
                            HStack(alignment: .top, spacing: 14) {
                                Text("\(slide.index)")
                                    .font(.title.bold())
                                    .foregroundStyle(.cyan)
                                    .frame(width: 42)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(slide.heading)
                                        .font(.headline)
                                    Text(slide.layout)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(slide.note)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Carousel")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AppStoreBuilderView: View {
    private let templates = ["Productivity", "Finance", "AI", "Gaming", "Health", "Ecommerce"]

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "App Store Builder",
                        subtitle: "Create screenshot sets with feature callouts, onboarding showcases, and comparisons."
                    )

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                        ForEach(templates, id: \.self) { template in
                            QuickActionTile(
                                title: template,
                                subtitle: "Screenshot set",
                                systemImage: "app.badge",
                                tint: .cyan
                            )
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("App Store export sizes", systemImage: "iphone")
                                .font(.headline)
                            Text("6.7-inch, 6.5-inch, iPad, and localized set placeholders are ready for the export pipeline.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("App Store")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TemplateMarketplaceView: View {
    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Template Marketplace",
                        subtitle: "Premium template categories for SaaS, AI startups, creators, ecommerce, and agencies."
                    )

                    ForEach(TemplateLibrary.categories) { category in
                        NavigationLink(value: category.route) {
                            HStack(spacing: 14) {
                                Image(systemName: "storefront")
                                    .foregroundStyle(.cyan)
                                    .frame(width: 44, height: 44)
                                    .background(.cyan.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.title)
                                        .font(.headline)
                                    Text(category.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

@ViewBuilder
func screenHeader(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.system(size: 32, weight: .bold, design: .rounded))
        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

private func placeholderTile(_ title: String, _ icon: String, _ subtitle: String) -> some View {
    GlassCard(padding: 14) {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.cyan)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private func stylePicker(selection: Binding<PolishStyle>) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
            ForEach(PolishStyle.allCases) { style in
                Button {
                    selection.wrappedValue = style
                } label: {
                    Text(style.label)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .foregroundStyle(.white)
                        .background(
                            selection.wrappedValue == style ? .cyan.opacity(0.24) : .white.opacity(0.08),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private func suggestions(for style: PolishStyle) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        Text("Composition")
            .font(.headline)
        ForEach(DesignEngine.suggestions(for: style)) { suggestion in
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.mint)
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(.subheadline.weight(.semibold))
                    Text(suggestion.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
