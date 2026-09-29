import AppKit

/// Neutral colors for chrome drawn on a themed surface (the shared-terminal
/// presence accessory and sizing bounds).
public struct BonsplitContrastPalette: Equatable, Sendable {
    /// An opaque gamma-encoded sRGB color, components in 0...1.
    public struct RGB: Equatable, Hashable, Sendable {
        public var red: Double
        public var green: Double
        public var blue: Double

        public init(red: Double, green: Double, blue: Double) {
            self.red = red
            self.green = green
            self.blue = blue
        }

        /// `#rrggbb` or `rrggbb`.
        public init?(hex: String) {
            var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            if value.hasPrefix("#") { value.removeFirst() }
            guard value.count == 6, let rgb = UInt32(value, radix: 16) else { return nil }
            self.init(
                red: Double((rgb >> 16) & 0xFF) / 255,
                green: Double((rgb >> 8) & 0xFF) / 255,
                blue: Double(rgb & 0xFF) / 255
            )
        }

        public func mixed(toward other: RGB, by amount: Double) -> RGB {
            let t = min(max(amount, 0), 1)
            return RGB(
                red: red + (other.red - red) * t,
                green: green + (other.green - green) * t,
                blue: blue + (other.blue - blue) * t
            )
        }

        public var relativeLuminance: Double {
            func linear(_ c: Double) -> Double {
                c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
        }
    }

    public let background: RGB
    public let foreground: RGB
    public let fill: RGB
    public let glyph: RGB
    public let text: RGB
    public let line: RGB
    public let hatch: RGB

    public static func contrastRatio(_ a: RGB, _ b: RGB) -> Double {
        let la = a.relativeLuminance, lb = b.relativeLuminance
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }

    // Stub: the separator-grey behavior this palette replaces.
    public init(background: RGB, foreground: RGB) {
        self.background = background
        self.foreground = foreground
        let light = background.relativeLuminance > 0.18
        let tone = light
            ? RGB(red: background.red - 0.12, green: background.green - 0.12, blue: background.blue - 0.12)
            : RGB(red: background.red + 0.16, green: background.green + 0.16, blue: background.blue + 0.16)
        let alpha = light ? 0.26 : 0.36
        fill = background.mixed(toward: tone, by: alpha * 0.6)
        line = background.mixed(toward: tone, by: alpha)
        hatch = background.mixed(toward: tone, by: alpha * 0.35)
        glyph = RGB(red: 0.6, green: 0.6, blue: 0.6)
        text = glyph
    }

    /// `color` as opaque sRGB in the current drawing appearance, composited
    /// over `base` when translucent.
    public static func rgb(_ color: NSColor, over base: NSColor = .windowBackgroundColor) -> RGB {
        let resolved = color.usingColorSpace(.sRGB) ?? NSColor.gray
        let own = RGB(red: resolved.redComponent, green: resolved.greenComponent, blue: resolved.blueComponent)
        let alpha = Double(resolved.alphaComponent)
        guard alpha < 0.999 else { return own }
        let under = base.usingColorSpace(.sRGB) ?? NSColor.windowBackgroundColor
        let baseRGB = RGB(red: under.redComponent, green: under.greenComponent, blue: under.blueComponent)
        return baseRGB.mixed(toward: own, by: alpha)
    }
}
