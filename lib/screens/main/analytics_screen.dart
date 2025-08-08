import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cgm_provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../widgets/cards/stats_card.dart';
import '../../widgets/charts/glucose_chart.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/constants.dart';
import '../../generated/l10n.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  String _selectedPeriod = '7天';
  final List<String> _periods = ['24小時', '7天', '30天', '90天'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final cgmProvider = context.read<CGMProvider>();
    int? hours;

    switch (_selectedPeriod) {
      case '24小時':
        hours = 24;
        break;
      case '7天':
        hours = 24 * 7;
        break;
      case '30天':
        hours = 24 * 30;
        break;
      case '90天':
        hours = 24 * 90;
        break;
    }

    cgmProvider.loadGlucoseData(hours: hours);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: Column(
          children: [
            _buildPeriodSelector(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildTrendsTab(),
                  _buildReportsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      title: Text(S.of(context).analytics),
      floating: true,
      snap: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        Consumer<BluetoothProvider>(
          builder: (context, bluetoothProvider, _) {
            return IconButton(
              icon: Icon(
                bluetoothProvider.isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: bluetoothProvider.isConnected
                    ? Colors.white
                    : Colors.white54,
              ),
              onPressed: () {
                // 導航到設備設定
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Row(
        children: [
          Text(
            '時間範圍：',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.map((period) {
                  final isSelected = period == _selectedPeriod;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.paddingS),
                    child: FilterChip(
                      label: Text(period),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPeriod = period;
                          });
                          _loadData();
                        }
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: '概覽', icon: Icon(Icons.dashboard, size: 20)),
          Tab(text: '趨勢', icon: Icon(Icons.timeline, size: 20)),
          Tab(text: '報告', icon: Icon(Icons.description, size: 20)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<CGMProvider>(
      builder: (context, cgmProvider, _) {
        if (cgmProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cgmProvider.glucoseReadings.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(cgmProvider),
                const SizedBox(height: AppSizes.paddingL),
                _buildGlucoseChart(cgmProvider),
                const SizedBox(height: AppSizes.paddingL),
                _buildDetailedStats(cgmProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    return Consumer<CGMProvider>(
      builder: (context, cgmProvider, _) {
        if (cgmProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrendAnalysis(cgmProvider),
              const SizedBox(height: AppSizes.paddingL),
              _buildPatternAnalysis(cgmProvider),
              const SizedBox(height: AppSizes.paddingL),
              _buildTimeBasedAnalysis(cgmProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsTab() {
    return Consumer<CGMProvider>(
      builder: (context, cgmProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportSummary(cgmProvider),
              const SizedBox(height: AppSizes.paddingL),
              _buildReportActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            '暫無血糖數據',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '連接您的 CGM 設備以開始分析',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(CGMProvider cgmProvider) {
    final hours = _getHoursFromPeriod(_selectedPeriod);
    final tir = cgmProvider.calculateTIR(hours: hours);
    final average = cgmProvider.calculateAverageGlucose(hours: hours);
    final cv = cgmProvider.calculateCoefficientOfVariation(hours: hours);

    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'TIR',
            value: '${tir.toStringAsFixed(1)}%',
            subtitle: '目標範圍內時間',
            color: _getTIRColor(tir),
            icon: Icons.target,
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: StatsCard(
            title: '平均血糖',
            value: '${average.toStringAsFixed(0)}',
            subtitle: 'mg/dL',
            color: _getAverageColor(average),
            icon: Icons.trending_flat,
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: StatsCard(
            title: 'CV',
            value: '${cv.toStringAsFixed(1)}%',
            subtitle: '血糖變異係數',
            color: _getCVColor(cv),
            icon: Icons.show_chart,
          ),
        ),
      ],
    );
  }

  Widget _buildGlucoseChart(CGMProvider cgmProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '血糖趨勢圖',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            SizedBox(
              height: 250,
              child: GlucoseChart(
                glucoseReadings: cgmProvider.glucoseReadings,
                timeRange: _selectedPeriod,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(CGMProvider cgmProvider) {
    final hours = _getHoursFromPeriod(_selectedPeriod);
    final highEvents = cgmProvider.getHighGlucoseEvents(hours: hours);
    final lowEvents = cgmProvider.getLowGlucoseEvents(hours: hours);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '詳細統計',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildStatRow('高血糖事件', '${highEvents.length}次', AppColors.glucoseHigh),
            _buildStatRow('低血糖事件', '${lowEvents.length}次', AppColors.glucoseLow),
            _buildStatRow('總讀數', '${cgmProvider.glucoseReadings.length}筆', AppColors.info),
            _buildStatRow('數據完整性', '${_calculateDataCompleteness(cgmProvider)}%', AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(CGMProvider cgmProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '趨勢分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            // 趨勢分析內容
            Text('趨勢分析功能開發中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternAnalysis(CGMProvider cgmProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模式分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            // 模式分析內容
            Text('模式分析功能開發中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBasedAnalysis(CGMProvider cgmProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '時間基礎分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            // 時間基礎分析內容
            Text('時間基礎分析功能開發中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummary(CGMProvider cgmProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '報告摘要',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              '數據期間: $_selectedPeriod',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '總讀數: ${cgmProvider.glucoseReadings.length}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // 更多摘要資訊
          ],
        ),
      ),
    );
  }

  Widget _buildReportActions() {
    return Column(
      children: [
        CustomButton(
          text: '生成 PDF 報告',
          icon: Icons.picture_as_pdf,
          onPressed: _generatePDFReport,
        ),
        const SizedBox(height: AppSizes.paddingM),
        CustomButton(
          text: '匯出數據',
          icon: Icons.download,
          backgroundColor: AppColors.secondary,
          onPressed: _exportData,
        ),
        const SizedBox(height: AppSizes.paddingM),
        CustomButton(
          text: '分享報告',
          icon: Icons.share,
          backgroundColor: AppColors.info,
          onPressed: _shareReport,
        ),
      ],
    );
  }

  // 輔助方法
  int? _getHoursFromPeriod(String period) {
    switch (period) {
      case '24小時': return 24;
      case '7天': return 24 * 7;
      case '30天': return 24 * 30;
      case '90天': return 24 * 90;
      default: return null;
    }
  }

  Color _getTIRColor(double tir) {
    if (tir >= 70) return AppColors.success;
    if (tir >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Color _getAverageColor(double average) {
    if (average >= 70 && average <= 180) return AppColors.success;
    return AppColors.warning;
  }

  Color _getCVColor(double cv) {
    if (cv <= 33) return AppColors.success;
    if (cv <= 36) return AppColors.warning;
    return AppColors.error;
  }

  double _calculateDataCompleteness(CGMProvider cgmProvider) {
    // 簡化的數據完整性計算
    final hours = _getHoursFromPeriod(_selectedPeriod) ?? 24;
    final expectedReadings = hours * 4; // 假設每15分鐘一次讀數
    final actualReadings = cgmProvider.glucoseReadings.length;
    return (actualReadings / expectedReadings * 100).clamp(0.0, 100.0);
  }

  Future<void> _generatePDFReport() async {
    // PDF 報告生成邏輯
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF 報告生成功能開發中...')),
    );
  }

  Future<void> _exportData() async {
    // 數據匯出邏輯
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('數據匯出功能開發中...')),
    );
  }

  Future<void> _shareReport() async {
    // 報告分享邏輯
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('報告分享功能開發中...')),
    );
  }
}