import Foundation
import SwiftData

@MainActor
final class DrawService {
    enum DrawError: LocalizedError {
        case notEnoughPeople
        case noValidAssignment

        var errorDescription: String? {
            switch self {
            case .notEnoughPeople:
                return String(localized: "draws.error.minimum_participants")
            case .noValidAssignment:
                return String(localized: "draws.error.no_valid_assignment")
            }
        }
    }

    func createDraw(for group: Group, in context: ModelContext) throws -> Draw {
        let people = group.persons
        guard people.count >= 3 else { throw DrawError.notEnoughPeople }
        guard let assignments = makeAssignments(for: people) else {
            throw DrawError.noValidAssignment
        }

        let now = Date()
        let draw = Draw(
            name: localizedFormat(
                NSLocalizedString("draws.generated_name", comment: ""),
                now.formatted(date: .abbreviated, time: .shortened)
            ),
            maxPrice: group.maxPrice
        )
        draw.date = now
        draw.group = group

        for (giverIndex, targetIndex) in assignments {
            draw.gifts.append(Gift(giver: people[giverIndex], target: people[targetIndex]))
        }

        context.insert(draw)
        try context.save()
        return draw
    }

    private func makeAssignments(for people: [Person]) -> [Int: Int]? {
        var assignments: [Int: Int] = [:]
        var usedTargets = Set<Int>()

        func candidates(for giver: Int) -> [Int] {
            people.indices.filter { target in
                target != giver &&
                !usedTargets.contains(target) &&
                !people[giver].noGift.contains(people[target].id)
            }.shuffled()
        }

        func assignRemaining() -> Bool {
            guard assignments.count < people.count else { return true }

            let unassignedGivers = people.indices.filter { assignments[$0] == nil }
            let nextGiver = unassignedGivers
                .map { ($0, candidates(for: $0)) }
                .min { $0.1.count < $1.1.count }

            guard let (giver, availableTargets) = nextGiver, !availableTargets.isEmpty else {
                return false
            }

            for target in availableTargets {
                assignments[giver] = target
                usedTargets.insert(target)

                if assignRemaining() { return true }

                assignments[giver] = nil
                usedTargets.remove(target)
            }

            return false
        }

        return assignRemaining() ? assignments : nil
    }
}
