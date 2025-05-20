// --- Data Models (Simplified for example) ---
class Event {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  final bool isRegistered; // Placeholder for user's registration status

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,

    this.isRegistered = false,
  });
}