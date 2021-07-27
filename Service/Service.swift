//
//  Service.swift
//  Service
//
//  Created by Tim Wolff on 06/11/2020.
//  Copyright © 2020 Tim Wolff. All rights reserved.
//

import Foundation
import PhoAggregateDoseServicesLib
import PhoCoreEventsLib
import CodableXPC


public class Service {
    private let connection: NSXPCConnection
    
    public init() {
        connection = NSXPCConnection(serviceName: "com.PhoHale.dev.PhoNotesAgent")
        connection.remoteObjectInterface = NSXPCInterface(with: PhoNotesAgentProtocol.self)

//		let prevAllowedClasses = connection.remoteObjectInterface?.classes(for: <#T##Selector#>, argumentIndex: <#T##Int#>, ofReply: <#T##Bool#>)
//		connection.remoteObjectInterface?.setClasses(<#T##classes: Set<AnyHashable>##Set<AnyHashable>#>, for: <#T##Selector#>, argumentIndex: <#T##Int#>, ofReply: <#T##Bool#>)
        connection.resume()
    }
    
    public func upperCase(aString: String, reply: @escaping (String) -> Void) {
        let service = connection.remoteObjectProxyWithErrorHandler { (error) in
            print(error)
        } as! PhoNotesAgentProtocol
        
        service.upperCaseString(aString, withReply: reply)
    }


	public func parseText(noteDayDate: Date, noteText: String, reply: @escaping ([Record]) -> Void) {
		let service = connection.remoteObjectProxyWithErrorHandler { (error) in
			print(error)
		} as! PhoNotesAgentProtocol

		service.parseText(noteDayDate: noteDayDate, noteText: noteText) { (returned_data) in
			guard let validObject = returned_data else {
				print("return nil")
				reply([])
				return
			}

			// we're OK to parse!
			let decoder = JSONDecoder()
			guard let validLoadedParsedRecordsArray = try? decoder.decode(Array<Record>.self, from: validObject) else {
				debugPrint("Warning: loaded data but couldn't decode from json!")
				print("return nil")
				reply([])
				return
			}


//			let decodedObject = try! XPCDecoder.decode(Array<Record>.self, message: validObject)
			print("validLoadedParsedRecordsArray: \(validLoadedParsedRecordsArray)")
			reply(validLoadedParsedRecordsArray)



		}

	}



}
