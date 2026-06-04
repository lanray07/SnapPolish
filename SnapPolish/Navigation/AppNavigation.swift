import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case studio
    case brand
    case exports
    case settings

    var id: String { rawValue }

    @ViewBuilder
    var label: some View {
        switch self {
        case .dashboard:
            Label("Today", systemImage: "sparkles")
        case .studio:
            Label("Studio", systemImage: "wand.and.stars")
        case .brand:
            Label("Brand", systemImage: "swatchpalette")
        case .exports:
            Label("Exports", systemImage: "square.and.arrow.up")
        case .settings:
            Label("Settings", systemImage: "gearshape")
        }
    }
}

enum StudioRoute: Hashable {
    case importScreenshots
    case polish
    case glowUp
    case mockups
    case social
    case headlines
    case carousel
    case appStore
    case templates
    case analytics
    case widgets
    case paywall
}
