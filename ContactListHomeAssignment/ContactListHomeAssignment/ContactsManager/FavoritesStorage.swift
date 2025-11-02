//
//  FavoritesStorage.swift
//  ContactListHomeAssignment
//
//  Created by Ivan Savin on 02.11.2025.
//

import Foundation

final actor FavoritesStorage {
    private let fileName = "favorites"

    private var fileURL: URL? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            fileName
        )
    }

    func getFavoritesIds() async -> Set<UUID> {
        guard
            let fileURL
        else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            let favorites = try JSONDecoder().decode(Set<UUID>.self, from: data)
            return favorites
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func saveFavoritesIds(_ ids: Set<UUID>) async {
        guard let fileURL else { return }
        do {
            let data = try JSONEncoder().encode(ids)
            try data.write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}
