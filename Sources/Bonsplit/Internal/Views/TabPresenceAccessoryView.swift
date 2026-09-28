import SwiftUI

/// The shared-terminal presence accessory drawn after a tab title: an
/// overlapping avatar stack with an owner ring, the grid size, and a dashed-box
/// glyph when this device's window does not match the grid.
struct TabPresenceAccessoryView: View {
    let presence: TabPresence
    /// Fill behind the tab, used for the avatar separation border.
    let borderColor: Color
    let textColor: Color
    let isHovered: Bool
    let hoverBackground: Color

    private static let maxAvatars = 3
    private static let avatarSize: CGFloat = 14
    private static let overlap: CGFloat = 4
    static let mismatchColor = Color(tabPresenceHex: "#E9B44C") ?? .orange

    var body: some View {
        HStack(spacing: 4) {
            avatarStack
            Text(presence.gridLabel)
                .font(.system(size: 10).monospacedDigit())
                .foregroundStyle(textColor.opacity(0.78))
                .lineLimit(1)
                .fixedSize()
            if presence.viewerMismatch {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(Self.mismatchColor, style: StrokeStyle(lineWidth: 1.2, dash: [2, 1.5]))
                    .frame(width: 11, height: 9)
                    .frame(width: 11, height: 11)
            }
        }
        .padding(.horizontal, 3)
        .padding(.vertical, 1)
        .background(
            Capsule(style: .continuous)
                .fill(isHovered ? hoverBackground : .clear)
        )
        .contentShape(Capsule(style: .continuous))
    }

    @ViewBuilder
    private var avatarStack: some View {
        let shown = Array(presence.participants.prefix(Self.maxAvatars))
        let extra = presence.participants.count - shown.count
        HStack(spacing: -Self.overlap) {
            ForEach(shown) { participant in
                avatar(participant)
            }
            if extra > 0 {
                Text("+\(extra)")
                    .font(.system(size: 8, weight: .semibold).monospacedDigit())
                    .foregroundStyle(textColor.opacity(0.78))
                    .padding(.leading, Self.overlap + 2)
                    .fixedSize()
            }
        }
    }

    private func avatar(_ participant: TabPresence.Participant) -> some View {
        let color = Color(tabPresenceHex: participant.colorHex) ?? .gray
        return ZStack {
            Circle()
                .fill(color)
            Text(participant.initials)
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(Color(red: 0.055, green: 0.07, blue: 0.094))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(width: Self.avatarSize, height: Self.avatarSize)
        .overlay(Circle().stroke(borderColor, lineWidth: 1.5))
        .overlay {
            if participant.isOwner {
                Circle()
                    .inset(by: -3)
                    .stroke(color, lineWidth: 1.5)
            }
        }
        .padding(participant.isOwner ? 3 : 0)
    }
}

extension Color {
    /// Parses `#RRGGBB` (or `RRGGBB`); nil for anything else.
    init?(tabPresenceHex hex: String) {
        var text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") { text.removeFirst() }
        guard text.count == 6, let value = UInt32(text, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
