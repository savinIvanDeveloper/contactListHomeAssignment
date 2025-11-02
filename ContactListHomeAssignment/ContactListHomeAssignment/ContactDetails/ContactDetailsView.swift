//
//  ContactDetailsView.swift
//  ContactListHomeAssignment
//
//  Created by Ivan Savin on 01.11.2025.
//

import SwiftUI

struct ContactDetailsView: View {
    
    @State
    var contact: ContactModel
    
    var favoriteToggle: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                prepareInfoSection(for: contact.phoneNumbers, title: "Phone numbers")
                prepareInfoSection(for: contact.emails, title: "Emails")
                favoriteButton
            }
            .padding([.leading, .bottom, .trailing], 16)
            .padding(.top, 24)
        }
    }
    
    // MARK: - Private

    private var headerView: some View {
        VStack {
            Image.initForContact(contact, size: 120)
            Text(contact.fullName)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func prepareInfoSection(
        for dataModels: [ContactModel.ContactProperty],
        title: String
    ) -> some View {
        if !dataModels.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                ForEach(dataModels, id: \.id) {
                    prepareInfoCellView(model: $0)
                }
            }
        }
    }
    
    private func prepareInfoCellView(model: ContactModel.ContactProperty) -> some View {
        HStack {
            HStack {
                Text(model.label)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .frame(width: 120)
            Text(model.value)
            Spacer()
        }
    }
    
    private var favoriteButton: some View {
        Button(
            contact.isFavorite ? "Remove from favorites" : "Add to favorites",
            systemImage: contact.isFavorite ? "star.fill" : "star"
        ) {
            favoriteToggle?()
            contact.isFavorite.toggle()
        }
    }
    
}

#Preview {
    let contact = ContactModel(
        id: UUID(),
        fullName: "Ivan Savin",
        phoneNumbers: [
            .init(label: "main", value: "+972557710758"),
            .init(label: "extra large title", value: "+77777777777")
        ],
        emails: [.init(label: "work", value: "savin.ivan.developer@gmail.com")],
        photo: nil,
        isFavorite: false
    )
    ContactDetailsView(contact: contact)
}
