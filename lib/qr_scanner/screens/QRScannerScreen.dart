import 'dart:async';

import 'package:event_hub_and_navigation_app/qr_scanner/bloc/qr_scanner_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:event_hub_and_navigation_app/models/qr_code_types.dart';
import 'package:event_hub_and_navigation_app/services/qr_code_handler_service.dart';
import 'package:event_hub_and_navigation_app/navigation/bloc/navigation_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';

class QRScannerScreen extends StatefulWidget {

  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  QRViewController? controller;
  int? _currentUserId;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool _isProcessing = false; // Add this flag
  String? _lastProcessedCode; // Add this to avoid duplicate processing

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      final authState = context.read<AuthBloc>().state;
      if (authState is AuthenticatedState) {
        _currentUserId = authState.user.id;
      }

    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<QrScannerBloc, QrScannerState>(
      listener: (context, state) {
        if (state is QRScannerLoading) {
          // You could show a loading indicator here if needed
        } else if (state is TakeAttendanceSuccess) {
          _showDialog('Success', state.message, () {
            // Optional: You could navigate or resume here
          });
        } else if (state is QRScannerError) {
          _showDialog('Error', state.error, () {
            // Optional: You could retry or navigate back
          });
        } else if (state is UserIsUnAuthenticatedState) {
          _showDialog('Unauthenticated', state.message, () {
            // Optional: You could navigate to the sign-in screen
          });
        }
      },
      child: Scaffold(
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
        _handleAttendanceQRCode(qrData);

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

        break;
    }
    print('========================');
  }

  void _handleAttendanceQRCode(String qrData) {

    context.read<QrScannerBloc>().add(TakeAttendanceEvent(userId: _currentUserId, qrPayloadString:qrData));


  }
  void _showDialog(String title, String content, Function onDismiss) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Pop the QRScannerScreen
                onDismiss();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      // Resume camera after dialog is dismissed
      _resumeCameraAfterDelay();
    });
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
