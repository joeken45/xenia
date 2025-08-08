import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../providers/bluetooth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../utils/constants.dart';
import '../../generated/l10n.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  bool _isConnecting = false;
  String? _connectingDeviceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });
  }

  Future<void> _startScanning() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);

    if (!bluetoothProvider.isBluetoothOn) {
      _showErrorSnackBar('請先開啟藍牙');
      return;
    }

    try {
      await bluetoothProvider.startScanning(
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('掃描失敗: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('掃描 CGM 設備'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, _) {
              return IconButton(
                icon: Icon(
                  bluetoothProvider.isScanning ? Icons.stop : Icons.refresh,
                ),
                onPressed: bluetoothProvider.isScanning
                    ? () => bluetoothProvider.stopScanning()
                    : _startScanning,
              );
            },
          ),
        ],
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, _) {
          return Column(
            children: [
              _buildScanHeader(bluetoothProvider),
              Expanded(
                child: _buildDeviceList(bluetoothProvider),
              ),
              _buildBottomActions(bluetoothProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanHeader(BluetoothProvider bluetoothProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXL),
          bottomRight: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: Column(
        children: [
          if (bluetoothProvider.isScanning) ...[
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            const Text(
              '正在掃描附近的 CGM 設備...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Icon(
              bluetoothProvider.availableDevices.isNotEmpty
                  ? Icons.devices_outlined
                  : Icons.search_off,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              bluetoothProvider.availableDevices.isNotEmpty
                  ? '找到 ${bluetoothProvider.availableDevices.length} 個設備'
                  : '未找到 CGM 設備',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.paddingS),
          Text(
            bluetoothProvider.isScanning
                ? '請確保您的 CGM 設備已開啟並處於配對模式'
                : bluetoothProvider.availableDevices.isNotEmpty
                ? '選擇您要連接的設備'
                : '點擊重新掃描或檢查設備狀態',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BluetoothProvider bluetoothProvider) {
    if (bluetoothProvider.errorMessage != null) {
      return DeviceConnectionErrorWidget(
        onRetry: _startScanning,
      );
    }

    if (bluetoothProvider.availableDevices.isEmpty && !bluetoothProvider.isScanning) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _startScanning,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: bluetoothProvider.availableDevices.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSizes.paddingS),
        itemBuilder: (context, index) {
          final device = bluetoothProvider.availableDevices[index];
          return _buildDeviceCard(device, bluetoothProvider);
        },
      ),
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device, BluetoothProvider bluetoothProvider) {
    final isConnecting = _isConnecting && _connectingDeviceId == device.remoteId.toString();
    final deviceName = device.platformName.isNotEmpty ? device.platformName : '未知設備';

    return Card(
      elevation: 3,
      child: InkWell(
        onTap: isConnecting ? null : () => _connectToDevice(device, bluetoothProvider),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getDeviceTypeColor(device).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getDeviceTypeIcon(device),
                  color: _getDeviceTypeColor(device),
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      'ID: ${device.remoteId.toString().substring(0, 8)}...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDeviceTypeColor(device).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getDeviceTypeName(device),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getDeviceTypeColor(device),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '良好',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isConnecting)
                const SmallLoadingWidget()
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              '未找到 CGM 設備',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              '請確保您的 CGM 設備已開啟並處於配對模式',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingL),
            _buildTroubleshootingTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSizes.paddingM),
                Text(
                  '排除問題',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildTipItem('檢查 CGM 設備是否已開啟'),
            _buildTipItem('確保設備在 10 公尺範圍內'),
            _buildTipItem('重新啟動 CGM 設備'),
            _buildTipItem('檢查設備是否已與其他手機配對'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BluetoothProvider bluetoothProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!bluetoothProvider.isScanning && bluetoothProvider.availableDevices.isEmpty)
              CustomButton(
                text: '重新掃描',
                onPressed: _startScanning,
                icon: Icons.refresh,
              )
            else if (bluetoothProvider.isScanning)
              SecondaryButton(
                text: '停止掃描',
                onPressed: () => bluetoothProvider.stopScanning(),
                icon: Icons.stop,
              )
            else
              SecondaryButton(
                text: '重新掃描',
                onPressed: _startScanning,
                icon: Icons.refresh,
              ),
            const SizedBox(height: AppSizes.paddingS),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回上一步'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device, BluetoothProvider bluetoothProvider) async {
    setState(() {
      _isConnecting = true;
      _connectingDeviceId = device.remoteId.toString();
    });

    try {
      final success = await bluetoothProvider.connectToDevice(device);

      if (success) {
        if (mounted) {
          _showSuccessSnackBar('設備連接成功');
          Navigator.pop(context, true); // 返回成功結果
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('設備連接失敗，請重試');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('連接失敗: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectingDeviceId = null;
        });
      }
    }
  }

  Color _getDeviceTypeColor(BluetoothDevice device) {
    final deviceName = device.platformName.toLowerCase();

    if (deviceName.contains('freestyle')) {
      return const Color(0xFF4CAF50); // 綠色
    } else if (deviceName.contains('dexcom')) {
      return const Color(0xFF2196F3); // 藍色
    } else if (deviceName.contains('guardian')) {
      return const Color(0xFF9C27B0); // 紫色
    } else {
      return AppColors.primary; // 預設顏色
    }
  }

  IconData _getDeviceTypeIcon(BluetoothDevice device) {
    final deviceName = device.platformName.toLowerCase();

    if (deviceName.contains('cgm') ||
        deviceName.contains('glucose') ||
        deviceName.contains('freestyle') ||
        deviceName.contains('dexcom') ||
        deviceName.contains('guardian')) {
      return Icons.sensors;
    } else {
      return Icons.device_unknown;
    }
  }

  String _getDeviceTypeName(BluetoothDevice device) {
    final deviceName = device.platformName.toLowerCase();

    if (deviceName.contains('freestyle')) {
      return 'FreeStyle CGM';
    } else if (deviceName.contains('dexcom')) {
      return 'Dexcom CGM';
    } else if (deviceName.contains('guardian')) {
      return 'Guardian CGM';
    } else if (deviceName.contains('cgm') || deviceName.contains('glucose')) {
      return 'CGM 設備';
    } else {
      return '未知設備';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '關閉',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    // 確保在離開頁面時停止掃描
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    if (bluetoothProvider.isScanning) {
      bluetoothProvider.stopScanning();
    }
    super.dispose();
  }
}