import SwiftUI
import UIKit

@MainActor
final class ImageExportEngine {
    func pngData<V: View>(for view: V, size: CGSize) -> Data? {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage?.pngData()
    }

    func jpegData<V: View>(for view: V, size: CGSize, compressionQuality: CGFloat = 0.9) -> Data? {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage?.jpegData(compressionQuality: compressionQuality)
    }
}

struct ExportPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let format: ExportFormat
    let size: CGSize

    var sizeLabel: String {
        "\(Int(size.width)) x \(Int(size.height))"
    }
}

enum ExportPresetLibrary {
    static let presets: [ExportPreset] = [
        ExportPreset(name: "Square Social", format: .png, size: CGSize(width: 1080, height: 1080)),
        ExportPreset(name: "Portrait Feed", format: .png, size: CGSize(width: 1080, height: 1350)),
        ExportPreset(name: "Story", format: .jpg, size: CGSize(width: 1080, height: 1920)),
        ExportPreset(name: "Launch Wide", format: .jpg, size: CGSize(width: 1600, height: 900)),
        ExportPreset(name: "App Store 6.7", format: .appStore, size: CGSize(width: 1290, height: 2796))
    ]
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
