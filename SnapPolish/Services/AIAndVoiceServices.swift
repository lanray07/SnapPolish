import AVFoundation
import Combine
import Foundation
import Speech
import StoreKit

protocol ScreenshotPolishServing {
    func polish(style: PolishStyle, screenshotType: String) async -> [DesignVariationPreview]
}

protocol DesignRecommendationServing {
    func recommendations(for creatorType: CreatorType, primaryUse: PrimaryUse) async -> [AIRecommendation]
}

protocol MockupGenerationServing {
    func mockups(for frame: DeviceFrame) async -> [DesignVariationPreview]
}

protocol SocialContentServing {
    func socialAssets(prompt: String, platform: SocialPlatform) async -> [SocialAsset]
}

protocol HeadlineGenerationServing {
    func headlines(prompt: String) async -> [String]
}

protocol CarouselGenerationServing {
    func carouselSlides(prompt: String) async -> [CarouselSlide]
}

final class MockAIService:
    ScreenshotPolishServing,
    DesignRecommendationServing,
    MockupGenerationServing,
    SocialContentServing,
    HeadlineGenerationServing,
    CarouselGenerationServing
{
    static let shared = MockAIService()

    private init() {}

    func polish(style: PolishStyle, screenshotType: String) async -> [DesignVariationPreview] {
        [
            DesignVariationPreview(
                style: style,
                title: "\(style.label) hero",
                summary: "Cropped for clarity with premium spacing, glow, and a launch-ready headline zone.",
                palette: ["#0B0F1A", "#7C3AED", "#06B6D4"]
            ),
            DesignVariationPreview(
                style: style,
                title: "Floating showcase",
                summary: "Places the screenshot inside a lifted device frame with deep shadow and glass accents.",
                palette: ["#030712", "#F43F5E", "#FBBF24"]
            ),
            DesignVariationPreview(
                style: style,
                title: "Social proof frame",
                summary: "Optimized for feeds with readable contrast, a clean caption area, and creator branding.",
                palette: ["#111827", "#10B981", "#E5E7EB"]
            )
        ]
    }

    func recommendations(for creatorType: CreatorType, primaryUse: PrimaryUse) async -> [AIRecommendation] {
        [
            AIRecommendation(
                title: "Build a launch post",
                detail: "\(creatorType.label) workspace tuned for \(primaryUse.label.lowercased()).",
                route: .social
            ),
            AIRecommendation(
                title: "Polish your strongest screenshot",
                detail: "Generate three visual directions before exporting.",
                route: .polish
            ),
            AIRecommendation(
                title: "Create a headline set",
                detail: "Use voice input to dictate a rough idea, then refine it.",
                route: .headlines
            )
        ]
    }

    func mockups(for frame: DeviceFrame) async -> [DesignVariationPreview] {
        [
            DesignVariationPreview(
                style: .appleStyle,
                title: "\(frame.label) glass mockup",
                summary: "A crisp \(frame.label.lowercased()) frame with reflection, depth, and editorial lighting.",
                palette: ["#020617", "#38BDF8", "#F8FAFC"]
            )
        ]
    }

    func socialAssets(prompt: String, platform: SocialPlatform) async -> [SocialAsset] {
        let base = prompt.isEmpty ? "Turn screenshots into marketing assets" : prompt
        return [
            SocialAsset(
                platform: platform,
                title: "Launch graphic",
                caption: "\(base). Built for a fast, high-contrast product reveal.",
                outputSize: platform == .instagramStory ? "1080 x 1920" : "1080 x 1080"
            ),
            SocialAsset(
                platform: platform,
                title: "Founder note",
                caption: "I made this to help teams make every screenshot look launch-ready.",
                outputSize: platform == .x ? "1600 x 900" : "1200 x 1500"
            )
        ]
    }

    func headlines(prompt: String) async -> [String] {
        let subject = prompt.isEmpty ? "your screenshot" : prompt
        return [
            "Make \(subject) look launch-ready",
            "Turn ordinary screens into premium product visuals",
            "Ship polished launch graphics in seconds",
            "From raw screenshot to App Store-ready asset"
        ]
    }

    func carouselSlides(prompt: String) async -> [CarouselSlide] {
        let theme = prompt.isEmpty ? "a product walkthrough" : prompt
        return [
            CarouselSlide(index: 1, heading: "The problem", layout: "Bold opener", note: "Frame why \(theme) matters."),
            CarouselSlide(index: 2, heading: "The transformation", layout: "Before and after", note: "Show raw vs polished screenshot."),
            CarouselSlide(index: 3, heading: "The details", layout: "Feature trio", note: "Highlight three benefits."),
            CarouselSlide(index: 4, heading: "The action", layout: "CTA close", note: "Invite the viewer to try or download.")
        ]
    }
}

