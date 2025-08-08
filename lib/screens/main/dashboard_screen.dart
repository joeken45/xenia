import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cgm_provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../widgets/cards/glucose_card.dart';
import '../../widgets/cards/device_status_card.dart';
import '../../widgets/charts/glucose_chart.dart';
import '../../widgets/common/custom_button.dart';
import '../../screens/device/device_setup_screen.dart';
import '../../utils/constants.dart';
import '../../models/glucose_reading.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeRange = '6H';
  final List<String> _timeRanges = ['3H', '6H', '12H', '24H'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CGMProvider>().loadGlucoseData();
      context.read<BluetoothProvider>().checkBluetoothStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildDeviceConnectionSection(),
              const SizedBox(height: 20),
              _buildGlucoseSection(),
              const SizedBox(height: 20),
              _buildChartSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '血糖監控',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateTime.now().toString().substring(0, 16),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Consumer<BluetoothProvider>(
          builder: (context, bluetoothProvider, _) {
            return Icon(
              bluetoothProvider.isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: bluetoothProvider.isConnected
                  ? AppColors.success
                  : Colors.grey,
              size: 24,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeviceConnectionSection() {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, _) {
        if (!bluetoothProvider.isConnected) {
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.sensors_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '尚未連接 CGM 設備',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '請連接您的血糖監測設備以開始監控',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: '開始設定',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeviceSetupScreen(),
                        ),
                      );
                    },
                    isExpanded: true,
                  ),
                ],
              ),
            ),
          );
        }

        return const DeviceStatusCard();
      },
    );
  }

  Widget _buildGlucoseSection() {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, _) {
        if (!bluetoothProvider.isConnected) {
          return const SizedBox.shrink();
        }

        return Consumer<CGMProvider>(
          builder: (context, cgmProvider, _) {
            if (cgmProvider.isLoading) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            return const GlucoseCard();
          },
        );
      },
    );
  }

  Widget _buildChartSection() {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, _) {
        if (!bluetoothProvider.isConnected) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '血糖趨勢',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildTimeRangeSelector(),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<CGMProvider>(
                  builder: (context, cgmProvider, _) {
                    if (cgmProvider.glucoseReadings.isEmpty) {
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timeline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '暫無數據',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    return SizedBox(
                      height: 250,
                      child: GlucoseChart(
                        glucoseReadings: _filterDataByTimeRange(
                          cgmProvider.glucoseReadings,
                        ),
                        timeRange: _selectedTimeRange,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _timeRanges.map((range) {
          final isSelected = range == _selectedTimeRange;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeRange = range;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<GlucoseReading> _filterDataByTimeRange(List<GlucoseReading> readings) {
    if (readings.isEmpty) return readings;

    final now = DateTime.now();
    int hours;

    switch (_selectedTimeRange) {
      case '3H':
        hours = 3;
        break;
      case '6H':
        hours = 6;
        break;
      case '12H':
        hours = 12;
        break;
      case '24H':
        hours = 24;
        break;
      default:
        hours = 6;
    }

    final cutoffTime = now.subtract(Duration(hours: hours));

    return readings.where((reading) {
      return reading.timestamp.isAfter(cutoffTime);
    }).toList();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<CGMProvider>().loadGlucoseData(),
      context.read<BluetoothProvider>().refreshConnection(),
    ]);
  }
}