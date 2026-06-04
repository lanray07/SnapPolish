import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI
import UIKit

struct DesignSettings: Codable, Hashable {
    var style: PolishStyle
    var shadowDepth: Double
    var cornerRadius: Double
    var glowIntensity: Double
    var backgroundHex: String
}

struct CompositionSuggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
}

final class ScreenshotEnhancementPipeline {
    private let context = CIContext()

    func enhancedImage(from data: Data, style: PolishStyle) -> UIImage? {
        guard let image = CIImage(data: data) else { return nil }

        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = image
        colorControls.saturation = style == .neon ? 1.22 : 1.08
        colorControls.contrast = style == .minimal ? 1.02 : 1.14
        colorControls.brightness = style == .darkLuxury ? -0.02 : 0.03

        guard
            let output = colorControls.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent)
        else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

enum DesignEngine {
    static func settings(for style: PolishStyle) -> DesignSettings {
        switch style {
        case .minimal:
            DesignSettings(style: style, shadowDepth: 0.12, cornerRadius: 22, glowIntensity: 0.08, backgroundHex: "#F8FAFC")
        case .appleStyle:
            DesignSettings(style: style, shadowDepth: 0.28, cornerRadius: 28, glowIntensity: 0.16, backgroundHex: "#0B1220")
        case .startup:
            DesignSettings(style: style, shadowDepth: 0.34, cornerRadius: 26, glowIntensity: 0.24, backgroundHex: "#111827")
        case .saas:
            DesignSettings(style: style, shadowDepth: 0.22, cornerRadius: 18, glowIntensity: 0.14, backgroundHex: "#0F172A")
        case .darkLuxury:
            DesignSettings(style: style, shadowDepth: 0.42, cornerRadius: 30, glowIntensity: 0.18, backgroundHex: "#020617")
        case .neon:
            DesignSettings(style: style, shadowDepth: 0.38, cornerRadius: 26, glowIntensity: 0.42, backgroundHex: "#050816")
        case .creator:
            DesignSettings(style: style, shadowDepth: 0.26, cornerRadius: 24, glowIntensity: 0.26, backgroundHex: "#18181B")
        case .productLaunch:
            DesignSettings(style: style, shadowDepth: 0.36, cornerRadius: 24, glowIntensity: 0.32, backgroundHex: "#09090B")
        }
    }

    static func suggestions(for style: PolishStyle) -> [CompositionSuggestion] {
        [
            CompositionSuggestion(title: "Crop to the action", detail: "Center the key UI and remove low-signal margins."),
            CompositionSuggestion(title: "Add launch hierarchy", detail: "Reserve a clean headline zone above the screenshot."),
            CompositionSuggestion(title: "\(style.label) finish", detail: "Apply shadows, glow, spacing, and brand accents consistently.")
        ]
    }
}
