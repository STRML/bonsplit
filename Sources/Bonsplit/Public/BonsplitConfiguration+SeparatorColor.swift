import AppKit

extension BonsplitConfiguration.Appearance {
    /// The one border grey this appearance draws: split dividers, tab-bar
    /// separators and pane borders. `chromeColors.borderHex` when set, else a
    /// shade derived from the tab-bar background. Hosts draw related chrome
    /// (for example shared-terminal sizing bounds) in this color, deriving
    /// fills from it with opacity, so every border in the app matches.
    public var separatorColor: NSColor {
        TabBarColors.nsColorSeparator(for: self)
    }
}