final class ScreenshotPolishService {
    private let ai: ScreenshotPolishServing

    init(ai: ScreenshotPolishServing = MockAIService.shared) {
        self.ai = ai
    }

    func variations(style: PolishStyle, screenshotType: String = "app screen") async -> [DesignVariationPreview] {
        await ai.polish(style: style, screenshotType: screenshotType)
    }
}

final class DesignRecommendationService {
    private let ai: DesignRecommendationServing

    init(ai: DesignRecommendationServing = MockAIService.shared) {
        self.ai = ai
    }

    func recommendations(for creatorType: CreatorType = .creator, primaryUse: PrimaryUse = .socialMedia) async -> [AIRecommendation] {
        await ai.recommendations(for: creatorType, primaryUse: primaryUse)
    }
}

final class MockupGenerationService {
    private let ai: MockupGenerationServing

    init(ai: MockupGenerationServing = MockAIService.shared) {
        self.ai = ai
    }

    func mockups(for frame: DeviceFrame) async -> [DesignVariationPreview] {
        await ai.mockups(for: frame)
    }
}

final class SocialContentService {
    private let ai: SocialContentServing

    init(ai: SocialContentServing = MockAIService.shared) {
        self.ai = ai
    }

    func assets(prompt: String, platform: SocialPlatform) async -> [SocialAsset] {
        await ai.socialAssets(prompt: prompt, platform: platform)
    }
}

final class HeadlineGenerationService {
    private let ai: HeadlineGenerationServing

    init(ai: HeadlineGenerationServing = MockAIService.shared) {
        self.ai = ai
    }

    func headlines(prompt: String) async -> [String] {
        await ai.headlines(prompt: prompt)
    }
}

final class CarouselGenerationService {
    private let ai: CarouselGenerationServing

    init(ai: CarouselGenerationServing = MockAIService.shared) {
        self.ai = ai
    }

    func slides(prompt: String) async -> [CarouselSlide] {
        await ai.carouselSlides(prompt: prompt)
    }
}

struct RemoteAIRequest: Encodable {
    var module: String
    var screenshotType: String
    var style: String
    var platform: String
}

struct RemoteAIResponse: Decodable {
    var variations: [String]
    var headlines: [String]
    var recommendations: [String]
}

final class RemoteAIService {
    private let endpoint = URL(string: "https://YOUR_BACKEND_URL.com/snappolish")!

    func send(_ request: RemoteAIRequest) async throws -> RemoteAIResponse {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(RemoteAIResponse.self, from: data)
    }
}

private enum StoreVerificationError: Error {
    case failedVerification
}

