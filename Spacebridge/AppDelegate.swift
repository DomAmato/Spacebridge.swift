//
//  AppDelegate.swift
//  Spacebridge
//
//  Created by Dominic Amato on 11/5/19.
//  Copyright © 2019 Hologram. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Initialize the connectivity singleton
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarIcon"))
            button.toolTip = "Spacebridge"
            button.action = #selector(togglePopover(_:))
        }
        popover.contentViewController = ViewController.freshController()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

    func applicationWillResignActive(_ notification: Notification) {
            closePopover(sender: self)
    }
}


