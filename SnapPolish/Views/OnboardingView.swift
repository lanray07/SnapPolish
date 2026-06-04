import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    let onFinish: () -> Void

    @State private var creatorType: CreatorType = .founder
    @State private var primaryUse: PrimaryUse = .socialMedia

    var body: some View {
        PremiumBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SnapPolish")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Turn screenshots into marketing assets.")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.cyan)
                        Text("Make every screenshot look launch-ready.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 42)

                    optionSection(
                        title: "Creator type",
                        items: CreatorType.allCases,
                        selection: $creatorType
                    ) { item in
                        item.label
                    }

                    optionSection(
                        title: "Primary use",
                        items: PrimaryUse.allCases,
                        selection: $primaryUse
                    ) { item in
                        item.label
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Personalized workspace", systemImage: "wand.and.stars")
                                .font(.headline)
                            Text("Your dashboard will prioritize \(primaryUse.label.lowercased()) templates, launch-ready polish styles, and AI recommendations for \(creatorType.label.lowercased()) workflows.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    PremiumButton(title: "Create workspace", systemImage: "sparkles") {
                        saveProfile()
                    }
                }
                .padding(20)
            }
        }
    }

    private func optionSection<Item: Identifiable & Hashable>(
        title: String,
        items: [Item],
        selection: Binding<Item>,
        label: @escaping (Item) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                ForEach(items) { item in
                    Button {
                        selection.wrappedValue = item
                    } label: {
                        HStack {
                            Text(label(item))
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            if selection.wrappedValue == item {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .padding(14)
                        .foregroundStyle(.white)
                        .background(
                            selection.wrappedValue == item ? .cyan.opacity(0.22) : .white.opacity(0.07),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(selection.wrappedValue == item ? .cyan.opacity(0.65) : .white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func saveProfile() {
        let profile = UserProfile(creatorType: creatorType, primaryUse: primaryUse)
        modelContext.insert(profile)
        try? modelContext.save()
        onFinish()
    }
}
