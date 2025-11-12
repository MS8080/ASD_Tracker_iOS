import SwiftUI
import CoreData

class MedicationViewModel: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var todaysLogs: [MedicationLog] = []
    @Published var recentLogs: [MedicationLog] = []
    @Published var medicationsTakenToday: Int = 0
    @Published var medicationsMissedToday: Int = 0
    @Published var adherenceRate: Double = 0.0
    
    private let dataController = DataController.shared
    
    func loadMedications() {
        print("🔵 MedicationViewModel: Loading medications...")
        medications = dataController.fetchMedications(activeOnly: true)
        print("✅ MedicationViewModel: Loaded \(medications.count) medications")
    }
    
    func loadTodaysLogs() {
        print("🔵 MedicationViewModel: Loading today's logs...")
        todaysLogs = dataController.getTodaysMedicationLogs()
        calculateTodayStats()
        print("✅ MedicationViewModel: Loaded \(todaysLogs.count) logs")
    }
    
    func loadRecentLogs(limit: Int = 10) {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        recentLogs = dataController.fetchMedicationLogs(startDate: sevenDaysAgo, endDate: Date())
        calculateAdherenceRate()
    }
    
    func logMedication(
        medication: Medication,
        taken: Bool,
        skippedReason: String? = nil,
        sideEffects: String? = nil,
        effectiveness: Int16 = 0,
        mood: Int16 = 0,
        energyLevel: Int16 = 0,
        notes: String? = nil
    ) {
        _ = dataController.createMedicationLog(
            medication: medication,
            taken: taken,
            skippedReason: skippedReason,
            sideEffects: sideEffects,
            effectiveness: effectiveness,
            mood: mood,
            energyLevel: energyLevel,
            notes: notes
        )
        loadTodaysLogs()
        loadRecentLogs()
    }
    
    func createMedication(
        name: String,
        dosage: String? = nil,
        frequency: String,
        notes: String? = nil
    ) {
        _ = dataController.createMedication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            notes: notes
        )
        loadMedications()
    }
    
    func updateMedication(_ medication: Medication) {
        dataController.updateMedication(medication)
        loadMedications()
    }
    
    func deleteMedication(_ medication: Medication) {
        dataController.deleteMedication(medication)
        loadMedications()
    }
    
    func deleteMedicationLog(_ log: MedicationLog) {
        dataController.deleteMedicationLog(log)
        loadTodaysLogs()
        loadRecentLogs()
    }
    
    private func calculateTodayStats() {
        medicationsTakenToday = todaysLogs.filter { $0.taken }.count
        medicationsMissedToday = todaysLogs.filter { !$0.taken }.count
    }
    
    private func calculateAdherenceRate() {
        let totalLogs = recentLogs.count
        guard totalLogs > 0 else {
            adherenceRate = 0.0
            return
        }
        
        let takenCount = recentLogs.filter { $0.taken }.count
        adherenceRate = Double(takenCount) / Double(totalLogs)
    }
    
    func refresh() {
        loadMedications()
        loadTodaysLogs()
        loadRecentLogs()
    }
    
    func hasTakenToday(medication: Medication) -> Bool {
        return todaysLogs.contains(where: { log in
            log.taken && log.medication.objectID == medication.objectID
        })
    }
}
