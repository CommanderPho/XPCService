//
//  FolderReference.swift
//  Service
//
//  Created by Pho Hale on 7/27/21.
//  Copyright © 2021 Pho Hale. All rights reserved.
//

import Foundation
import PhoAppleNotesFramework


// MARK: -
// MARK: - FolderReference
// Description: A returned reference to a Notes folder with an internal specifier that can be used in future requests for notes
// 	Contains basic elements that a view controller requesting the folder might want to display, such as its name, number of children, children, etc.
@objcMembers
@objc(FolderReference) public final class FolderReference: NSObject, Codable, AppleNotesFolderBaseModelProtocol {

	public var id: String
	public var name: String

	public var containingPath: [String] // the parents path
	public var path: [String] // the path it represents

	public let numberOfChildren: Int

	////////////////////////////////////////////////////////////////////
	//MARK: -
	//MARK: - Initializers

	public init(id: String, name: String, containingPath: [String], path: [String], numberOfChildren: Int) {
		self.id = id
		self.name = name
		self.containingPath = containingPath
		self.path = path
		self.numberOfChildren = numberOfChildren
	}

	// Initialize from an AppleNotesFolder-type object
	public init(appleNotesFolder: AppleNotesFolder) {
		self.id = appleNotesFolder.id
		self.name = appleNotesFolder.name
		self.path = appleNotesFolder.path
		self.containingPath = appleNotesFolder.containingPath
		self.numberOfChildren = appleNotesFolder.folders.count
	}

}




