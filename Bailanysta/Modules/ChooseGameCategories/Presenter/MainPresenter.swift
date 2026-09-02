//
//  MainPresenter.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 08.11.2024.
//

final class MainPresenter {

    /// Результат нажатия на кнопку Continue:
    /// либо переход в игровой флоу, либо показ ошибки пользователю
    enum ContinueResult {
        case flow(MainFlowType)
        case error(title: String, message: String)
    }

    /// Эффект на UI после выбора темы:
    /// либо перерисовка затронутых ячеек, либо показ алерта (например, при смешении секций)
    enum ThemeSelectionEffect {
        case reconfigure([ThemeType])
        case alert(title: String, message: String)
    }

    private let interactor: MainInteractor
    private let configBuilder: GameSectionConfigBuilder

    private var sectionConfigs: [GameSectionConfig] = []
    private var articleItems: [ArticleItem] = []
    private var selectedTip: RelationshipTip?
    private var themeModels: [ThemeType: ThemeModel] = [:]

    init(interactor: MainInteractor, configBuilder: GameSectionConfigBuilder) {
        self.interactor    = interactor
        self.configBuilder = configBuilder
    }

    /// Загружает данные и подготавливает состояние. Вызывай из viewDidLoad через Task.
    func load() async {
        let data       = await interactor.fetchCategories()
        sectionConfigs = configBuilder.build(from: data)
        articleItems   = data.articles
        selectedTip    = data.tips.randomElement()
        themeModels    = Dictionary(
            uniqueKeysWithValues: sectionConfigs.flatMap(\.themes).map { ($0.type, $0) }
        )
    }

    // MARK: - Public

    func items(for section: ThemeSection) -> [SectionItem] {
        switch section {
        case .quickGame:
            return [.quickGame]
        case .articles:
            return articleItems.map { .article($0) }
        case .tip:
            guard let tip = selectedTip else { return [] }
            return [.tip(tip)]
        case .deep, .fun:
            return config(for: section)?.themes.map { .theme($0.type) } ?? []
        }
    }

    func quickGame() -> ContinueResult {
        let deepTypes = sectionConfigs.first { $0.themeSection == .deep }?.themeTypes ?? []

        guard let random = deepTypes.randomElement() else {
            return .error(title: "Alert.MixedSection.Title".localized, message: "Alert.MixedSection.Message".localized)
        }

        return .flow(.playGame([random]))
    }

    func model(for type: ThemeType) -> ThemeModel? {
        themeModels[type]
    }

    func select(type: ThemeType) -> ThemeSelectionEffect {
        guard let idx = sectionConfigs.firstIndex(where: { $0.contains(type) }) else {
            return .reconfigure([type])
        }

        let hasCrossSelection = sectionConfigs.indices
            .filter { $0 != idx }
            .contains { hasSelection(in: sectionConfigs[$0]) }

        if hasCrossSelection {
            return .alert(
                title: "Alert.MixedSection.Title".localized,
                message: "Alert.MixedSection.Message".localized
            )
        }

        switch sectionConfigs[idx].selectionMode {
        case .single: return applySingleSelection(type, in: sectionConfigs[idx])
        case .multi:  return applyMultiSelection(type)
        }
    }

    func resolveOnContinue() -> ContinueResult {
        let selected = selectedThemes()
        if let error = validateNotEmpty(selected)     { return error }
        if let error = validateSubscription(selected) { return error }

        return buildFlow(from: selected)
    }
}

// MARK: - Private

private extension MainPresenter {

    func config(for section: ThemeSection) -> GameSectionConfig? {
        sectionConfigs.first { $0.themeSection == section }
    }

    func hasSelection(in config: GameSectionConfig) -> Bool {
        config.contains { themeModels[$0]?.isSelected == true }
    }

    func selectedThemes() -> [ThemeModel] {
        themeModels.values.filter { $0.isSelected }
    }

    func applySingleSelection(_ type: ThemeType, in config: GameSectionConfig) -> ThemeSelectionEffect {
        var changed = [type]
        if let previous = config.themeTypes.first(where: { $0 != type && themeModels[$0]?.isSelected == true }) {
            themeModels[previous]?.isSelected = false
            changed.append(previous)
        }
        themeModels[type]?.isSelected.toggle()

        return .reconfigure(changed)
    }

    func applyMultiSelection(_ type: ThemeType) -> ThemeSelectionEffect {
        themeModels[type]?.isSelected.toggle()

        return .reconfigure([type])
    }

    func validateNotEmpty(_ selected: [ThemeModel]) -> ContinueResult? {
        guard selected.isEmpty else { return nil }

        return .error(
            title: "ChooseCategoriesVC.ChooseCategory".localized,
            message: "ChooseCategoriesVC.ChooseCategoryBeforeStart".localized
        )
    }

    func validateSubscription(_ selected: [ThemeModel]) -> ContinueResult? {
        let withinFreeLimit = selected.count <= Constants.freeThemeLimit
        guard !SubscriptionManager.shared.isPremium() && !withinFreeLimit else { return nil }

        return .error(
            title: "ChooseCategoriesVC.BuyPremium".localized,
            message: "ChooseCategoriesVC.ChooseMoreThemesBuySubscr".localized
        )
    }

    func buildFlow(from selected: [ThemeModel]) -> ContinueResult {
        let selectedTypes = selected.map(\.type)
        let activeConfig  = sectionConfigs.first { hasSelection(in: $0) }
        let flow          = activeConfig?.makeFlow(selectedTypes) ?? .playGame(selectedTypes)

        return .flow(flow)
    }

    enum Constants {
        static let freeThemeLimit = 2
    }
}
