import CoreData
import Foundation

class DataController: ObservableObject {
    static let shared = DataController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BehaviorTrackerModel")
        
        print("🔵 DataController: Initializing with model name: BehaviorTrackerModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Enable lightweight migration
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        if !inMemory {
            container.persistentStoreDescriptions = [description]
        }
        
        print("🔵 DataController: About to load persistent stores...")

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Log the error but don't try to reload - this can cause deadlocks
                print("🔴 Core Data failed to load: \(error.localizedDescription)")
                print("🔴 Error details: \(error.userInfo)")
                
                // If you want to handle this, delete the store and restart the app
                // For now, we'll let it fail gracefully
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data store loaded successfully: \(storeDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        print("🔵 DataController: Initialization complete")
    }

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }

    func createPatternEntry(
        patternType: PatternType,
        intensity: Int16 = 0,
        duration: Int32 = 0,
        contextNotes: String? = nil,
        specificDetails: String? = nil
    ) -> PatternEntry {
        let entry = NSEntityDescription.insertNewObject(forEntityName: "PatternEntry", into: container.viewContext) as! PatternEntry
        entry.configure(
            patternType: patternType,
            intensity: intensity,
            duration: duration,
            contextNotes: contextNotes,
            specificDetails: specificDetails
        )
        save()
        return entry
    }

    func deletePatternEntry(_ entry: PatternEntry) {
        container.viewContext.delete(entry)
        save()
    }

    func fetchPatternEntries(
        startDate: Date? = nil,
        endDate: Date? = nil,
        category: PatternCategory? = nil
    ) -> [PatternEntry] {
        let request = NSFetchRequest<PatternEntry>(entityName: "PatternEntry")
        var predicates: [NSPredicate] = []

        if let startDate = startDate {
            predicates.append(NSPredicate(format: "timestamp >= %@", startDate as NSDate))
        }

        if let endDate = endDate {
            predicates.append(NSPredicate(format: "timestamp <= %@", endDate as NSDate))
        }

        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category.rawValue))
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        request.sortDescriptors = [NSSortDescriptor(keyPath: \PatternEntry.timestamp, ascending: false)]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch pattern entries: \(error.localizedDescription)")
            return []
        }
    }

    func getUserPreferences() -> UserPreferences {
        let request = NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
        request.fetchLimit = 1

        do {
            let results = try container.viewContext.fetch(request)
            if let preferences = results.first {
                return preferences
            } else {
                let newPreferences = NSEntityDescription.insertNewObject(forEntityName: "UserPreferences", into: container.viewContext) as! UserPreferences
                save()
                return newPreferences
            }
        } catch {
            print("Failed to fetch preferences: \(error.localizedDescription)")
            let newPreferences = NSEntityDescription.insertNewObject(forEntityName: "UserPreferences", into: container.viewContext) as! UserPreferences
            save()
            return newPreferences
        }
    }

    func updateStreak() {
        let preferences = getUserPreferences()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let request = NSFetchRequest<PatternEntry>(entityName: "PatternEntry")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PatternEntry.timestamp, ascending: false)]
        request.fetchLimit = 1

        do {
            let results = try container.viewContext.fetch(request)
            if let lastEntry = results.first {
                let lastEntryDate = calendar.startOfDay(for: lastEntry.timestamp)
                let daysDifference = calendar.dateComponents([.day], from: lastEntryDate, to: today).day ?? 0

                if daysDifference == 0 {
                    return
                } else if daysDifference == 1 {
                    preferences.streakCount += 1
                } else {
                    preferences.streakCount = 1
                }
            } else {
                preferences.streakCount = 1
            }
            save()
        } catch {
            print("Failed to update streak: \(error.localizedDescription)")
        }
    }

    // MARK: - Medication Management

    func createMedication(
        name: String,
        dosage: String? = nil,
        frequency: String,
        notes: String? = nil
    ) -> Medication {
        let medication = NSEntityDescription.insertNewObject(forEntityName: "Medication", into: container.viewContext) as! Medication
        medication.configure(
            name: name,
            dosage: dosage,
            frequency: frequency,
            notes: notes
        )
        save()
        return medication
    }

    func fetchMedications(activeOnly: Bool = true) -> [Medication] {
        let request = NSFetchRequest<Medication>(entityName: "Medication")

        if activeOnly {
            request.predicate = NSPredicate(format: "isActive == true")
        }

        request.sortDescriptors = [NSSortDescriptor(keyPath: \Medication.name, ascending: true)]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch medications: \(error.localizedDescription)")
            return []
        }
    }

    func updateMedication(_ medication: Medication) {
        save()
    }

    func deleteMedication(_ medication: Medication) {
        container.viewContext.delete(medication)
        save()
    }

    // MARK: - Medication Log Management

    func createMedicationLog(
        medication: Medication,
        taken: Bool = true,
        skippedReason: String? = nil,
        sideEffects: String? = nil,
        effectiveness: Int16 = 0,
        mood: Int16 = 0,
        energyLevel: Int16 = 0,
        notes: String? = nil
    ) -> MedicationLog {
        let log = NSEntityDescription.insertNewObject(forEntityName: "MedicationLog", into: container.viewContext) as! MedicationLog
        log.configure(
            medication: medication,
            taken: taken,
            skippedReason: skippedReason,
            sideEffects: sideEffects,
            effectiveness: effectiveness,
            mood: mood,
            energyLevel: energyLevel,
            notes: notes
        )
        save()
        return log
    }

    func fetchMedicationLogs(
        startDate: Date? = nil,
        endDate: Date? = nil,
        medication: Medication? = nil
    ) -> [MedicationLog] {
        let request = NSFetchRequest<MedicationLog>(entityName: "MedicationLog")
        var predicates: [NSPredicate] = []

        if let startDate = startDate {
            predicates.append(NSPredicate(format: "timestamp >= %@", startDate as NSDate))
        }

        if let endDate = endDate {
            predicates.append(NSPredicate(format: "timestamp <= %@", endDate as NSDate))
        }

        if let medication = medication {
            predicates.append(NSPredicate(format: "medication == %@", medication))
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicationLog.timestamp, ascending: false)]
        
        // Prefetch the medication relationship to avoid faulting issues
        request.relationshipKeyPathsForPrefetching = ["medication"]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch medication logs: \(error.localizedDescription)")
            return []
        }
    }

    func deleteMedicationLog(_ log: MedicationLog) {
        container.viewContext.delete(log)
        save()
    }

    func getTodaysMedicationLogs() -> [MedicationLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return fetchMedicationLogs(startDate: startOfDay, endDate: endOfDay)
    }
}
