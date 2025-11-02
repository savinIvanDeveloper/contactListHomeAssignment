//
//  ContactListViewModel.swift
//  ContactListHomeAssignment
//
//  Created by Ivan Savin on 31.10.2025.
//

import Foundation
import SwiftUI

final class ContactListViewModel: ObservableObject {
    private let contactsManager: ContactsManagerInterface
    
    @Published
    private var contacts: [ContactModel] = []
    
    @Published
    var searchText: String = ""
    
    @Published
    var isContactsAccessGranted: Bool = false
    
    @Published
    var selectedContact: ContactModel?

    var filteredContacts: [ContactModel] {
        updateFilteredContacts()
    }
    
    init(contactsManager: ContactsManagerInterface) {
        self.contactsManager = contactsManager
    }
    
    func fetchContacts() {
        let status = contactsManager.getCurrentAccessStatus()
        isContactsAccessGranted = status == .authorized
        switch status {
        case .authorized:
            Task { await fetch() }
        case .notDetermined:
            Task {
                await requestAccess()
                await fetch()
            }
        default: break
        }
    }
    
    func toggleContactFavorite(by id: UUID) {
        guard let index = contacts.firstIndex(where: { $0.id == id }) else {
            return
        }
        contacts[index].isFavorite.toggle()
        contactsManager.toggleContactFavorite(by: id)
    }
    
    // MARK: - Private
    
    private func fetch() async {
        let contacts = await contactsManager.getContacts()
        await MainActor.run { [weak self] in
            self?.contacts = contacts.sorted { $0.fullName < $1.fullName }
        }
    }
    
    private func requestAccess() async {
        let isGranted = await contactsManager.requestAccess()
        await MainActor.run { [weak self] in
            self?.isContactsAccessGranted = isGranted
        }
    }
    
    private func updateFilteredContacts() -> [ContactModel] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.fullName.localizedCaseInsensitiveContains(searchText) ||
                contact.emails.contains { $0.value.localizedCaseInsensitiveContains(searchText) } ||
                contact.phoneNumbers.contains { $0.value.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
}
