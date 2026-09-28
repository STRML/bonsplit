import XCTest
@testable import Bonsplit
import AppKit
import SwiftUI

final class TabPresenceTests: XCTestCase {
    private func samplePresence(mode: TabPresence.SizeMode = .priority, counts: Bool = false, canDisconnect: Bool = false) -> TabPresence {
        TabPresence(
            participants: [
                .init(id: "c3", initials: "MO", colorHex: "#3CC2B0", isOwner: true, accessibilityName: "Maya Ortiz"),
                .init(id: "mobile:1", initials: "DV", colorHex: "#EBA946", isOwner: false, accessibilityName: "Dev"),
            ],
            gridLabel: "118×38",
            viewerMismatch: true,
            sizeMode: mode,
            countsFromThisDevice: counts,
            canDisconnectOthers: canDisconnect,
            accessibilityLabel: "118 × 38, Maya Ortiz sets the size"
        )
    }

    func testTabItemCodableRoundTripsPresence() throws {
        let presence = samplePresence()
        let item = TabItem(title: "zsh", presence: presence)
        let decoded = try JSONDecoder().decode(TabItem.self, from: JSONEncoder().encode(item))
        XCTAssertEqual(decoded.presence, presence)

        let legacy = try JSONDecoder().decode(TabItem.self, from: JSONEncoder().encode(TabItem(title: "zsh")))
        XCTAssertNil(legacy.presence)
    }

    @MainActor
    func testUpdateTabSetsKeepsAndClearsPresence() throws {
        let controller = BonsplitController()
        let tabId = try XCTUnwrap(controller.createTab(title: "zsh"))
        XCTAssertNil(controller.tab(tabId)?.presence)

        let presence = samplePresence()
        controller.updateTab(tabId, presence: .some(presence))
        XCTAssertEqual(controller.tab(tabId)?.presence, presence)

        controller.updateTab(tabId, title: "renamed")
        XCTAssertEqual(controller.tab(tabId)?.presence, presence)

        controller.updateTab(tabId, presence: .some(nil))
        XCTAssertNil(controller.tab(tabId)?.presence)
    }

    func testSizeModeActionsRoundTrip() {
        for mode in TabPresence.SizeMode.allCases {
            XCTAssertEqual(TabContextAction.sizeMode(mode).sizeMode, mode)
        }
        XCTAssertNil(TabContextAction.showSizePanel.sizeMode)
    }

    @MainActor
    func testContextMenuAddsTerminalSizeSectionOnlyWithPresence() throws {
        let target = TabContextMenuActionTarget()
        var selected: TabContextAction?
        target.onContextAction = { selected = $0 }

        func menu(presence: TabPresence?) -> NSMenu {
            let state = TabContextMenuState(
                isPinned: false, isUnread: false, isBrowser: false, isAudioMuted: false,
                isTerminal: true, hasCustomTitle: false, canCloseToLeft: false,
                canCloseToRight: false, canCloseOthers: false, canMoveToNewWorkspace: false,
                canMoveToLeftPane: false, canMoveToRightPane: false,
                forkConversationDefaultAction: .forkConversationRight, isZoomed: false,
                hasSplits: false, shortcuts: [:], presence: presence
            )
            let snapshot = TabContextMenuSnapshot(
                tabId: UUID(), state: state,
                moveDestinationsProvider: { [] },
                forkConversationAvailabilityProvider: { .hidden }
            )
            return TabContextMenuBuilder.makeMenu(snapshot: snapshot, target: target)
        }

        XCTAssertFalse(menu(presence: nil).items.contains { $0.title == "Size to My Window" })

        let withPresence = menu(presence: samplePresence(mode: .priority, counts: false, canDisconnect: false))
        let titles = withPresence.items.map(\.title)
        for title in ["Size to My Window", "Don't Resize from This Mac", "Terminal Size",
                      "Follow Latest Input", "Fit Everyone (Smallest)", "Largest Window",
                      "Priority List…", "Fixed Size…", "Show Size Panel…", "Disconnect Other Clients…"] {
            XCTAssertTrue(titles.contains(title), "missing \(title)")
        }
        let dontResize = try XCTUnwrap(withPresence.items.first { $0.title == "Don't Resize from This Mac" })
        XCTAssertEqual(dontResize.state, .on)
        XCTAssertEqual(withPresence.items.first { $0.title == "Priority List…" }?.state, .on)
        XCTAssertEqual(withPresence.items.first { $0.title == "Follow Latest Input" }?.state, .off)
        XCTAssertEqual(withPresence.items.first { $0.title == "Disconnect Other Clients…" }?.isEnabled, false)
        XCTAssertEqual(withPresence.items.first { $0.title == "Terminal Size" }?.isEnabled, false)

        let largest = try XCTUnwrap(withPresence.items.first { $0.title == "Largest Window" })
        target.performContextAction(largest)
        XCTAssertEqual(selected, .sizeModeLargest)
    }

    func testHexColorParsing() {
        XCTAssertNotNil(Color(tabPresenceHex: "#3CC2B0"))
        XCTAssertNotNil(Color(tabPresenceHex: "D6C24A"))
        XCTAssertNil(Color(tabPresenceHex: "#12345"))
        XCTAssertNil(Color(tabPresenceHex: "zzzzzz"))
    }
}
