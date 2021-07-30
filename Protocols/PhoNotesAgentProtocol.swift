//
//  PhoNotesAgentProtocol.swift
//  Service
//
//  Created by Tim Wolff on 06/11/2020.
//  Copyright © 2020 Tim Wolff. All rights reserved.
//

import Foundation
import PhoAppleNotesFramework

/* TODO - 07/27/2021 11:31am

	- Note that this protocol is going to have to duplicate much of the AppleNotesFramework public functions if it wants to provide similar functionality.

	- Don't aim for drop-in compatibility with PhoAppleNotesFramework

	- There is a struct somewhere like "struct NotesFolderInfo" that is what I'm tryin gto mirror in FolderReference. The only reason I don't just return [AppleNotesFolder] is because it's not encodable :[, so the XPC service can't pass it back as Data?.
		- I realize that having to create a codable object (FolderReference below) actually is the kind of abstracted "folder specifier" type system that I was hoping to create in AppleNotesFramework's newest API anyway but didn't quite get to completing.
		- ?? Also, where is the newest AppleNotesFramework API defined? I remember it uses "(_ result: Result<[AppleNotesFolder], NotesFolderUpdatingError>) -> Void" type callbacks, and I see some use of it in PhoGuiEventRenderingLib. Is it defined as a protocol?
		- For folder at least, It's basically I think (see "AppleNotesFolderListProvider")
			public func getSubfolders() throws -> [AppleNotesFolder]?
			public func getSubfolders(ofFolder parentFolder: AppleNotesFolder) throws -> [AppleNotesFolder]?

	🔬 Observation: Part of the functionality of this XPC service is basically aiming to replace all direct access to PhoAppleNotesFramework. In many ways it seems that it should be part of PhoAppleNotesFramework.
				- It does also go slightly further in wanting to provide the cache/in-memory datasource level functionality that's currently implemented (and re-implemented/duplicated) in several independent places across the various notes projects.
					- Without this it would be functionally equivalent to the current solution, and the only benefits of converting it to an XPC solution is the automatic benefits of XPC (code isolation, modularity, etc).
	Goal: My initial goal of building a "service" is that it would run in the background and provide attachable/detachable access to my various frontend programs as needed, without duplicating in-memory stores and stuff.
				- an example use-case: it would load the folders and notes from the apple notes database using PhoAppleNotesFramework and then all Cocoa and CLI applications could request the list of folders to display, or the flattened list of notes, or perform a search, etc. There would be:
							- only one copy of the Notes.app sqlite3 database made (by the XPCService)
							- one source of truth for the current notes and folder lists
							- simplify fetching logic by fetching all notes/folders recurrsively on startup of the service without worrying about main-thread scheduling and such because it will be done in the background and only introduce a delay the first time it's requested, but be cached after that.
							- only need to fetch all notes/folders once
							- Provide a meaningful interface for creation/updating of notes/records/etc objects due to the single source of truth.
							- Allow various separate Cocoa/cli programs to be written modularly as well: for example:
									- I could make a MacOS status bar app that just displays the current curve value updated in real-time from the notes. This would need to do a multi-stage process of getting the current daily note, parsing it for records, passing these to the dose curve calculator, and then getting the results.
									- I could make a CLI script that allows querying for notes that match a given predicate and returning the list of results
*/




// MARK: -
// MARK: - @objc protocol PhoNotesAgentProtocol
// Description: The common protocol that both the XPC service and the framework that uses the service agree to commuicate by. Defines the public XPC api
@objc protocol PhoNotesAgentProtocol {

    func upperCaseString(_ aString: String, withReply reply: @escaping (String) -> Void)

	func parseText(noteDayDate: Date, noteText: String, withReply reply: @escaping (Data?) -> Void)


	////////////////////////////////////////////////////////////////////
	//MARK: -
	//MARK: - Note Loading Protocol
	func getNotesFolderList(withReply reply: @escaping (Data?) -> Void) // Returned Data is [FolderReference]
	func getNotesFolderList(childrenOf parentFolder: FolderReference, withReply reply: @escaping (Data?) -> Void) // Returned Data is [FolderReference]

	
	
//	func getNotes(forFolder folder: FolderReference, withReply reply: @escaping (Data?) -> Void) // Returned Data is [AppleNotesNote]

}





