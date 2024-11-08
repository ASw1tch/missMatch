//
//  MissMatchTests.swift
//  MissMatchTests
//
//  Created by Anatoliy Petrov on 26.10.24..
//

import XCTest
@testable import MissMatch

class ContactListViewModelTests: XCTestCase {
    
    var viewModel: ContactListViewModel!
    
    override func setUpWithError() throws {
        viewModel = ContactListViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testFetchContacts() {
        let viewModel = ContactListViewModel()
        let expectation = XCTestExpectation(description: "Fetch contacts")
        
        viewModel.fetchContacts { contactList in
            XCTAssertFalse(viewModel.contacts.isEmpty, "Contacts should not be empty after fetching.")
            XCTAssertFalse(viewModel.isLoading, "Loading state should be false after fetching.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testSortContactsForServer() {
        let viewModel = ContactListViewModel()
        let contacts = [Contact(identifier: "1", givenName: "John", familyName: "Doe", phoneNumbers: ["+123456789"], iLiked: false, itsMatch: false)]
        let contactList = viewModel.sortContactsForServer(userID: "TestUser", contacts: contacts)
        
        XCTAssertFalse(contactList.toAdd.isEmpty, "There should be contacts to add.")
    }
    
    func testCheckAndShowMatchScreen() {
        let viewModel = ContactListViewModel()
        
        let contact = Contact(identifier: "123", givenName: "Jane", familyName: "Smith", phoneNumbers: ["+123456789"], iLiked: false, itsMatch: false)
        viewModel.contacts = [contact]
        
        viewModel.contacts[0].itsMatch = true
        viewModel.showMatchView = true
        
        XCTAssertTrue(viewModel.contacts.first?.itsMatch ?? false, "Contact should have a match.")
        XCTAssertTrue(viewModel.showMatchView, "Match view should be shown.")
    }
    
    func testStartRegularUpdates() {
        let viewModel = ContactListViewModel()
        
        viewModel.startRegularUpdates(interval: 10)
        
        XCTAssertNotNil(viewModel.timer, "Timer should be started.")
    }
    
    func testSaveAndLoadContacts() {
        let viewModel = ContactListViewModel()
        let contact = Contact(identifier: "123", givenName: "John", familyName: "Doe", phoneNumbers: ["+123456789"], iLiked: false, itsMatch: false)
        viewModel.saveContactsToUD([contact])
        
        let loadedContacts = viewModel.loadContactsFromUD()
        XCTAssertNotNil(loadedContacts, "Contacts should be loaded from UserDefaults.")
        XCTAssertEqual(loadedContacts?.first?.identifier, "123", "Contact identifier should match.")
    }
}
