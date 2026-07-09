//
//  Model.swift
//  CozyCards
//
//  Created by Dinara Shakirova on 09/07/2026.
//

import SwiftData
import Foundation

@Model
final class WordCard {
    var id: UUID
    var term: String
    var definition: String
    var createdAt: Date

    var dictionary: WordDictionary?

    // определение картинкой
    // enum DefinitionType: String, Codable {
    //     case text
    //     case image
    // }
    // var definitionType: DefinitionType = .text
    // @Attribute(.externalStorage)
    // var definitionImageData: Data?

    init(term: String, definition: String, createdAt: Date = .now) {
        self.id = UUID()
        self.term = term
        self.definition = definition
        self.createdAt = createdAt
    }
}

@Model
final class WordDictionary {
    var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WordCard.dictionary)
    var cards: [WordCard] = []

    init(name: String, createdAt: Date = .now) {
        self.id = UUID()
        self.name = name
        self.createdAt = createdAt
    }
}

// Переименовано из `Chat` в `ChatSession`, чтобы не конфликтовать
// с моковым `struct Chat` в HistoryView.swift
@Model
final class ChatSession {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date

    @Attribute(.externalStorage)
    var transcriptData: Data?

    init(title: String, createdAt: Date = .now) {
        self.id = UUID()
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}