@MainActor
final class SubscriptionStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var plan: SubscriptionPlan = .free
    @Published var isLoadingProducts = false
    @Published var isRestoringPurchases = false
    @Published var purchaseMessage: String?

    private let productIDs = [
        "snappolish.creator.monthly",
        "snappolish.creator.yearly",
        "snappolish.agency.monthly"
    ]
    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        transactionUpdatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handleTransactionUpdate(update)
            }
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var isPro: Bool {
        plan != .free
    }

    var sortedProducts: [Product] {
        products.sorted { first, second in
            productSortOrder(first.id) < productSortOrder(second.id)
        }
    }

    func prepare() async {
        await refreshPurchasedEntitlements()
        await loadProducts()
    }

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            products = try await Product.products(for: productIDs)
        } catch {
            purchaseMessage = "Subscriptions are temporarily unavailable."
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshPurchasedEntitlements()
                let activePlan = plan(for: transaction.productID) ?? plan
                purchaseMessage = "\(activePlan.label) active."
            case .pending:
                purchaseMessage = "Purchase pending."
            case .userCancelled:
                purchaseMessage = "Purchase cancelled."
            @unknown default:
                purchaseMessage = "Purchase status unavailable."
            }
        } catch {
            purchaseMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isRestoringPurchases = true
        defer { isRestoringPurchases = false }

        do {
            try await AppStore.sync()
            await refreshPurchasedEntitlements()
            purchaseMessage = isPro ? "\(plan.label) restored." : "No active subscription found."
        } catch {
            purchaseMessage = error.localizedDescription
        }
    }

    func reloadProducts() async {
        products = []
        purchaseMessage = nil
        await loadProducts()
    }

    func refreshPurchasedEntitlements() async {
        var bestPlan: SubscriptionPlan = .free

        for await entitlement in Transaction.currentEntitlements {
            guard
                let transaction = try? checkVerified(entitlement),
                transaction.revocationDate == nil,
                transaction.expirationDate.map({ $0 > Date() }) ?? true,
                let entitlementPlan = plan(for: transaction.productID)
            else {
                continue
            }

            if entitlementRank(entitlementPlan) > entitlementRank(bestPlan) {
                bestPlan = entitlementPlan
            }
        }

        plan = bestPlan
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreVerificationError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func handleTransactionUpdate(_ update: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(update)
            await transaction.finish()
            await refreshPurchasedEntitlements()
        } catch {
            purchaseMessage = "Unable to verify purchase."
        }
    }

    private func plan(for productID: String) -> SubscriptionPlan? {
        switch productID {
        case "snappolish.creator.monthly":
            return .creatorProMonthly
        case "snappolish.creator.yearly":
            return .creatorProYearly
        case "snappolish.agency.monthly":
            return .agencyMonthly
        default:
            return nil
        }
    }

    private func productSortOrder(_ productID: String) -> Int {
        switch productID {
        case "snappolish.creator.monthly":
            return 0
        case "snappolish.creator.yearly":
            return 1
        case "snappolish.agency.monthly":
            return 2
        default:
            return Int.max
        }
    }

    private func entitlementRank(_ plan: SubscriptionPlan) -> Int {
        switch plan {
        case .free:
            return 0
        case .creatorProMonthly, .creatorProYearly:
            return 1
        case .agencyMonthly:
            return 2
        }
    }
}

final class VoiceInputService: ObservableObject {
    @Published private(set) var transcript = ""
    @Published private(set) var isRecording = false
    @Published private(set) var authorizationStatus = SFSpeechRecognizerAuthorizationStatus.notDetermined
    @Published var errorMessage: String?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    @MainActor
    func resetTranscript() {
        transcript = ""
        errorMessage = nil
    }

    @MainActor
    func startTranscribing() async {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is not available right now."
            return
        }

        guard await requestAuthorization() else {
            errorMessage = "Enable microphone and speech recognition permissions to use voice input."
            return
        }

        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = true

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            errorMessage = nil

            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                Task { @MainActor in
                    if let result {
                        self?.transcript = result.bestTranscription.formattedString
                    }

                    if error != nil || result?.isFinal == true {
                        self?.stopTranscribing()
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            stopTranscribing()
        }
    }

    @MainActor
    func stopTranscribing() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    @MainActor
    private func requestAuthorization() async -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        let microphoneGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        authorizationStatus = speechStatus
        return speechStatus == .authorized && microphoneGranted
    }
}
