//
//  MockContactsManager.swift
//  ContactListHomeAssignment
//
//  Created by Ivan Savin on 31.10.2025.
//

import Foundation

final class MockContactsManager: ContactsManagerInterface {
    func getContacts() async -> [ContactModel] {
        return [
            .init(
                id: UUID(),
                fullName: "Ivan Savin",
                phoneNumbers: [
                    .init(label: "Personal", value: "+972557710758")
                ],
                emails: [
                    .init(label: "Work", value: "savin.ivan.developer@gmail.com")
                ],
                photo: nil,
                isFavorite: false
            ),
            .init(
                id: UUID(),
                fullName: "John Dow",
                phoneNumbers: [
                    .init(label: "Personal", value: "+77771234567")
                ],
                emails: [
                    .init(label: "Work", value: "real.work.email@gmail.com")
                ],
                photo: nil,
                isFavorite: false
            )
        ]
    }

    func requestAccess() async -> Bool { true }
    
    func getCurrentAccessStatus() -> ContactAccessStatus { .authorized }
    
    func toggleContactFavorite(by id: UUID) { }
    
}
