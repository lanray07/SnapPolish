import SwiftData
import SwiftUI

@main
struct SnapPolishApp: App {
    @StateObject private var subscriptionStore = SubscriptionStore()
    @StateObject private var voiceInputService = VoiceInputService()

    private let modelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Project.self,
            ScreenshotAsset.self,
            DesignVariation.self,
            BrandKit.self,
            ExportRecord.self,
            SubscriptionState.self
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SnapPolish model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(modelContainer)
                .environmentObject(subscriptionStore)
                .environmentObject(voiceInputService)
                .preferredColorScheme(.dark)
        }
    }
}
