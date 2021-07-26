//
//  PhoNotesAgent.swift
//  PhoNotesAgent
//
//  Created by Tim Wolff on 06/11/2020.
//  Copyright © 2020 Tim Wolff. All rights reserved.
//

import Foundation
import PhoAggregateDoseServicesLib
import PhoCoreEventsLib
import PhoNotesParser
import PhoNotesLib
import CodableXPC


// MARK: -
// MARK: - @objc class PhoNotesAgent: NSObject, PhoNotesAgentProtocol
// Description: Despite its name, this is the actual XPC Service
@objc class PhoNotesAgent: NSObject, PhoNotesAgentProtocol {

	func parseText(noteDayDate: Date, noteText: String, withReply reply: @escaping (xpc_object_t?) -> Void) {
		let resultArray = PhoNotesLib.performParse(noteDayDate: noteDayDate, noteText: noteText) // [CombinedLineParseResult]

		let flatRecordResultsArray = resultArray.compactMap({ $0.0 }) // [Record]
		let payload = try! XPCEncoder.encode(flatRecordResultsArray)

		reply(payload)

//		for anItem in resultArray {
//			let payload = try! XPCEncoder.encode(anItem.0)
//
//		}


	}

    func upperCaseString(_ aString: String, withReply reply: @escaping (String) -> Void) {
        reply(aString.uppercased())
    }

}
