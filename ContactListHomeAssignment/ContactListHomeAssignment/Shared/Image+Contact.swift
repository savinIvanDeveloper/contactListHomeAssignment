//
//  Image+Contact.swift
//  ContactListHomeAssignment
//
//  Created by Ivan Savin on 01.11.2025.
//

import SwiftUI

extension Image {
    static func initForContact(_ contact: ContactModel, size: CGFloat = 45) -> some View {
        let image: Image
        if let uiImage = UIImage(data: contact.photo ?? Data()) {
            image = Image(uiImage: uiImage)
        } else {
            image = Image(systemName: "person.fill")
        }
        return image
            .resizable()
            .frame(width: size, height: size)
            .scaledToFit()
            .background(Color(.systemFill))
            .clipShape(Circle())
    }
}
