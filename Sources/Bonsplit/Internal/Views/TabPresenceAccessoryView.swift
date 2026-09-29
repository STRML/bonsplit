import SwiftUI

/// The shared-terminal presence accessory drawn after a tab title: up to
/// three overlapping neutral grey avatars (initials for other people, a device
/// glyph for the viewer's own other devices), a thin neutral ring on the owner,
/// and `+N` for the rest. No per-participant colors.
struct TabPresenceAccessoryView: View {
    let presence: TabPresence
    /// Fill behind the tab, used for the avatar separation border.
    let borderColor: Color
    let textColor: Color
    let isHovered: Bool
    let hoverBackground: Color

    static let maxAvatars = 3
    private static let avatarSize: CGFloat = 14
    private static let overlap: CGFloat = 4
    private static let ringWidth: CGFloat = 1

    var body: some View {
        let shown = Array(presence.participants.prefix(Self.maxAvatars))
        let extra = presence.participants.count - shown.count
        HStack(spacing: -Self.overlap) {
            // Later avatars sit under earlier ones so the owner (first) stays on top.
            ForEach(Array(shown.enumerated()), id: \.element.id) { index, participant in
                avatar(participant)
                    .zIndex(Double(shown.count - index))
            }
            if extra > 0 {
                Text(verbatim: "+\(extra)")
                    .font(.system(size: 9, weight: .semibold).monospacedDigit())
                    .foregroundStyle(textColor.opacity(0.7))
                    .padding(.leading, Self.overlap + 3)
                    .fixedSize()
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

    private func avatar(_ participant: TabPresence.Participant) -> some View {
        ZStack {
            // Opaque base so overlapping avatars do not show through each other.
            Circle().fill(borderColor)
            Circle().fill(Color(nsColor: .quaternaryLabelColor))
            if let symbolName = participant.symbolName {
                Image(systemName: symbolName)
                    .font(.system(size: 7, weight: .medium))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
            } else {
                Text(verbatim: participant.initials)
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .frame(width: Self.avatarSize, height: Self.avatarSize)
        .overlay(Circle().stroke(borderColor, lineWidth: 1))
        .overlay {
            if participant.isOwner {
                Circle()
                    .inset(by: -(Self.ringWidth + 0.5))
                    .stroke(Color(nsColor: .labelColor).opacity(0.5), lineWidth: Self.ringWidth)
            }
        }
        .padding(participant.isOwner ? Self.ringWidth + 0.5 : 0)
    }
}

/// Where the title row reserved space for the presence accessory.
struct TabPresenceAccessoryBoundsKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}
