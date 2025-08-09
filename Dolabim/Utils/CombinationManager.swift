
import UIKit

class CombinationManager {
    static let shared = CombinationManager()
    private let key = "savedCombinations"

    func saveCombination(_ combination: Combination) {
        var combinations = loadCombinations()
        combinations.append(combination)
        persist(combinations)
    }

    func loadCombinations() -> [Combination] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let combinations = try? JSONDecoder().decode([Combination].self, from: data) else {
            return []
        }
        return combinations
    }

    func deleteCombination(_ combination: Combination) {
        var combinations = loadCombinations()
        combinations.removeAll { $0.id == combination.id }
        persist(combinations)
    }

    private func persist(_ combinations: [Combination]) {
        if let data = try? JSONEncoder().encode(combinations) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
