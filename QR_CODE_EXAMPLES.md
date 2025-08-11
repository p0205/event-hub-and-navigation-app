# QR Code Examples for Event Hub & Navigation App

This document provides examples of different QR code types that the app can handle, along with their data structures and use cases.

## QR Code Types

The app supports four main types of QR codes:

1. **Venue QR Codes** - For navigation and location purposes
2. **Attendance QR Codes** - For marking attendance at events/sessions
3. **Event QR Codes** - For displaying event information
4. **Session QR Codes** - For displaying session information

## 1. Venue QR Codes

**Purpose**: Set starting point for navigation, show venue information

**Data Structure**:
```json
{
  "type": "venue",
  "id": "venue_001",
  "name": "Main Auditorium",
  "coordinates": {
    "x": 150.5,
    "y": 200.0
  },
  "floor_level": 2,
  "venue_id": "backend_venue_123",
  "node_id": "nav_node_456",
  "qr_code_id": "qr_789"
}
```

**Alternative Format (without type field)**:
```json
{
  "id": "venue_001",
  "name": "Main Auditorium",
  "coordinates": {
    "x": 150.5,
    "y": 200.0
  },
  "floor_level": 2,
  "venue_id": "backend_venue_123",
  "node_id": "nav_node_456",
  "qr_code_id": "qr_789"
}
```

**App Behavior**: 
- Sets the scanned location as the starting point for navigation
- Automatically navigates to the navigation screen
- Dispatches SelectSourceFromQR event to NavigationBloc
- Can be used to navigate to other venues

## 2. Attendance QR Codes

**Purpose**: Mark attendance at specific events or sessions

**Data Structure**:
```json
{
  "type": "attendance",
  "id": "att_001",
  "eventId": 123,
  "eventName": "Tech Conference 2024",
  "sessionId": 456,
  "sessionName": "Opening Keynote",
  "startTime": "2024-01-15T09:00:00Z",
  "endTime": "2024-01-15T10:30:00Z",
  "venueName": "Main Auditorium",
  "qr_code_id": "qr_att_789"
}
```

**Alternative Format (without type field)**:
```json
{
  "id": "att_001",
  "eventId": 123,
  "eventName": "Tech Conference 2024",
  "sessionId": 456,
  "sessionName": "Opening Keynote",
  "startTime": "2024-01-15T09:00:00Z",
  "endTime": "2024-01-15T10:30:00Z",
  "venueName": "Main Auditorium",
  "qr_code_id": "qr_att_789"
}
```

**App Behavior**:
- Shows attendance confirmation dialog
- Displays event and session details
- Allows user to mark attendance
- Shows success message after marking attendance

## 3. Event QR Codes

**Purpose**: Display event information and details

**Data Structure**:
```json
{
  "type": "event",
  "id": "event_001",
  "eventName": "Tech Conference 2024",
  "description": "Annual technology conference featuring industry leaders",
  "startDateTime": "2024-01-15T09:00:00Z",
  "endDateTime": "2024-01-15T17:00:00Z",
  "organizer": "Tech Events Inc.",
  "qr_code_id": "qr_event_789"
}
```

**Alternative Format (without type field)**:
```json
{
  "id": "event_001",
  "eventName": "Tech Conference 2024",
  "description": "Annual technology conference featuring industry leaders",
  "startDateTime": "2024-01-15T09:00:00Z",
  "endDateTime": "2024-01-15T17:00:00Z",
  "organizer": "Tech Events Inc.",
  "qr_code_id": "qr_event_789"
}
```

**App Behavior**:
- Shows event details dialog
- Displays event information, timing, and organizer
- User can view details and close dialog

## 4. Session QR Codes

**Purpose**: Display session-specific information

**Data Structure**:
```json
{
  "type": "session",
  "id": "session_001",
  "sessionName": "Opening Keynote",
  "eventId": 123,
  "eventName": "Tech Conference 2024",
  "startDateTime": "2024-01-15T09:00:00Z",
  "endDateTime": "2024-01-15T10:30:00Z",
  "venueName": "Main Auditorium",
  "qr_code_id": "qr_session_789"
}
```

