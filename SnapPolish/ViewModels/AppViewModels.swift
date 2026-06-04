import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var recommendations: [AIRecommendation] = []
    @Published var isLoadingRecommendations = false

    private let recommendationService: DesignRecommendationService

    init(recommendationService: DesignRecommendationService = DesignRecommendationService()) {
        self.recommendationService = recommendationService
    }

    func loadRecommendations(creatorType: CreatorType = .creator, primaryUse: PrimaryUse = .socialMedia) async {
        isLoadingRecommendations = true
        recommendations = await recommendationService.recommendations(for: creatorType, primaryUse: primaryUse)
        isLoadingRecommendations = false
    }
}

@MainActor
final class PolishStudioViewModel: ObservableObject {
    @Published var selectedStyle: PolishStyle = .startup
    @Published var variations: [DesignVariationPreview] = []
    @Published var isGenerating = false

    private let polishService: ScreenshotPolishService

    init(polishService: ScreenshotPolishService = ScreenshotPolishService()) {
        self.polishService = polishService
    }

    func generate() async {
        isGenerating = true
        variations = await polishService.variations(style: selectedStyle)
        isGenerating = false
    }
}

@MainActor
final class MockupViewModel: ObservableObject {
    @Published var selectedFrame: DeviceFrame = .iPhone
    @Published var mockups: [DesignVariationPreview] = []
    @Published var isGenerating = false

    private let mockupService: MockupGenerationService

    init(mockupService: MockupGenerationService = MockupGenerationService()) {
        self.mockupService = mockupService
    }

    func generate() async {
        isGenerating = true
        mockups = await mockupService.mockups(for: selectedFrame)
        isGenerating = false
    }
}

@MainActor
final class SocialContentViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var selectedPlatform: SocialPlatform = .linkedIn
    @Published var assets: [SocialAsset] = []
    @Published var isGenerating = false

    private let service: SocialContentService

    init(service: SocialContentService = SocialContentService()) {
        self.service = service
    }

    func generate() async {
        isGenerating = true
        assets = await service.assets(prompt: prompt, platform: selectedPlatform)
        isGenerating = false
    }
}

@MainActor
final class HeadlineGeneratorViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var headlines: [String] = []
    @Published var isGenerating = false

    private let service: HeadlineGenerationService

    init(service: HeadlineGenerationService = HeadlineGenerationService()) {
        self.service = service
    }

    func generate() async {
        isGenerating = true
        headlines = await service.headlines(prompt: prompt)
        isGenerating = false
    }
}

@MainActor
final class CarouselBuilderViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var slides: [CarouselSlide] = []
    @Published var isGenerating = false

    private let service: CarouselGenerationService

    init(service: CarouselGenerationService = CarouselGenerationService()) {
        self.service = service
    }

    func generate() async {
        isGenerating = true
        slides = await service.slides(prompt: prompt)
        isGenerating = false
    }
}

@MainActor
final class BrandKitViewModel: ObservableObject {
    @Published var brandName = "SnapPolish Studio"
    @Published var colors = ["#7C3AED", "#06B6D4", "#F43F5E"]
    @Published var selectedFont = "SF Pro"
    @Published var exportPreference = "PNG, JPG, App Store, social presets"

    func applyPreset(_ preset: BrandPreset) {
        brandName = preset.name
        colors = preset.colors
        selectedFont = preset.font
    }
}
