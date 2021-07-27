//
//  PhoNotesAgent.swift
//  PhoNotesAgent
//
//  Created by Tim Wolff on 06/11/2020.
//  Copyright © 2020 Tim Wolff. All rights reserved.
//

import Foundation
import PhoAggregateDoseServicesLib
@testable import PhoEncodableImportExportLib
import PhoCoreEventsLib
import PhoNotesParser
import PhoNotesLib
import CodableXPC


// MARK: -
// MARK: - @objc class PhoNotesAgent: NSObject, PhoNotesAgentProtocol
// Description: Despite its name, this is the actual XPC Service
@objc class PhoNotesAgent: NSObject, PhoNotesAgentProtocol {

	func parseText(noteDayDate: Date, noteText: String, withReply reply: @escaping (Data?) -> Void) {
		let resultArray = PhoNotesLib.performParse(noteDayDate: noteDayDate, noteText: noteText) // [CombinedLineParseResult]

		let flatRecordResultsArray = resultArray.compactMap({ $0.0 }) // [Record]
//		let payload = try! XPCEncoder.encode(flatRecordResultsArray)

//		PhoEncodableImportExportLib.EncodableImportExportHelper.getEncodedData(arrayOfEncodables: flatRecordResultsArray)
		guard let newJsonData = EncodableImportExportHelper.getEncodedData(arrayOfEncodables: flatRecordResultsArray) else {
			print("Failed to encode [Record] array!")
			reply(nil)
			return
		}

		print("Successfully encoded [Record] array as Data!")
		reply(newJsonData)


//		for anItem in resultArray {
//			let payload = try! XPCEncoder.encode(anItem.0)
//
//		}


	}

    func upperCaseString(_ aString: String, withReply reply: @escaping (String) -> Void) {
        reply(aString.uppercased())
    }

}
