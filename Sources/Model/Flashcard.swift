//
//  Flashcard.swift
//  Flashcards
//

import Foundation

struct Flashcard: Identifiable, Codable {

    let id: String
    var front = ""
    var back = ""
    var gameData = GameData()

    init(id: String? = nil, front: String = "", back: String = "") {
        self.id = id ?? UUID().uuidString
        self.front = front
        self.back = back
    }

    enum Side: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {

        case front
        case back

        var id: Self { self }
        var description: String { rawValue.capitalized }

    }

    struct GameData: Codable {

        var input = ""
        var lastInput: String?
        var difficulty = 0

    }

    mutating func check() {
        gameData.lastInput = gameData.input
    }

    mutating func done() {
        gameData.input = ""
        gameData.lastInput = nil
    }

}