//
//  ServiceDelegate.swift
//  PhoNotesAgent
//
//  Created by Pho Hale on 7/30/21.
//  Copyright © 2021 Pho Hale. All rights reserved.
//

import Foundation



@objc class ServiceDelegate: NSObject, NSXPCListenerDelegate {
	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
		newConnection.exportedInterface = NSXPCInterface(with: PhoNotesAgentProtocol.self)
		newConnection.exportedObject = PhoNotesAgent()
		newConnection.resume()
		return true
	}
}
