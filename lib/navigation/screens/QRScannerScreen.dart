import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:event_hub_and_navigation_app/models/qr_code_types.dart';
import 'package:event_hub_and_navigation_app/services/qr_code_handler_service.dart';
import 'package:event_hub_and_navigation_app/navigation/bloc/navigation_bloc.dart';
import 'package:event_hub_and_navigation_app/navigation/screens/navigation_screen.dart';

import '../../common_widget/navigation_provider.dart';

class QRScannerScreen extends StatefulWidget {
  
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

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
      if (scanData.code != null) {
        _processQRCode(scanData.code!);
      }
    });
  }

  void _processQRCode(String qrData) {
    try {
      // Use the new QR code handler service
      final QRCodeData? qrCodeData = QRCodeHandlerService.parseQRCode(qrData);
      
      if (qrCodeData != null) {
        // Print QR code information
        _printQRCodeInfo(qrCodeData);
        
        // Handle the QR code based on its type
        QRCodeHandlerService.handleQRCode(qrCodeData, navigationBloc: context.read<NavigationBloc>());
        

       _navigateToNavigationScreen();
      } else {
        _showError('Invalid or unsupported QR Code format');
      }
    } catch (e) {
      _showError('Error processing QR Code: $e');
    }
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
        print('Coordinates: (${venueQR.coordinates['x']}, ${venueQR.coordinates['y']})');
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



    void _navigateToNavigationScreen() {
    // Navigate to navigation screen using NavigationProvider
    // This switches to the navigation tab (page 2) and closes the QR scanner
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.setPage(2);                              
    Navigator.pop(context); // Close the QR scanner
  }

  void _showAttendanceDialog(AttendanceQRCode attendanceQR) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event: ${attendanceQR.eventName}'),
              Text('Session: ${attendanceQR.sessionName}'),
              Text('Time: ${attendanceQR.startTime.toString().substring(11, 16)} - ${attendanceQR.endTime.toString().substring(11, 16)}'),
              if (attendanceQR.venueName != null)
                Text('Venue: ${attendanceQR.venueName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement attendance marking logic
                _showSuccess('Attendance marked successfully!');
                Navigator.of(context).pop();
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
