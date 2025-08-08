import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../utils/constants.dart';
import '../../generated/l10n.dart';
import 'bluetooth_scan_screen.dart';
import 'pairing_guide_screen.dart';

class DeviceSetupScreen extends StatefulWidget {
  const DeviceSetupScreen({super.key});

  @override
  State<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends State<DeviceSetupScreen> {
  int _currentStep = 0;
  bool _bluetoothPermissionGranted = false;
  bool _bluetoothEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    await bluetoothProvider.checkBluetoothStatus();

    setState(() {
      _bluetoothEnabled = bluetoothProvider.isBluetoothOn;
      if (_bluetoothEnabled) {
        _currentStep = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(S.of(context).connectDevice),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, _) {
          return Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: _buildCurrentStep(bluetoothProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
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
          Text(
            '設備設定',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Row(
            children: [
              _buildStepIndicator(0, '藍牙設定', Icons.bluetooth),
              _buildStepConnector(0),
              _buildStepIndicator(1, '掃描設備', Icons.search),
              _buildStepConnector(1),
              _buildStepIndicator(2, '配對連接', Icons.link),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title, IconData icon) {
    final isActive = stepIndex <= _currentStep;
    final isCompleted = stepIndex < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive ? AppColors.primary : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int stepIndex) {
    final isActive = stepIndex < _currentStep;

    return Container(
      width: 32,
      height: 2,
      color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildCurrentStep(BluetoothProvider bluetoothProvider) {
    switch (_currentStep) {
      case 0:
        return _buildBluetoothSetupStep(bluetoothProvider);
      case 1:
        return _buildDeviceScanStep(bluetoothProvider);
      case 2:
        return _buildDevicePairingStep(bluetoothProvider);
      default:
        return _buildCompletedStep(bluetoothProvider);
    }
  }

  Widget _buildBluetoothSetupStep(BluetoothProvider bluetoothProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.paddingXL),
          Icon(
            bluetoothProvider.isBluetoothOn ? Icons.bluetooth : Icons.bluetooth_disabled,
            size: 120,
            color: bluetoothProvider.isBluetoothOn ? AppColors.success : Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            bluetoothProvider.isBluetoothOn ? '藍牙已開啟' : '請開啟藍牙',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            bluetoothProvider.isBluetoothOn
                ? '您的設備藍牙已開啟，可以開始掃描 CGM 設備'
                : '需要開啟藍牙功能才能連接 CGM 設備',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingL),
          if (!bluetoothProvider.isBluetoothOn)
            _buildBluetoothStatusCard(bluetoothProvider),
          const Spacer(),
          if (bluetoothProvider.isBluetoothOn)
            CustomButton(
              text: '下一步',
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              icon: Icons.arrow_forward,
            )
          else
            CustomButton(
              text: '檢查藍牙狀態',
              onPressed: () async {
                await bluetoothProvider.checkBluetoothStatus();
                if (bluetoothProvider.isBluetoothOn) {
                  setState(() {
                    _currentStep = 1;
                  });
                }
              },
              icon: Icons.refresh,
            ),
        ],
      ),
    );
  }

  Widget _buildBluetoothStatusCard(BluetoothProvider bluetoothProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Text(
                    '藍牙狀態',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildStatusRow(
              '藍牙支援',
              true,
              Icons.check_circle,
              AppColors.success,
            ),
            _buildStatusRow(
              '藍牙開啟',
              bluetoothProvider.isBluetoothOn,
              bluetoothProvider.isBluetoothOn ? Icons.check_circle : Icons.cancel,
              bluetoothProvider.isBluetoothOn ? AppColors.success : AppColors.error,
            ),
            _buildStatusRow(
              '權限授予',
              true, // 簡化處理
              Icons.check_circle,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String title, bool status, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            status ? '正常' : '異常',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceScanStep(BluetoothProvider bluetoothProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.paddingXL),
          Icon(
            Icons.search,
            size: 120,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            '掃描 CGM 設備',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
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
          _buildScanInstructions(),
          const Spacer(),
          CustomButton(
            text: '開始掃描',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BluetoothScanScreen(),
                ),
              ).then((result) {
                if (result == true) {
                  setState(() {
                    _currentStep = 2;
                  });
                }
              });
            },
            icon: Icons.search,
          ),
          const SizedBox(height: AppSizes.paddingM),
          SecondaryButton(
            text: '需要幫助？',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PairingGuideScreen(),
                ),
              );
            },
            icon: Icons.help_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildScanInstructions() {
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
                  '掃描提示',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildInstructionItem('確保 CGM 設備電量充足'),
            _buildInstructionItem('設備應在 10 公尺範圍內'),
            _buildInstructionItem('避免其他藍牙設備干擾'),
            _buildInstructionItem('首次配對可能需要較長時間'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
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

  Widget _buildDevicePairingStep(BluetoothProvider bluetoothProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.paddingXL),
          if (bluetoothProvider.isConnected) ...[
            Icon(
              Icons.check_circle,
              size: 120,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              '設備連接成功',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              '您的 CGM 設備已成功連接，可以開始監測血糖',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingL),
            if (bluetoothProvider.deviceInfo != null)
              _buildDeviceInfoCard(bluetoothProvider.deviceInfo!),
          ] else ...[
            const LoadingWidget(
              message: '正在配對設備...',
              size: 60,
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              '設備配對中',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              '請稍候，正在與您的 CGM 設備建立連接',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
          if (bluetoothProvider.isConnected)
            CustomButton(
              text: '完成設定',
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: Icons.check,
            )
          else
            SecondaryButton(
              text: '取消配對',
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              icon: Icons.cancel,
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedStep(BluetoothProvider bluetoothProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration,
            size: 120,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            '設定完成！',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            '您的 Xenia 已準備就緒，開始您的健康管理之旅',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingXL),
          CustomButton(
            text: '開始使用',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: Icons.home,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(dynamic deviceInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sensors,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '已連接設備',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'CGM 設備',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: const Text(
                    '已連接',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}