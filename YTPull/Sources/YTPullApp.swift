//
//  YTPullApp.swift
//  YTPull
//
//  Created by Huy Nguyen on 04/04/2023.
//

import SwiftUI

@main
struct YTPullApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView().hidden()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    private var statusBarItem: NSStatusItem?
    private var popover: NSPopover!

    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {

        if let window = NSApplication.shared.windows.first {
            window.close()
        }

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let statusButton = statusBarItem?.button {
            statusButton.image = NSImage(systemSymbolName: "flame.circle", accessibilityDescription: nil)
            statusButton.action = #selector(didTapStatusButton)
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 300)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        popover.contentViewController?.view.window?.makeKey()
    }

    @objc private func didTapStatusButton() {
        guard let button = statusBarItem?.button else {
            return
        }

        if popover.isShown {
            popover?.performClose(self)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
