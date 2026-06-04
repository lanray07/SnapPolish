import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
                    .withStudioDestinations()
            }
            .tabItem { AppTab.dashboard.label }
            .tag(AppTab.dashboard)

            NavigationStack {
                StudioHomeView()
                    .withStudioDestinations()
            }
            .tabItem { AppTab.studio.label }
            .tag(AppTab.studio)

            NavigationStack {
                BrandKitView()
                    .withStudioDestinations()
            }
            .tabItem { AppTab.brand.label }
            .tag(AppTab.brand)

            NavigationStack {
                ExportCenterView()
                    .withStudioDestinations()
            }
            .tabItem { AppTab.exports.label }
            .tag(AppTab.exports)

            NavigationStack {
                SettingsView()
                    .withStudioDestinations()
            }
            .tabItem { AppTab.settings.label }
            .tag(AppTab.settings)
        }
        .tint(.cyan)
    }
}

extension View {
    func withStudioDestinations() -> some View {
        navigationDestination(for: StudioRoute.self) { route in
            StudioDestinationView(route: route)
        }
    }
}

struct StudioDestinationView: View {
    let route: StudioRoute

    var body: some View {
        switch route {
        case .importScreenshots:
            ScreenshotImportView()
        case .polish:
            PolishEngineView()
        case .glowUp:
            GlowUpView()
        case .mockups:
            DeviceMockupGeneratorView()
        case .social:
            SocialMediaGeneratorView()
        case .headlines:
            HeadlineGeneratorView()
        case .carousel:
            CarouselBuilderView()
        case .appStore:
            AppStoreBuilderView()
        case .templates:
            TemplateMarketplaceView()
        case .analytics:
            AnalyticsDashboardView()
        case .widgets:
            WidgetsPlaceholderView()
        case .paywall:
            PaywallView()
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(SubscriptionStore())
        .environmentObject(VoiceInputService())
}
