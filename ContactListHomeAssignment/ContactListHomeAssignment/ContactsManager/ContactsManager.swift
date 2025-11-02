//
//  ContactsManager.swift
//  ContactListHomeAssignment
//
//  Created by Ivan Savin on 31.10.2025.
//

import Foundation
import Contacts
import SwiftUI


struct ContactModel: Identifiable {
    struct ContactProperty: Identifiable {
        let id = UUID()
        let label: String
        let value: String
    }
    let id: UUID
    let fullName: String
    let phoneNumbers: [ContactProperty]
    let emails: [ContactProperty]
    let photo: Data?
    var isFavorite: Bool
}

enum ContactAccessStatus {
    case notDetermined, denied, restricted, authorized
}

protocol ContactsManagerInterface {
    func requestAccess() async -> Bool
    func getCurrentAccessStatus() -> ContactAccessStatus
    func getContacts() async -> [ContactModel]
    func toggleContactFavorite(by id: UUID)
}

final class ContactsManager: ContactsManagerInterface {
    private let store = CNContactStore()
    private var favorites = Set<UUID>()
    private let favoritesStorage = FavoritesStorage()
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        store.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func requestAccess() async -> Bool {
        do {
            return try await store.requestAccess(for: .contacts)
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func getCurrentAccessStatus() -> ContactAccessStatus {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized, .limited: .authorized
        case .denied: .denied
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        @unknown default: .restricted
        }
    }

    func getContacts() async -> [ContactModel] {
        favorites = await favoritesStorage.getFavoritesIds()
        let keys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey
        ] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        var contacts = [ContactModel]()
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                contacts.append(self.mapContactToModel(contact))
            }
        } catch {
            print(error.localizedDescription)
        }
        return contacts
    }
    
    func toggleContactFavorite(by id: UUID) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        Task { [weak self] in
            guard let self else { return }
            await favoritesStorage.saveFavoritesIds(favorites)
        }
    }

    
    // MARK: - Private
    private func mapContactToModel(_ contact: CNContact) -> ContactModel {
        let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(
            in: CharacterSet(charactersIn: " ")
        )
        var phoneNumbers = [ContactModel.ContactProperty]()
        contact.phoneNumbers.forEach { labeledValue in
            phoneNumbers.append(
                .init(
                    label: CNLabeledValue<NSString>.localizedString(forLabel: labeledValue.label ?? "Phone").capitalized,
                    value: labeledValue.value.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: " \n"))
                )
            )
        }
        var emails = [ContactModel.ContactProperty]()
        contact.emailAddresses.forEach { labeledValue in
            emails.append(
                .init(
                    label: CNLabeledValue<NSString>.localizedString(forLabel: labeledValue.label ?? "Email").capitalized,
                    value: String(labeledValue.value)
                )
            )
        }
        return ContactModel(
            id: contact.id,
            fullName: fullName,
            phoneNumbers: phoneNumbers,
            emails: emails,
            photo: contact.thumbnailImageData,
            isFavorite: favorites.contains(contact.id)
        )
    }

}