**Alternative Format (without type field)**:
```json
{
  "id": "session_001",
  "sessionName": "Opening Keynote",
  "eventId": 123,
  "eventName": "Tech Conference 2024",
  "startDateTime": "2024-01-15T09:00:00Z",
  "endDateTime": "2024-01-15T10:30:00Z",
  "venueName": "Main Auditorium",
  "qr_code_id": "qr_session_789"
}
```

**App Behavior**:
- Shows session details dialog
- Displays session and event information
- Shows timing and venue details

## QR Code Generation Guidelines

### Required Fields by Type

**Venue QR Codes**:
- `id` (string) - Unique identifier
- `name` (string) - Venue name
- `coordinates` (object) - X and Y coordinates
- `floor_level` (number) - Floor number

**Attendance QR Codes**:
- `id` (string) - Unique identifier
- `eventId` (number) - Event ID
- `eventName` (string) - Event name
- `sessionId` (number) - Session ID
- `sessionName` (string) - Session name
- `startTime` (string) - ISO 8601 datetime
- `endTime` (string) - ISO 8601 datetime

**Event QR Codes**:
- `id` (string) - Unique identifier
- `eventName` (string) - Event name
- `startDateTime` (string) - ISO 8601 datetime
- `endDateTime` (string) - ISO 8601 datetime

**Session QR Codes**:
- `id` (string) - Unique identifier
- `sessionName` (string) - Session name
- `eventId` (number) - Event ID
- `eventName` (string) - Event name
- `startDateTime` (string) - ISO 8601 datetime
- `endDateTime` (string) - ISO 8601 datetime

### Optional Fields

- `type` (string) - Explicitly specify QR code type
- `qr_code_id` (string) - Backend QR code identifier
- `venue_id` (string) - Backend venue identifier
- `node_id` (string) - Navigation node identifier
- `description` (string) - Event description
- `organizer` (string) - Event organizer
- `venueName` (string) - Venue name for events/sessions

### DateTime Format

Use ISO 8601 format for all datetime fields:
```
YYYY-MM-DDTHH:MM:SSZ
```

Example: `2024-01-15T09:00:00Z`

### Type Inference

If the `type` field is not provided, the app will automatically infer the QR code type based on the available fields:

1. **Venue**: Has `coordinates` and `floor_level`
2. **Attendance**: Has `eventId` and `sessionId`
3. **Event**: Has `eventName` and `startDateTime`
4. **Session**: Has `sessionName` and `eventId`

## Usage Examples

### For Event Organizers

1. **Create venue QR codes** for each location in your venue
2. **Create attendance QR codes** for each session
3. **Create event QR codes** for general event information
4. **Create session QR codes** for detailed session information

### For Attendees

1. **Scan venue QR codes** to set starting point for navigation
2. **Scan attendance QR codes** to mark attendance
3. **Scan event/session QR codes** to view details

### For Navigation

1. **Scan venue QR codes** to set source location
2. **App automatically navigates** to the navigation screen
3. **Use navigation system** to find route to destination
4. **Follow turn-by-turn instructions** to reach destination

### Automatic Navigation

When a venue QR code is scanned:
- The app automatically dispatches a `SelectSourceFromQR` event to the NavigationBloc
- The app switches to the navigation tab using NavigationProvider
- The scanned location is set as the starting point
- The QR scanner automatically closes
- No manual navigation is required

## Testing QR Codes

You can test the QR code functionality by:

1. **Generating QR codes** with the example JSON data above
2. **Using online QR code generators** like qr-code-generator.com
3. **Testing with the app** by scanning the generated QR codes
4. **Checking console logs** for parsed information
5. **Verifying app behavior** matches expected functionality

## Troubleshooting

### Common Issues

1. **Invalid JSON**: Ensure JSON is properly formatted
2. **Missing required fields**: Include all required fields for the QR code type
3. **Invalid datetime format**: Use ISO 8601 format for all datetime fields
4. **Type mismatch**: Ensure field types match expected types (string, number, etc.)

### Debug Information

The app provides detailed console logging for:
- QR code parsing results
- Type inference
- Field validation
- Error messages

Check the console output for debugging information when scanning QR codes.
