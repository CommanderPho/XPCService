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
import PhoAppleNotesFramework

// MARK: -
// MARK: - @objc class PhoNotesAgent: NSObject, PhoNotesAgentProtocol
// Description: Despite its name, this is the actual XPC Service
@objc class PhoNotesAgent: NSObject, PhoNotesAgentProtocol {

	////////////////////////////////////////////////////////////////////
	//MARK: -
	//MARK: - Apple Notes Loading
	// appleNotesProvider is the primary data model for the folder/notes
	@objc fileprivate dynamic var appleNotesProvider: AppleNotesProvider = AppleNotesProvider(withOperationMode: .Database)
	// We keep track of the pending work item as a property
	private var pendingNotesConnectionRequestWorkItem: DispatchWorkItem? = nil


	fileprivate func startConnectingToAppleNotesProvider() {
		self.pendingNotesConnectionRequestWorkItem?.cancel()
		// Wrap our request in a work item
		let requestWorkItem = DispatchWorkItem { [weak self] in
			guard let validSelf = self else {
				fatalError()
			}
			// Why does AppDelegate have a custom copy of the FSNotes storage?
			let foundFolders = validSelf.appleNotesProvider.getFoldersList()
//			AppDelegate.primaryModel.changeLoadedActiveFolders(to: foundFolders)

		}
		self.pendingNotesConnectionRequestWorkItem = requestWorkItem
		DispatchQueue.global(qos: .userInteractive).async(execute: requestWorkItem)
	}





	private func performInitialNotesLoadingRequest() {
		// start the process of getting all foldsers
		let ourRequest = RequestSpecifier.NotesFoldersRequest.all
		self.appleNotesProvider.request(ourRequest, requestOptions: AppleNotesFolderRequestCallbackConfig()) { aResult in
			// Completion handler
			print("complete!")
			switch aResult {
			case .failure(let error):
				fatalError("error: \(error.localizedDescription)")
			case .success(let foundFolders):
				// Found the apple notes folders
				print("found \(foundFolders.count) folders! Flattening them...")
				let flattendFolders = foundFolders.flatMap({ PhoAppleNotesFramework.getFlattenedFolders(folder: $0) })
				print("\t done. Flattened to \(flattendFolders.count) folders")
//				let amphFolderID = AmphDailyDoseLogConstants.getID(forOperationMode: .Database)
				let compareIsAmphFolderIDFcn = AmphDailyDoseLogConstants.getIDComparisonFunction(withOperationMode: self.appleNotesProvider.underlyingOperationMode)
//				let validFoundDoseLogFolder = flattendFolders.first(where: { $0.id.caseInsensitiveCompare(amphFolderID) == .orderedSame })
				guard let validFoundDoseLogFolder = flattendFolders.first(where: { compareIsAmphFolderIDFcn($0.id) }) else {
					fatalError("Failed to find a folder with the Daily Dose Log Folder id in flattened folders!")
				}
				print("Success! Found a validDoseLogFolder with name \(validFoundDoseLogFolder.name) and ID \(validFoundDoseLogFolder.id)")
//				} // end .measure
				print("done")
//				self.on_end_fetch_folders(fetchedFolders: foundFolders) // do the normal thing


			}

		} 	// End callback.

	} // end function



	func getNotesFolderList(withReply reply: @escaping (Data?) -> Void) {
		let foundFolders = self.appleNotesProvider.getFoldersList() // [AppleNotesFolder]
		// Convert to [FolderReference]'s
		let folderReferences = foundFolders.map({ FolderReference(appleNotesFolder: $0) }) // [FolderReference]

//		do {
//			try self.appleNotesProvider.getSubfolders(ofFolder: <#T##AppleNotesFolder#>)
//
//		} catch <#pattern#> {
//			<#statements#>
//		}


		//TODO: should we keep a map of [FolderReference:AppleNotesFolder] or something? How does the requester go about getting children?

		// Encode to data
		guard let newJsonData = EncodableImportExportHelper.getEncodedData(arrayOfEncodables: folderReferences) else {
			print("Failed to encode [FolderReference] array!")
			reply(nil)
			return
		}
		print("Successfully encoded [FolderReference] array as Data!")
		reply(newJsonData)
	}





	////////////////////////////////////////////////////////////////////
	//MARK: -
	//MARK: - Simple Note Text Parsing

	func parseText(noteDayDate: Date, noteText: String, withReply reply: @escaping (Data?) -> Void) {
		let resultArray = PhoNotesLib.performParse(noteDayDate: noteDayDate, noteText: noteText) // [CombinedLineParseResult]
		let flatRecordResultsArray = resultArray.compactMap({ $0.0 }) // [Record] //TODO: currently only returns [Record] objects
		guard let newJsonData = EncodableImportExportHelper.getEncodedData(arrayOfEncodables: flatRecordResultsArray) else {
			print("Failed to encode [Record] array!")
			reply(nil)
			return
		}
		print("Successfully encoded [Record] array as Data!")
		reply(newJsonData)
	}

    func upperCaseString(_ aString: String, withReply reply: @escaping (String) -> Void) {
        reply(aString.uppercased())
    }

}
