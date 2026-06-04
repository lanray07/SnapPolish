import Foundation

struct TemplateCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let route: StudioRoute
}

struct BrandPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let colors: [String]
    let font: String
}

enum TemplateLibrary {
    static let categories: [TemplateCategory] = [
        TemplateCategory(title: "SaaS Launch", subtitle: "Product pages, feature cards, founder posts", route: .social),
        TemplateCategory(title: "AI Startup", subtitle: "Neon mockups, launch visuals, App Store sets", route: .appStore),
        TemplateCategory(title: "Creator Kit", subtitle: "Carousel posts, story frames, captions", route: .carousel),
        TemplateCategory(title: "Ecommerce", subtitle: "Product screenshots and polished showcase tiles", route: .mockups),
        TemplateCategory(title: "Agency Client", subtitle: "White-label exports and premium brand frames", route: .templates),
        TemplateCategory(title: "Mobile Apps", subtitle: "App Store screenshots and onboarding showcases", route: .appStore)
    ]

    static let brandPresets: [BrandPreset] = [
        BrandPreset(name: "Electric Noir", colors: ["#030712", "#7C3AED", "#22D3EE"], font: "SF Pro Display"),
        BrandPreset(name: "Launch Signal", colors: ["#0F172A", "#F43F5E", "#FBBF24"], font: "New York"),
        BrandPreset(name: "Studio Mint", colors: ["#111827", "#10B981", "#E5E7EB"], font: "Avenir Next")
    ]
}
