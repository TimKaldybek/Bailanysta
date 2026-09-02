//
//  GameSectionConfig.swift
//  Bailanysta
//

/// Режим выбора тем внутри одной секции
enum SelectionMode {
    /// Одновременно активна только одна тема — секция «Посмейтесь вместе»
    case single
    /// Можно выбрать несколько тем — секция «Вопросы по душам»
    case multi
}

/// Конфиг одной игровой секции.
/// Чтобы добавить новую секцию — добавь новый элемент в GameSectionConfigBuilder.build(from:)
struct GameSectionConfig {
    let themeSection: ThemeSection
    let themes: [ThemeModel]
    let selectionMode: SelectionMode
    /// Какой игровой флоу запустить для этой секции
    let makeFlow: ([ThemeType]) -> MainFlowType
}

// MARK: - Builder

/// Собирает конфиги секций из бизнес-данных интерактора.
/// Чтобы добавить новую секцию — добавь новый GameSectionConfig в build(from:)
struct GameSectionConfigBuilder {
    func build(from data: CategoriesData) -> [GameSectionConfig] {
        [
            GameSectionConfig(themeSection: .deep, themes: data.deepThemes, selectionMode: .multi,  makeFlow: { .playGame($0) }),
            GameSectionConfig(themeSection: .fun,  themes: data.funThemes,  selectionMode: .single, makeFlow: { .playFunGame($0) }),
        ]
    }
}

// MARK: - Helpers

extension GameSectionConfig {
    var themeTypes: [ThemeType] { themes.map(\.type) }

    func contains(_ type: ThemeType) -> Bool {
        themeTypes.contains(type)
    }

    func contains(where predicate: (ThemeType) -> Bool) -> Bool {
        themeTypes.contains(where: predicate)
    }
}
