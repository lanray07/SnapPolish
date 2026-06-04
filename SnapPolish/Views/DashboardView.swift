import SwiftData
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]
    @StateObject private var viewModel = DashboardViewModel()

    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    metrics
                    quickActions
                    recommendations
                    recentProjects
                    templateStrip
                }
                .padding(20)
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadRecommendations(
                creatorType: profile?.creatorType ?? .creator,
                primaryUse: profile?.primaryUse ?? .socialMedia
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Make it launch-ready")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("Turn screenshots into premium App Store, launch, and social visuals.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(.cyan)
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.08), in: Circle())
            }

            NavigationLink(value: StudioRoute.paywall) {
                UpgradeBanner(
                    title: subscriptionStore.isPro ? subscriptionStore.plan.label : "Creator Pro",
                    subtitle: subscriptionStore.isPro ? "Premium exports active" : "Unlimited exports, AI headlines, App Store builder"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricPill(title: "Projects", value: "\(projects.count)", systemImage: "folder")
            MetricPill(title: "Plan", value: subscriptionStore.plan == .free ? "Free" : "Pro", systemImage: "crown")
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 14)], spacing: 14) {
                actionLink("Polish Screenshot", "Enhance composition", "wand.and.stars", .cyan, .polish)
                actionLink("Create Mockup", "Device frames", "iphone.gen3", .purple, .mockups)
                actionLink("Build Carousel", "Slides and story", "rectangle.stack", .pink, .carousel)
                actionLink("Launch Post", "Social graphics", "megaphone", .orange, .social)
                actionLink("App Store Creator", "Screenshot sets", "app.badge", .mint, .appStore)
                actionLink("Brand Kit", "Colors and style", "swatchpalette", .yellow, .templates)
            }
        }
    }

    private func actionLink(
        _ title: String,
        _ subtitle: String,
        _ icon: String,
        _ tint: Color,
        _ route: StudioRoute
    ) -> some View {
        NavigationLink(value: route) {
            QuickActionTile(title: title, subtitle: subtitle, systemImage: icon, tint: tint)
        }
        .buttonStyle(.plain)
    }

    private var recommendations: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI recommendations")
                .font(.headline)

            if viewModel.isLoadingRecommendations {
                ProgressView()
                    .tint(.cyan)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                ForEach(viewModel.recommendations) { recommendation in
                    NavigationLink(value: recommendation.route) {
                        HStack(spacing: 14) {
                            Image(systemName: "sparkle")
                                .foregroundStyle(.cyan)
                                .frame(width: 38, height: 38)
                                .background(.cyan.opacity(0.12), in: Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recommendation.title)
                                    .font(.headline)
                                Text(recommendation.detail)
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
        }
    }

    private var recentProjects: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent projects")
                .font(.headline)

            if projects.isEmpty {
                ProjectCard(title: "First launch asset", count: 0, createdAt: .now, thumbnailData: nil)
                    .overlay(alignment: .topTrailing) {
                        Text("Start")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.cyan.opacity(0.2), in: Capsule())
                            .padding(12)
                    }
            } else {
                ForEach(projects.prefix(4)) { project in
                    ProjectCard(
                        title: project.title,
                        count: project.screenshotCount,
                        createdAt: project.createdAt,
                        thumbnailData: project.thumbnailData
                    )
                }
            }
        }
    }

    private var templateStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular templates")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(TemplateLibrary.categories) { category in
                        NavigationLink(value: category.route) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(category.title)
                                    .font(.headline)
                                Text(category.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.cyan)
                            }
                            .frame(width: 190, height: 126, alignment: .leading)
                            .padding(16)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct StudioHomeView: View {
    private let sections: [(title: String, subtitle: String, icon: String, route: StudioRoute, color: Color)] = [
        ("Screenshot Import", "Photo library, camera roll, batch placeholder", "photo.on.rectangle", .importScreenshots, .cyan),
        ("AI Screenshot Polish", "Minimal, Apple, Startup, SaaS, Neon", "wand.and.stars", .polish, .purple),
        ("One Tap Glow-Up", "Before and after transformation", "slider.horizontal.below.rectangle", .glowUp, .pink),
        ("Device Mockups", "iPhone, iPad, MacBook, browser, watch", "macbook.and.iphone", .mockups, .mint),
        ("AI Social Generator", "X, LinkedIn, Instagram, Threads", "megaphone", .social, .orange),
        ("AI Headlines", "Voice-enabled prompt generation", "text.quote", .headlines, .yellow),
        ("Carousel Builder", "Educational slides and walkthroughs", "rectangle.stack", .carousel, .blue),
        ("App Store Builder", "Feature callouts and screenshot sets", "app.badge", .green),
        ("Marketplace", "Premium template placeholder", "storefront", .templates, .purple),
        ("Analytics", "Exports, templates, activity", "chart.xyaxis.line", .analytics, .cyan),
        ("Widgets", "Recent project and quick polish", "square.grid.2x2", .widgets, .pink)
    ]

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Studio")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        Text("Create launch visuals, mockups, social graphics, and App Store assets.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 14)], spacing: 14) {
                        ForEach(sections, id: \.title) { section in
                            NavigationLink(value: section.route) {
                                QuickActionTile(
                                    title: section.title,
                                    subtitle: section.subtitle,
                                    systemImage: section.icon,
                                    tint: section.color
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Studio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
