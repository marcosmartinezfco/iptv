import Foundation
import Observation

@Observable
@MainActor
final class CountryPreferencesStore {
    private static let storageKey = "defaultCountries"

    private let defaults: UserDefaults
    private(set) var defaultCountries: Set<String>

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaultCountries = Set(defaults.stringArray(forKey: Self.storageKey) ?? [])
    }

    func isDefault(_ country: String) -> Bool {
        defaultCountries.contains(country)
    }

    func toggleDefault(_ country: String) {
        if defaultCountries.contains(country) {
            defaultCountries.remove(country)
        } else {
            defaultCountries.insert(country)
        }
        defaults.set(Array(defaultCountries), forKey: Self.storageKey)
    }
}
