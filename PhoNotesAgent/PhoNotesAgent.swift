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


	// loadedFolders: the main folders for the primary container
	fileprivate var loadedFolders: [AppleNotesFolder] = []

//	fileprivate var loadedFolderReferences: [FolderReference] = []

	// Allows lookup of the AppleNotesFolder from the FolderReference a client provides
	fileprivate var loadedFolderReverseLookupMap: [FolderReference:AppleNotesFolder] = [:]

	fileprivate func performUpdatedLoadedFolders(_ newFolders: [AppleNotesFolder]) {
		self.loadedFolderReverseLookupMap.removeAll(keepingCapacity: true)
		self.loadedFolders.removeAll(keepingCapacity: true)

		// Rebuild the array of loaded folders and the reverse lookup map
		for aNewFolder in newFolders {
			self.loadedFolders.append(aNewFolder)
			// builds a folder reference to return
			self.loadedFolderReverseLookupMap[FolderReference(appleNotesFolder: aNewFolder)] = aNewFolder
		}
		//TODO: can issue a notification in the future if wanted.
	}

	////////////////////////////////////////////////////////////////////
	//MARK: -
	//MARK: - Apple Notes Loading
	// appleNotesProvider is the primary data model for the folder/notes
	@objc fileprivate dynamic var appleNotesProvider: AppleNotesProvider = AppleNotesProvider(withOperationMode: .Database)
	// We keep track of the pending work item as a property
	private var pendingNotesConnectionRequestWorkItem: DispatchWorkItem? = nil

	//TODO: not called
	fileprivate func startConnectingToAppleNotesProvider() {
		//NOTE: asynchronous
		self.pendingNotesConnectionRequestWorkItem?.cancel()
		// Wrap our request in a work item
		let requestWorkItem = DispatchWorkItem { [weak self] in
			guard let validSelf = self else {
				fatalError()
			}
			let foundFolders = validSelf.appleNotesProvider.getFoldersList()
			validSelf.performUpdatedLoadedFolders(foundFolders)
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
				self.performUpdatedLoadedFolders(foundFolders)
			}

		} 	// End callback.

	} // end function



	func getNotesFolderList(withReply reply: @escaping (Data?) -> Void) {
		//TODO: user the work item
		let foundFolders = self.appleNotesProvider.getFoldersList() // [AppleNotesFolder]
		self.performUpdatedLoadedFolders(foundFolders)

		// Convert to [FolderReference]'s
//		let folderReferences = foundFolders.map({ FolderReference(appleNotesFolder: $0) }) // [FolderReference]

		let folderReferences = Array(self.loadedFolderReverseLookupMap.keys)  // [FolderReference]

		// Encode to data
		guard let newJsonData = EncodableImportExportHelper.getEncodedData(arrayOfEncodables: folderReferences) else {
			print("Failed to encode [FolderReference] array!")
			reply(nil)
			return
		}
		print("Successfully encoded [FolderReference] array as Data!")
		reply(newJsonData)
	}



	func getNotesFolderList(childrenOf parentFolder: FolderReference, withReply reply: @escaping (Data?) -> Void) {
		// find the AppleNotesFolder
		guard let appleNotesFolder = self.loadedFolderReverseLookupMap[parentFolder] else {
			// This really shouldn't happen, as we passed the record back
			print("WARNING: Couldn't get parentFolder from reverse lookup map. This really shouldn't happen!")
			reply(nil)
			return
		}

		do {
			guard let foundSubFolders = try self.appleNotesProvider.getSubfolders(ofFolder: appleNotesFolder) else {
				print("found no subfolders")
				reply(nil)
				return
			} // [AppleNotesFolder]

			self.performUpdatedLoadedFolders(foundSubFolders)

			// Convert to [FolderReference]'s
			let folderReferences = self.loadedFolderReverseLookupMap.compactMap({ $0.key })
			// Encode to data
			guard let newJsonData = EncodableImportExportHelper.getEncodedData(arrayOfEncodables: folderReferences) else {
				print("Failed to encode [FolderReference] array!")
				reply(nil)
				return
			}
			print("Successfully encoded [FolderReference] array as Data!")
			reply(newJsonData)

		} catch let error {
			print("error: \(error)")
			reply(nil)
			return
		}

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
