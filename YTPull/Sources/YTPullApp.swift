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
        WindowGroup { }.defaultSize(.zero)
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
        let readURL = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
        if let clipboardContent = readURL {
            if !clipboardContent.contains("youtube.com") && !clipboardContent.contains("youtu.be") { return }
            guard let _ = URL(string: clipboardContent) else { return }
            self.viewModel.url = clipboardContent
        }
    }
}


extension AppDelegate: NSMenuDelegate {
    func menuDidClose(_ menu: NSMenu) {
        statusBarItem.menu = nil
    }
}
