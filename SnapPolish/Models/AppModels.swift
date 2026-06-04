import Foundation
import SwiftData

enum CreatorType: String, CaseIterable, Codable, Identifiable {
    case founder
    case developer
    case creator
    case marketer
    case agency
    case designer

    var id: String { rawValue }

    var label: String {
        switch self {
        case .founder: "Founder"
        case .developer: "Developer"
        case .creator: "Creator"
        case .marketer: "Marketer"
        case .agency: "Agency"
        case .designer: "Designer"
        }
    }
}

enum PrimaryUse: String, CaseIterable, Codable, Identifiable {
    case socialMedia
    case appStore
    case productLaunches
    case websites
    case clientWork
    case ecommerce

    var id: String { rawValue }

    var label: String {
        switch self {
        case .socialMedia: "Social media"
        case .appStore: "App Store"
        case .productLaunches: "Product launches"
        case .websites: "Websites"
        case .clientWork: "Client work"
        case .ecommerce: "Ecommerce"
        }
    }
}

enum PolishStyle: String, CaseIterable, Codable, Identifiable {
    case minimal
    case appleStyle
    case startup
    case saas
    case darkLuxury
    case neon
    case creator
    case productLaunch

    var id: String { rawValue }

    var label: String {
        switch self {
        case .minimal: "Minimal"
        case .appleStyle: "Apple Style"
        case .startup: "Startup"
        case .saas: "SaaS"
        case .darkLuxury: "Dark Luxury"
        case .neon: "Neon"
        case .creator: "Creator"
        case .productLaunch: "Product Launch"
        }
    }
}

enum DeviceFrame: String, CaseIterable, Codable, Identifiable {
    case iPhone
    case iPad
    case macBook
    case desktop
    case browserWindow
    case appleWatch

    var id: String { rawValue }

    var label: String {
        switch self {
        case .iPhone: "iPhone"
        case .iPad: "iPad"
        case .macBook: "MacBook"
        case .desktop: "Desktop"
        case .browserWindow: "Browser"
        case .appleWatch: "Apple Watch"
        }
    }
}

enum SocialPlatform: String, CaseIterable, Codable, Identifiable {
    case x
    case linkedIn
    case instagramPost
    case instagramStory
    case threads
    case pinterest

    var id: String { rawValue }

    var label: String {
        switch self {
        case .x: "X"
        case .linkedIn: "LinkedIn"
        case .instagramPost: "Instagram"
        case .instagramStory: "Story"
        case .threads: "Threads"
        case .pinterest: "Pinterest"
        }
    }
}

enum ExportFormat: String, CaseIterable, Codable, Identifiable {
    case png
    case jpg
    case pdf
    case appStore
    case socialPreset

    var id: String { rawValue }

    var label: String {
        switch self {
        case .png: "PNG"
        case .jpg: "JPG"
        case .pdf: "PDF"
        case .appStore: "App Store"
        case .socialPreset: "Social"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Codable, Identifiable {
    case free
    case creatorProMonthly
    case creatorProYearly
    case agencyMonthly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .free: "Free"
        case .creatorProMonthly: "Creator Pro Monthly"
        case .creatorProYearly: "Creator Pro Yearly"
        case .agencyMonthly: "Agency Monthly"
        }
    }
}

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var creatorTypeRaw: String
    var primaryUseRaw: String
    var createdAt: Date

    init(id: UUID = UUID(), creatorType: CreatorType, primaryUse: PrimaryUse, createdAt: Date = .now) {
        self.id = id
        self.creatorTypeRaw = creatorType.rawValue
        self.primaryUseRaw = primaryUse.rawValue
        self.createdAt = createdAt
    }

    var creatorType: CreatorType {
        CreatorType(rawValue: creatorTypeRaw) ?? .creator
    }

    var primaryUse: PrimaryUse {
        PrimaryUse(rawValue: primaryUseRaw) ?? .socialMedia
    }
}

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var title: String
    var screenshotCount: Int
    var createdAt: Date
    var thumbnailData: Data?

    init(id: UUID = UUID(), title: String, screenshotCount: Int = 0, createdAt: Date = .now, thumbnailData: Data? = nil) {
        self.id = id
        self.title = title
        self.screenshotCount = screenshotCount
        self.createdAt = createdAt
        self.thumbnailData = thumbnailData
    }
}

@Model
final class ScreenshotAsset {
    @Attribute(.unique) var id: UUID
    var imageData: Data
    var createdAt: Date

    init(id: UUID = UUID(), imageData: Data, createdAt: Date = .now) {
        self.id = id
        self.imageData = imageData
        self.createdAt = createdAt
    }
}

@Model
final class DesignVariation {
    @Attribute(.unique) var id: UUID
    var projectId: UUID
    var styleRaw: String
    var settings: String
    var createdAt: Date

    init(id: UUID = UUID(), projectId: UUID, style: PolishStyle, settings: String, createdAt: Date = .now) {
        self.id = id
        self.projectId = projectId
        self.styleRaw = style.rawValue
        self.settings = settings
        self.createdAt = createdAt
    }

    var style: PolishStyle {
        PolishStyle(rawValue: styleRaw) ?? .startup
    }
}

@Model
final class BrandKit {
    @Attribute(.unique) var id: UUID
    var colorsCSV: String
    var logoPlaceholder: String
    var fontPlaceholder: String
    var exportPreferences: String

    init(
        id: UUID = UUID(),
        colors: [String] = ["#7C3AED", "#06B6D4", "#111827"],
        logoPlaceholder: String = "Monogram",
        fontPlaceholder: String = "SF Pro",
        exportPreferences: String = "PNG, social presets"
    ) {
        self.id = id
        self.colorsCSV = colors.joined(separator: ",")
        self.logoPlaceholder = logoPlaceholder
        self.fontPlaceholder = fontPlaceholder
        self.exportPreferences = exportPreferences
    }

    var colors: [String] {
        get { colorsCSV.split(separator: ",").map(String.init) }
        set { colorsCSV = newValue.joined(separator: ",") }
    }
}

@Model
final class ExportRecord {
    @Attribute(.unique) var id: UUID
    var formatRaw: String
    var size: String
    var createdAt: Date

    init(id: UUID = UUID(), format: ExportFormat, size: String, createdAt: Date = .now) {
        self.id = id
        self.formatRaw = format.rawValue
        self.size = size
        self.createdAt = createdAt
    }

    var format: ExportFormat {
        ExportFormat(rawValue: formatRaw) ?? .png
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var planRaw: String
    var isActive: Bool

    init(id: UUID = UUID(), plan: SubscriptionPlan = .free, isActive: Bool = false) {
        self.id = id
        self.planRaw = plan.rawValue
        self.isActive = isActive
    }

    var plan: SubscriptionPlan {
        SubscriptionPlan(rawValue: planRaw) ?? .free
    }
}

struct DesignVariationPreview: Identifiable, Hashable {
    let id = UUID()
    let style: PolishStyle
    let title: String
    let summary: String
    let palette: [String]
}

struct AIRecommendation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
    let route: StudioRoute
}

struct SocialAsset: Identifiable, Hashable {
    let id = UUID()
    let platform: SocialPlatform
    let title: String
    let caption: String
    let outputSize: String
}

struct CarouselSlide: Identifiable, Hashable {
    let id = UUID()
    let index: Int
    let heading: String
    let layout: String
    let note: String
}
