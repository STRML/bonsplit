import Foundation

/// Who is viewing a shared terminal tab and what size its grid has.
///
/// The host app fills this from its terminal sizing state. Bonsplit renders it
/// as a presence accessory after the tab title and adds the terminal-size
/// section to the tab context menu. A `nil` presence hides both.
public struct TabPresence: Hashable, Sendable, Codable {
    /// One attached person or device shown in the tab's avatar stack.
    public struct Participant: Hashable, Sendable, Codable, Identifiable {
        /// Host-scoped participant id.
        public var id: String
        /// One or two letters drawn inside the avatar.
        public var initials: String
        /// Avatar fill color as `#RRGGBB`.
        public var colorHex: String
        /// Whether this participant sets the terminal size (drawn with a ring).
        public var isOwner: Bool
        /// Name read by VoiceOver and shown in help text.
        public var accessibilityName: String

        /// Creates a participant row.
        ///
        /// - Parameters:
        ///   - id: Host-scoped participant id.
        ///   - initials: Letters drawn inside the avatar.
        ///   - colorHex: Avatar color as `#RRGGBB`.
        ///   - isOwner: Whether this participant sets the terminal size.
        ///   - accessibilityName: Spoken name.
        public init(id: String, initials: String, colorHex: String, isOwner: Bool, accessibilityName: String) {
            self.id = id
            self.initials = initials
            self.colorHex = colorHex
            self.isOwner = isOwner
            self.accessibilityName = accessibilityName
        }
    }

    /// How the host picks the terminal grid. Mirrors the host's sizing modes.
    public enum SizeMode: String, Hashable, Sendable, Codable, CaseIterable {
        /// The participant with the newest input sets the size.
        case latest
        /// Component-wise minimum over counting participants.
        case smallest
        /// Component-wise maximum over counting participants.
        case largest
        /// The first attached participant in a priority list sets the size.
        case priority
        /// One fixed grid regardless of who is attached.
        case fixed
    }

    /// Attached participants, in display order.
    public var participants: [Participant]
    /// Grid label drawn after the avatars, for example `118×38`.
    public var gridLabel: String
    /// Whether this device's window does not match the grid (draws a dashed-box glyph).
    public var viewerMismatch: Bool
    /// The current sizing mode, checked in the context menu.
    public var sizeMode: SizeMode
    /// Whether this device counts toward the size. `false` checks "Don't Resize from This Mac".
    public var countsFromThisDevice: Bool
    /// Whether "Disconnect Other Clients…" is enabled.
    public var canDisconnectOthers: Bool
    /// Label for the accessory button and its help tooltip.
    public var accessibilityLabel: String

    /// Creates a presence snapshot.
    ///
    /// - Parameters:
    ///   - participants: Attached participants.
    ///   - gridLabel: Grid label such as `118×38`.
    ///   - viewerMismatch: Whether this device's window differs from the grid.
    ///   - sizeMode: Current sizing mode.
    ///   - countsFromThisDevice: Whether this device counts toward size.
    ///   - canDisconnectOthers: Whether other clients can be disconnected.
    ///   - accessibilityLabel: Accessory label and tooltip.
    public init(
        participants: [Participant],
        gridLabel: String,
        viewerMismatch: Bool,
        sizeMode: SizeMode,
        countsFromThisDevice: Bool,
        canDisconnectOthers: Bool,
        accessibilityLabel: String
    ) {
        self.participants = participants
        self.gridLabel = gridLabel
        self.viewerMismatch = viewerMismatch
        self.sizeMode = sizeMode
        self.countsFromThisDevice = countsFromThisDevice
        self.canDisconnectOthers = canDisconnectOthers
        self.accessibilityLabel = accessibilityLabel
    }
}
