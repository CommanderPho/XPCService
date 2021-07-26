//
//  PhoNotesAgent.swift
//  PhoNotesAgent
//
//  Created by Tim Wolff on 06/11/2020.
//  Copyright © 2020 Tim Wolff. All rights reserved.
//

import Foundation
import PhoNotesLib


// MARK: -
// MARK: - @objc class PhoNotesAgent: NSObject, PhoNotesAgentProtocol
// Description: Despite its name, this is the actual XPC Service
@objc class PhoNotesAgent: NSObject, PhoNotesAgentProtocol {

	func parseText(_ text: String, withReply reply: @escaping (Data?) -> Void) {
		<#code#>
	}

    func upperCaseString(_ aString: String, withReply reply: @escaping (String) -> Void) {
        reply(aString.uppercased())
    }

}
