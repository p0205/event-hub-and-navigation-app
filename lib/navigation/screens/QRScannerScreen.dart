import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:event_hub_and_navigation_app/models/qr_code_types.dart';
import 'package:event_hub_and_navigation_app/services/qr_code_handler_service.dart';
import 'package:event_hub_and_navigation_app/navigation/bloc/navigation_bloc.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool _isProcessing = false; // Add this flag
  String? _lastProcessedCode; // Add this to avoid duplicate processing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && !_isProcessing) {
        // Only process if we're not already processing and it's a different code
        if (_lastProcessedCode != scanData.code) {
          _lastProcessedCode = scanData.code;
          _processQRCode(scanData.code!);
        }
      }
    });
  }

  void _processQRCode(String qrData) {
  if (_isProcessing || !mounted) return;
  
  setState(() {
    _isProcessing = true;
  });

  // Pause camera to prevent multiple scans
  controller?.pauseCamera();

  try {
    print('🔍 [QRScanner] Processing QR code: $qrData');
    
    final QRCodeData? qrCodeData = QRCodeHandlerService.parseQRCode(qrData);

    if (qrCodeData != null) {
      print('✅ [QRScanner] QR code parsed successfully');
      
      _printQRCodeInfo(qrCodeData);

      if (qrCodeData.runtimeType == VenueQRCode) {
        print('📍 [QRScanner] Processing Venue QR Code');
      
        // Handle the venue QR code
        _handleVenueQRCode(qrCodeData as VenueQRCode);
        // Don't resume camera since we're navigating away
        
      } else if (qrCodeData.runtimeType == AttendanceQRCode) {
        print('📅 [QRScanner] Processing Attendance QR Code');
        _showAttendanceDialog(qrCodeData as AttendanceQRCode);
        
        // Resume camera after showing dialog
        _resumeCameraAfterDelay();
      } else {
        print('❓ [QRScanner] Unknown QR code type: ${qrCodeData.runtimeType}');
        _showError('Unsupported QR Code type');
        _resumeCameraAfterDelay();
      }
    } else {
      print('❌ [QRScanner] Failed to parse QR code');
      _showError('Invalid or unsupported QR Code format');
      _resumeCameraAfterDelay();
    }
  } catch (e) {
    print('💥 [QRScanner] Error processing QR Code: $e');
    _showError('Error processing QR Code: $e');
    _resumeCameraAfterDelay();
  }
}

void _resumeCameraAfterDelay() {
  // Resume camera after a delay to prevent immediate re-scanning
  Timer(Duration(seconds: 2), () {
    if (mounted && controller != null) {
      controller!.resumeCamera();
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _lastProcessedCode = null;
        });
      }
    }
  });
}

  void _handleVenueQRCode(VenueQRCode qrCodeData) {
    // Dispatch the event to navigation bloc
    final venueQR = qrCodeData;
    final qrData = {
      'id': venueQR.id,
      'name': venueQR.name,
      'coordinates': venueQR.coordinates,
      'floor_level': venueQR.floorLevel,
      'venue_id': venueQR.venueId,
      'node_id': venueQR.nodeId,
      'qr_code_id': venueQR.qrCodeId,
    };

    print('🚀 [QRScanner] Dispatching SelectSourceFromQR event...');
    context.read<NavigationBloc>().add(SelectSourceFromQR(qrData: qrData));

    // Return the data to home page and let it handle navigation
    print('🔙 [QRScanner] Returning QR data to home page...');
    Navigator.pop(context, {
      'type': 'venue',
      'data': qrData,
    });
  }

  void _printQRCodeInfo(QRCodeData qrCodeData) {
    print('=== QR Code Information ===');
    print('Type: ${qrCodeData.type}');
    print('ID: ${qrCodeData.id}');

    switch (qrCodeData.runtimeType) {
      case VenueQRCode:
        final venueQR = qrCodeData as VenueQRCode;
        print('Venue Name: ${venueQR.name}');
        print('Floor Level: ${venueQR.floorLevel}');
        print(
            'Coordinates: (${venueQR.coordinates['x']}, ${venueQR.coordinates['y']})');
        break;

      case AttendanceQRCode:
        final attendanceQR = qrCodeData as AttendanceQRCode;
        print('Event: ${attendanceQR.eventName}');
        print('Session: ${attendanceQR.sessionName}');
        print('Time: ${attendanceQR.startTime} - ${attendanceQR.endTime}');
        break;
    }
    print('========================');
  }

  void _showAttendanceDialog(AttendanceQRCode attendanceQR) {
    print(
        '📋 [QRScanner] Showing attendance dialog for event: ${attendanceQR.eventName}');

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event: ${attendanceQR.eventName}'),
              Text('Session: ${attendanceQR.sessionName}'),
              Text(
                  'Time: ${attendanceQR.startTime.toString().substring(11, 16)} - ${attendanceQR.endTime.toString().substring(11, 16)}'),
              if (attendanceQR.venueName != null)
                Text('Venue: ${attendanceQR.venueName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('❌ [QRScanner] Attendance marking cancelled');
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                print(
                    '✅ [QRScanner] Marking attendance for event: ${attendanceQR.eventName}');
                // TODO: Implement attendance marking logic
                _showSuccess('Attendance marked successfully!');

                // Close dialog first
                Navigator.of(context).pop();

                // Then close QR scanner and return to previous screen
                print(
                    '🔙 [QRScanner] Closing QR scanner after attendance marking');
                Navigator.of(context).pop(); // Close QR scanner
              },
              child: Text('Mark Attendance'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    // QRViewController is auto-disposed when QRView is unmounted
    super.dispose();
  }
}
