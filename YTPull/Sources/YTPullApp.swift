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
            HStack {
                Text("We only support for menu bar now.")
                Image(systemName: "arrow.turn.right.up").font(.system(size: 32))
            }
            .padding(16)
            .onAppear {
                DispatchQueue.main.async {
                    NSApplication.shared.windows.forEach { window in
                        window.standardWindowButton(.zoomButton)?.isEnabled = false
                    }
                }
            }
        }
        .defaultPosition(.top)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {

    private var statusBarItem: NSStatusItem!
    private var cmdPermissionsStatusCode: Int32!
    @Published var viewModel: DownloadInputViewModel = .init()

    private lazy var popover: NSPopover = {
        let _popover = NSPopover()
        _popover.contentSize = NSSize(width: 375, height: 667)
        _popover.behavior = .transient
        _popover.contentViewController?.view.window?.makeKey()
        return _popover
    }()

    lazy var statusBarMenu: NSMenu = {
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(.init(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }()

    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.button?.image = NSImage(systemSymbolName: "flame.circle", accessibilityDescription: nil)
        statusBarItem.button?.action = #selector(didTapStatusButton)
        statusBarItem.button?.sendAction(on: [.leftMouseDown, .rightMouseDown])
        cmdPermissionsStatusCode = Commands.Permission.ytdlp.execute().statusCode
        if cmdPermissionsStatusCode == EXIT_SUCCESS {
            popover.contentViewController = NSHostingController(rootView: DownloadConsoleView(viewModel: viewModel))
        } else {
            popover.contentViewController = NSHostingController(rootView: DownloadConsoleErrorView())
        }
    }

    @objc private func didTapStatusButton() {
        /// Close main window in case still open same time with popover.
        if NSApp.windows.last?.isMainWindow == true {
            NSApp.windows.last?.close()
        }
        let event = NSApp.currentEvent?.type
        switch event {
        case .leftMouseDown:
            guard let button = statusBarItem.button else { return }
            if popover.isShown {
                popover.performClose(self)
            } else {
                if cmdPermissionsStatusCode == EXIT_SUCCESS {
                    getURLClipboard()
                }
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        case .rightMouseDown:
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(nil)
        default:
            break
        }
    }

    private func getURLClipboard() {
        guard let readURL = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string),
              readURL.isYTURL else {
            return
        }
        self.viewModel.url = readURL
    }
}


extension AppDelegate: NSMenuDelegate {
    func menuDidClose(_ menu: NSMenu) {
        statusBarItem.menu = nil
    }
}
