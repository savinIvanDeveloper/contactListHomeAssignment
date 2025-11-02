//
//  ContactListHomeAssignmentApp.swift
//  ContactListHomeAssignment
//
//  Created by Ivan Savin on 31.10.2025.
//

import SwiftUI

@main
struct ContactListHomeAssignmentApp: App {
    var body: some Scene {
        WindowGroup {
            ContactListView(
                viewModel: ContactListViewModel(
                    contactsManager: ContactsManager()
                )
            )
        }
    }
}
