//
//  ContactListView.swift
//  ContactListHomeAssignment
//
//  Created by Ivan Savin on 31.10.2025.
//

import SwiftUI

struct ContactListView: View {
    @ObservedObject
    var viewModel: ContactListViewModel

    var body: some View {
        NavigationView {
            ZStack {
                contentView
                placeholderView
            }
            .navigationTitle("Contacts List")
            .sheet(item: $viewModel.selectedContact) { contact in
                ContactDetailsView(
                    contact: contact,
                    favoriteToggle: {
                        viewModel.toggleContactFavorite(by: contact.id)
                    }
                )
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Private
    
    private var contentView: some View {
        List {
            ForEach(viewModel.filteredContacts, id: \.id) { contact in
                prepareContactView(for: contact)
            }
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(
                displayMode: .always
            )
        )
        .task {
            viewModel.fetchContacts()
        }
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        if !viewModel.isContactsAccessGranted || viewModel.filteredContacts.isEmpty {
            let title = !viewModel.isContactsAccessGranted ? "Contacts access denied" : "Empty result"
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Text(title)
                    .font(.title)
                if !viewModel.isContactsAccessGranted {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
    }
    
    private func prepareContactView(for contact: ContactModel) -> some View {
        HStack {
            Image.initForContact(contact)
            VStack(alignment: .leading) {
                Text(contact.fullName)
                    .font(.headline)
                if let phoneNumber = contact.phoneNumbers.first?.value {
                    Text(phoneNumber)
                        .font(.footnote)
                        .foregroundStyle(Color(.systemGray))
                }
            }
            Spacer()
            Button {
                viewModel.toggleContactFavorite(by: contact.id)
            } label: {
                Image(systemName: contact.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(Color(.systemBlue))
            }
            .buttonStyle(.plain)
            .frame(height: 45)
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectedContact = contact
        }
    }
    
}

#Preview {
    ContactListView(
        viewModel: ContactListViewModel(
            contactsManager: MockContactsManager()
        )
    )
}
