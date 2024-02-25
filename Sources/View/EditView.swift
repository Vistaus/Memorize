//
//  EditView.swift
//  Flashcards
//

import Adwaita

struct EditView: View {

    @Binding var set: FlashcardsSet
    @Binding var editMode: Bool
    @State private var expanded = false
    @State private var focusedFront: String?
    var app: GTUIApp
    var window: GTUIWindow

    var view: Body {
        ScrollView {
            VStack {
                title
                tags
                flashcards
                actions
            }
            .formWidth()
        }
        .vexpand()
        .topToolbar {
            HeaderBar(titleButtons: false) {
                ViewStack(element: set) { _ in
                    HStack {
                        Button(icon: .default(icon: .userTrash)) {
                            app.addWindow("delete-\(set.id)", parent: window)
                            editMode = false
                        }
                        Button(icon: .custom(name: "io.github.david_swift.Flashcards.share-symbolic")) {
                            app.addWindow("export-\(set.id)", parent: window)
                        }
                        .padding(10, .horizontal)
                    }
                }
            } end: {
                Button("Done") {
                    editMode = false
                }
                .style("suggested-action")
            }
            .headerBarTitle {
                WindowTitle(subtitle: "", title: "Edit Set")
            }
        }
    }

    var title: View {
        Form {
            EntryRow("Title", text: $set.name)
            KeywordsRow(keywords: $set.keywords.nonOptional)
        }
        .padding(20)
    }

    var tags: View {
        Form {
            KeywordsRow(
                keywords: $set.tags.nonOptional,
                title: "Tags",
                subtitle: "Organize and study flashcards in groups",
                element: "Tag"
            )
            SwitchRow()
                .title("Star")
                .subtitle("A special tag that can be set while studying")
                .active(
                    .init {
                        set.tags.nonOptional.contains("Star")
                    } set: { newValue in
                        if newValue && !set.tags.nonOptional.contains("Star") {
                            set.tags.nonOptional.append("Star")
                        } else {
                            set.tags.nonOptional = set.tags.nonOptional.filter { $0 != "Star" }
                        }
                    }
                )
        }
        .padding(20)
    }

    var flashcards: View {
        ForEach(.init(set.flashcards.indices)) { index in
            if set.flashcards[safe: index] != nil {
                EditFlashcardView(
                    flashcard: .init {
                        set.flashcards[safe: index] ?? .init()
                    } set: { newValue in
                        set.flashcards[safe: index] = newValue
                    },
                    index: index,
                    tags: set.tags.nonOptional,
                    focusedFront: focusedFront
                ) {
                    if let flashcard = set.flashcards[safe: index + 1] {
                        focusedFront = flashcard.id
                        focusedFront = nil
                    } else {
                        appendFlashcard()
                    }
                } delete: {
                    set.flashcards = set.flashcards.filter { $0.id != set.flashcards[safe: index]?.id }
                    Task {
                        try? await Task.sleep(nanoseconds: 100)
                        focusedFront = set.flashcards[safe: index - 1]?.id
                        focusedFront = nil
                    }
                }
            }
        }
        .padding()
    }

    var actions: View {
        PillButtonSet(
            primary: "Add Flashcard",
            icon: .default(icon: .listAdd),
            secondary: .default(icon: .folderDownload)
        ) {
            appendFlashcard()
        } secondary: {
            app.addWindow("import-\(set.id)", parent: window)
        }
    }

    func appendFlashcard() {
        let flashcard = Flashcard()
        set.flashcards.append(flashcard)
        Task {
            try? await Task.sleep(nanoseconds: 100)
            focusedFront = flashcard.id
            focusedFront = nil
        }
    }

}
