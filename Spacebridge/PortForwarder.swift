//
//  PortForwarding.swift
//  Spacebridge
//
//  Created by Dominic Amato on 11/5/19.
//  Copyright © 2019 Hologram. All rights reserved.
//
import Socket
import Foundation

class PortForwarder: NSObject {
    public static let shared = PortForwarder()
    static let bufferSize = 4096
    
    var listenSocket: Socket? = nil
    var continueRunningValue = true
    var connectedSockets = [Int:[Int32: Socket]]()
    let socketLockQueue = DispatchQueue(label: "com.ibm.serverSwift.socketLockQueue")
    var continueRunning: Bool {
        set(newValue) {
            socketLockQueue.sync {
                self.continueRunningValue = newValue
            }
        }
        get {
            return socketLockQueue.sync {
                self.continueRunningValue
            }
        }
    }
    
    override private init() {
    }
    
    deinit {
        // Close all open sockets...
        for ports in connectedSockets.values {
            for socket in ports.values {
                socket.close()
            }
            self.listenSocket?.close()
        }
    }
    
    func forwardPort(port: Int) {
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async { [unowned self] in
            
            do {
                // Create a socket...
                try self.listenSocket = Socket.create()
                
                guard let socket = self.listenSocket else {
                    
                    print("Unable to unwrap socket...")
                    return
                }
                
                try socket.listen(on: port)
                
                print("Listening on port: \(socket.listeningPort)")
                self.addNewConnection(port: port, socket: socket)
                
//                repeat {
//                    let newSocket = try socket.acceptClientConnection()
//
//                    print("Accepted connection from: \(newSocket.remoteHostname) on port \(newSocket.remotePort)")
//                    print("Socket Signature: \(String(describing: newSocket.signature?.description))")
//
//                    self.addNewConnection(port: port, socket: newSocket)
//
//                } while self.continueRunning
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error...")
                    return
                }
                
                if self.continueRunning {
                    
                    print("Error reported:\n \(socketError.description)")
                    
                }
            }
        }
        dispatchMain()
    }
    
    func addNewConnection(port: Int, socket: Socket) {
        
        // Add the new socket to the list of connected sockets...
        socketLockQueue.sync { [unowned self, socket] in
            self.connectedSockets[port]?[socket.socketfd] = socket
        }
        
        // Get the global concurrent queue...
        let queue = DispatchQueue.global(qos: .default)
        
        // Create the run loop work item and dispatch to the default priority global queue...
        queue.async { [unowned self, socket] in
            
            var shouldKeepRunning = true
            
            var readData = Data(capacity: PortForwarder.bufferSize)
            
            do {
                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    
                    if bytesRead > 0 {
                        guard let response = String(data: readData, encoding: .utf8) else {
                            
                            print("Error decoding response...")
                            readData.count = 0
                            break
                        }
                        print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")
                    }
                    
                    if bytesRead == 0 {
                        
                        shouldKeepRunning = false
                        break
                    }
                    
                    readData.count = 0
                    
                } while shouldKeepRunning
                
                print("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                socket.close()
                
                self.socketLockQueue.sync { [unowned self, socket] in
                    self.connectedSockets[port]?[socket.socketfd] = nil
                }
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                if self.continueRunning {
                    print("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
}
