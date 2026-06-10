import StoreKit
import SwiftData
import SwiftUI

struct BrandKitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedBrandKits: [BrandKit]
    @StateObject private var viewModel = BrandKitViewModel()

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Brand Kit",
                        subtitle: "Store colors, logo marks, font choices, and export preferences."
                    )

                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            TextField("Brand name", text: $viewModel.brandName)
                                .textFieldStyle(.plain)
                                .font(.title3.bold())
                                .padding(14)
                                .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                            GradientPicker(colors: $viewModel.colors)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Font")
                                    .font(.headline)
                                Text(viewModel.selectedFont)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            PremiumButton(title: "Save brand kit", systemImage: "checkmark.seal") {
                                saveBrandKit()
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Presets")
                            .font(.headline)
                        ForEach(TemplateLibrary.brandPresets) { preset in
                            Button {
                                viewModel.applyPreset(preset)
                            } label: {
                                HStack(spacing: 14) {
                                    HStack(spacing: -8) {
                                        ForEach(preset.colors, id: \.self) { hex in
                                            Circle()
                                                .fill(Color(hex: hex) ?? .white)
                                                .frame(width: 34, height: 34)
                                                .overlay(Circle().stroke(.black.opacity(0.35), lineWidth: 1))
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preset.name)
                                            .font(.headline)
                                        Text(preset.font)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let latest = savedBrandKits.first {
                        GlassCard {
                            Label("Saved kit: \(latest.logoPlaceholder)", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Brand")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveBrandKit() {
        let kit = BrandKit(
            colors: viewModel.colors,
            logoPlaceholder: viewModel.brandName,
            fontPlaceholder: viewModel.selectedFont,
            exportPreferences: viewModel.exportPreference
        )
        modelContext.insert(kit)
        try? modelContext.save()
    }
}

struct ExportCenterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExportRecord.createdAt, order: .reverse) private var exports: [ExportRecord]

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Export Center",
                        subtitle: "Export PNG, JPG, PDF, App Store sizes, and social media presets."
                    )

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                        ForEach(ExportPresetLibrary.presets) { preset in
                            Button {
                                createExport(preset)
                            } label: {
                                QuickActionTile(
                                    title: preset.name,
                                    subtitle: preset.sizeLabel,
                                    systemImage: "arrow.down.doc",
                                    tint: .cyan
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export history")
                            .font(.headline)

                        if exports.isEmpty {
                            GlassCard {
                                Label("No exports yet", systemImage: "tray")
                                    .font(.headline)
                            }
                        } else {
                            ForEach(exports) { record in
                                ExportCard(format: record.format, size: record.size, createdAt: record.createdAt)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Exports")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func createExport(_ preset: ExportPreset) {
        modelContext.insert(ExportRecord(format: preset.format, size: preset.sizeLabel))
        try? modelContext.save()
    }
}

struct AnalyticsDashboardView: View {
    @Query private var projects: [Project]
    @Query private var exports: [ExportRecord]
    @Query private var brandKits: [BrandKit]

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Analytics",
                        subtitle: "Track exports created, templates used, project volume, and design activity."
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricPill(title: "Exports", value: "\(exports.count)", systemImage: "square.and.arrow.up")
                        MetricPill(title: "Projects", value: "\(projects.count)", systemImage: "folder")
                        MetricPill(title: "Templates", value: "\(TemplateLibrary.categories.count)", systemImage: "rectangle.stack")
                        MetricPill(title: "Brand kits", value: "\(brandKits.count)", systemImage: "swatchpalette")
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Design activity", systemImage: "chart.xyaxis.line")
                                .font(.headline)
                            ForEach(0..<5) { index in
                                HStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(LinearGradient(colors: [.purple, .cyan], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: CGFloat(90 + index * 30), height: 12)
                                    Spacer()
                                    Text(["Mon", "Tue", "Wed", "Thu", "Fri"][index])
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WidgetsPlaceholderView: View {
    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Widgets",
                        subtitle: "Recent project, quick polish, inspiration quote, and export shortcuts."
                    )

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 14)], spacing: 14) {
                        QuickActionTile(title: "Recent Project", subtitle: "Home Screen widget", systemImage: "clock", tint: .cyan)
                        QuickActionTile(title: "Quick Polish", subtitle: "One tap shortcut", systemImage: "wand.and.stars", tint: .purple)
                        QuickActionTile(title: "Inspiration", subtitle: "Creator prompt", systemImage: "quote.bubble", tint: .yellow)
                        QuickActionTile(title: "Export Shortcut", subtitle: "Share instantly", systemImage: "square.and.arrow.up", tint: .mint)
                    }

                    GlassCard {
                        Label("Apple Watch companion: export notifications and workflow reminders.", systemImage: "applewatch")
                            .font(.headline)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Widgets")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PaywallView: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Creator Pro",
                        subtitle: "Unlimited exports, premium templates, AI headlines, App Store builder, and social presets."
                    )

                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            planRow("Free", "Limited exports, basic templates, watermark", "GBP 0")
                            planRow("Creator Pro Monthly", "Unlimited exports and AI generation", "GBP 9.99")
                            planRow("Creator Pro Yearly", "Best value for solo creators", "GBP 79.99")
                            planRow("Agency Monthly", "Brand kits, batch exports, white-label workflows", "GBP 29.99")
                        }
                    }

                    if subscriptionStore.isLoadingProducts {
                        ProgressView()
                            .tint(.cyan)
                            .frame(maxWidth: .infinity, minHeight: 54)
                    } else if subscriptionStore.products.isEmpty {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Subscriptions unavailable", systemImage: "exclamationmark.triangle")
                                    .font(.headline)
                                Text("Please try again in a moment.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                PremiumButton(title: "Retry", systemImage: "arrow.clockwise") {
                                    Task { await subscriptionStore.reloadProducts() }
                                }
                            }
                        }
                    } else {
                        ForEach(subscriptionStore.sortedProducts) { product in
                            Button {
                                Task { await subscriptionStore.purchase(product) }
                            } label: {
                                HStack {
                                    Text(product.displayName)
                                        .font(.headline)
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.headline)
                                }
                                .padding(16)
                                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    PremiumButton(
                        title: subscriptionStore.isRestoringPurchases ? "Restoring" : "Restore purchases",
                        systemImage: "arrow.triangle.2.circlepath",
                        isLoading: subscriptionStore.isRestoringPurchases
                    ) {
                        Task { await subscriptionStore.restorePurchases() }
                    }

                    if let message = subscriptionStore.purchaseMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await subscriptionStore.loadProducts()
        }
    }

    private func planRow(_ title: String, _ detail: String, _ price: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: title == "Free" ? "circle" : "checkmark.circle.fill")
                .foregroundStyle(title == "Free" ? Color.secondary : Color.cyan)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(price)
                .font(.subheadline.weight(.bold))
        }
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionStore: SubscriptionStore

    @Query private var projects: [Project]
    @Query private var screenshots: [ScreenshotAsset]
    @Query private var variations: [DesignVariation]
    @Query private var brandKits: [BrandKit]
    @Query private var exports: [ExportRecord]
    @Query private var states: [SubscriptionState]

    @State private var theme = "Dark"
    @State private var exportQuality = "High"

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    screenHeader(
                        title: "Settings",
                        subtitle: "Subscription, export settings, design preferences, privacy, and data controls."
                    )

                    GlassCard {
                        VStack(spacing: 16) {
                            settingsRow("Subscription", subscriptionStore.plan.label, "crown")
                            settingsRow("Export quality", exportQuality, "slider.horizontal.3")
                            settingsRow("Theme", theme, "moon.stars")
                            settingsRow("AI previews", "Enabled", "cpu")
                        }
                    }

                    NavigationLink(value: StudioRoute.paywall) {
                        UpgradeBanner(title: "Manage subscription", subtitle: "Free, Creator Pro, and Agency plans")
                    }
                    .buttonStyle(.plain)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Legal", systemImage: "doc.text")
                                .font(.headline)
                            Text("Privacy policy and terms of use are ready for review.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button(role: .destructive) {
                        deleteAllProjects()
                    } label: {
                        Label("Delete all projects", systemImage: "trash")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(.red.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func settingsRow(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(.cyan)
                .frame(width: 34)
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func deleteAllProjects() {
        projects.forEach { modelContext.delete($0) }
        screenshots.forEach { modelContext.delete($0) }
        variations.forEach { modelContext.delete($0) }
        brandKits.forEach { modelContext.delete($0) }
        exports.forEach { modelContext.delete($0) }
        states.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }
}
