//
//  main.swift
//  PhoNotesAgent
//
//  Created by Tim Wolff on 06/11/2020.
//  Copyright © 2020 Tim Wolff. All rights reserved.
//

import Foundation

/* See https://rderik.com/blog/creating-a-launch-agent-that-provides-an-xpc-service-on-macos/
(1) We create a listener and (2) set its delegate object.

The delegate is in charge of accepting and setting up new incoming connections. Once our listener has a delegate, we call resume that will indicate to our listener to (3) start “listening” for connections.

*/



#if (false)

////////////////////////////////////////////////////////////////////
//MARK: -
//MARK: - Normal XPC Service version:


let delegate = ServiceDelegate()

let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
//RunLoop.main.run() // I don't seem to need this?


#else

////////////////////////////////////////////////////////////////////
//MARK: -
//MARK: - Launch Agent XPC Service version:

//class LaunchedServiceDelegate : NSObject, NSXPCListenerDelegate {
//	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
//		let exportedObject = PhoNotesAgent()
//		newConnection.exportedInterface = NSXPCInterface(with: PhoNotesAgentProtocol.self)
//		newConnection.exportedObject = exportedObject
//		newConnection.resume()
//		return true
//	}
//}


let delegate = ServiceDelegate()

//let listener = NSXPCListener.service() // Non-Launch Agent version
let listener = NSXPCListener(machServiceName: "com.PhoHale.PhoNotesAgentXPC") // Launch-agent version
listener.delegate = delegate
listener.resume()
RunLoop.main.run()



#endif












