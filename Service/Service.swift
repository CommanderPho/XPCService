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


public class Service {
    private let connection: NSXPCConnection
    
    public init() {
        connection = NSXPCConnection(serviceName: "com.PhoHale.dev.PhoNotesAgent")
        connection.remoteObjectInterface = NSXPCInterface(with: PhoNotesAgentProtocol.self)
        connection.resume()
    }
    
    public func upperCase(aString: String, reply: @escaping (String) -> Void) {
        let service = connection.remoteObjectProxyWithErrorHandler { (error) in
			print("❗️Received error:", error)
        } as! PhoNotesAgentProtocol
        
        service.upperCaseString(aString, withReply: reply)
    }


	public func parseText(noteDayDate: Date, noteText: String, reply: @escaping ([Record]) -> Void) {
		let service = connection.remoteObjectProxyWithErrorHandler { (error) in
			print("❗️Received error:", error)
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
			print("validLoadedParsedRecordsArray: \(validLoadedParsedRecordsArray)")
			reply(validLoadedParsedRecordsArray)
		}

	}


	public func getNotesFolderList(childrenOf parentFolder: FolderReference? = nil, withReply reply: @escaping ([FolderReference]) -> Void) {
		// note if parentFolder is nil, the root folders are obtained
		let service = connection.remoteObjectProxyWithErrorHandler { (error) in
			print("❗️Received error:", error)
		} as! PhoNotesAgentProtocol

		// define the reply
		let dataReply: ((Data?) -> Void) = { (returned_data) in
			guard let validObject = returned_data else {
				print("return nil")
				reply([])
				return
			}
			// we're OK to parse!
			let decoder = JSONDecoder()
			guard let validLoadedParsedFolderReferenceArray = try? decoder.decode(Array<FolderReference>.self, from: validObject) else {
				debugPrint("Warning: loaded data but couldn't decode from json!")
				reply([])
				return
			}
			print("validLoadedParsedFolderReferenceArray: \(validLoadedParsedFolderReferenceArray)")
			reply(validLoadedParsedFolderReferenceArray)
		}


		if let validParentFolder = parentFolder {
			service.getNotesFolderList(childrenOf: validParentFolder, withReply: dataReply)
		}
		else {
			// Root folder is used
			service.getNotesFolderList(withReply: dataReply)
		}

	}




}
