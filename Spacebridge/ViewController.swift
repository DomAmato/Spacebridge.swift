//
//  ViewController.swift
//  Spacebridge
//
//  Created by Dominic Amato on 11/5/19.
//  Copyright © 2019 Hologram. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyField = NSSecureTextField()
        keyField.frame = NSRect(x: self.view.frame.width/8, y: self.view.frame.height*0.5, width: self.view.frame.width*0.8, height: 24)
        
        self.view.addSubview(keyField)
        
        // Do any additional setup after loading the view.
        let connectButton = NSButton(title: "Connect", target: self, action: #selector(createLocalSocketListener(_:)))
        connectButton.frame = NSRect(x: self.view.frame.width/4, y: self.view.frame.height*0.2, width: self.view.frame.width/2, height: 24)
        
        self.view.addSubview(connectButton)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @objc func createLocalSocketListener(_ sender: NSButton) {
        PortForwarder.shared.forwardPort(port: 2345)
    }
    
}

extension ViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ViewController {
        //1.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("PopViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Missing storyboard, did you change ")
        }
        return viewcontroller
    }
}
