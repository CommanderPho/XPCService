//
//  ServiceTests.swift
//  ServiceTests
//
//  Created by Tim Wolff on 06/11/2020.
//  Copyright © 2020 Tim Wolff. All rights reserved.
//

import XCTest
@testable import Service

class ServiceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testXPCService() {
        let textExpectation = expectation(description: "Recieve a string in upper case")
        
        let service = Service()
        service.upperCase(aString: "hello world") { (message) in
            XCTAssertEqual(message, "HELLO WORLD")
            textExpectation.fulfill()
        }
        
        wait(for: [textExpectation], timeout: 3.0)
    }




	func testXPCService_noteParsing() {
		let textExpectation = expectation(description: "Recieve a parsed array of records for the text")
		let testNoteText: String = """
			//soft-binge, second night

			//2:54 AM: Not sleeping. Talked to Kayla and she feels it's best to work on the wrong thing without pills (than to take pills and try to do the right thing).

			2:55 AM: 0.5+

			3:06 AM: 1.0+

			//3:06 AM: Kayla got me the pills upon my request. Unfortunately my previous delusion/spirit about diving head-first into the prelim stuff and learning all of neuroscience this week has lost its motivation.
		"""
		let testNoteDayDate = Date().startOfDay()

		let service = Service()
		service.parseText(noteDayDate: testNoteDayDate, noteText: testNoteText) { (records) in
			print("parseText finished with \(records)!")
			let recordCount = records.count
			XCTAssertNotEqual(recordCount, 0)
			textExpectation.fulfill()
		}
		wait(for: [textExpectation], timeout: 10.0)
	}





	func testXPCService_notesRootFoldersFetching() {
		let textExpectation = expectation(description: "Recieve a array of folders from Notes.app")
		let service = Service()
		service.getNotesFolderList(withReply: { (folderReferences) in
			print("getNotesFolderList finished with \(folderReferences)!")
			let recordCount = folderReferences.count
			XCTAssertNotEqual(recordCount, 0)
			textExpectation.fulfill()
		})

		wait(for: [textExpectation], timeout: 10.0)
	}



//	func testXPCService_notesSpecifiedFoldersFetching() {
//		let textExpectation = expectation(description: "Recieve a array of folders from Notes.app")
//		let testFolderName = "AMPH Daily Dose Record"
//
//		let service = Service()
//		service.getNotesFolderList(withReply: { (folderReferences) in
//			print("getNotesFolderList finished with \(folderReferences)!")
//			let recordCount = folderReferences.count
//			XCTAssertNotEqual(recordCount, 0)
//			textExpectation.fulfill()
//		})
//
//		wait(for: [textExpectation], timeout: 10.0)
//	}








}
