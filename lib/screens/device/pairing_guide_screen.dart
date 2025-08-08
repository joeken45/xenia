import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/constants.dart';

class PairingGuideScreen extends StatefulWidget {
  const PairingGuideScreen({super.key});

  @override
  State<PairingGuideScreen> createState() => _PairingGuideScreenState();
}

class _PairingGuideScreenState extends State<PairingGuideScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<PairingGuideStep> _steps = [
    PairingGuideStep(
      title: '準備您的 CGM 設備',
      subtitle: '開始配對前的準備工作',
      icon: Icons.sensors,
      content: [
        '確保 CGM 設備電量充足（建議 > 20%）',
        '檢查感測器是否已正確安裝',
        '確認設備處於正常工作狀態',
        '將設備放置在手機 10 公尺範圍內',
      ],
      tips: '如果是首次使用，請先閱讀設備說明書完成基本設定',
    ),
    PairingGuideStep(
      title: '啟用配對模式',
      subtitle: '讓您的設備可被發現',
      icon: Icons.bluetooth_searching,
      content: [
        '長按 CGM 設備的電源鍵 3-5 秒',
        '等待設備指示燈開始閃爍',
        '某些設備需要在選單中選擇"配對模式"',
        '配對模式通常持續 2-3 分鐘',
      ],
      tips: '不同品牌的 CGM 設備啟用方式可能略有不同，請參考您的設備說明書',
    ),
    PairingGuideStep(
      title: '開始配對連接',
      subtitle: '在 Xenia 中搜尋並連接設備',
      icon: Icons.link,
      content: [
        '在 Xenia 中點擊"開始掃描"',
        '等待設備出現在搜尋結果中',
        '點擊您的設備名稱開始連接',
        '首次配對可能需要 30-60 秒',
      ],
      tips: '如果掃描不到設備，請重新啟用配對模式並確保距離足夠近',
    ),
    PairingGuideStep(
      title: '完成設定',
      subtitle: '驗證連接並開始使用',
      icon: Icons.check_circle,
      content: [
        '連接成功後會看到設備狀態為"已連接"',
        '等待設備開始傳送血糖數據',
        '您可以在主頁面查看實時血糖值',
        '設定完成後設備會自動重新連接',
      ],
      tips: '如果遇到連接問題，請重啟設備和手機藍牙後重試',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('配對指南'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildGuidePage(_steps[index]);
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
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
            '步驟 ${_currentPage + 1} / ${_steps.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentPage;
              final isCurrent = index == _currentPage;

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < _steps.length - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidePage(PairingGuideStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.paddingL),
          _buildStepHeader(step),
          const SizedBox(height: AppSizes.paddingXL),
          _buildStepContent(step),
          const SizedBox(height: AppSizes.paddingL),
          _buildStepTips(step),
        ],
      ),
    );
  }

  Widget _buildStepHeader(PairingGuideStep step) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            step.icon,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),
        Text(
          step.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          step.subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepContent(PairingGuideStep step) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.paddingM),
                Text(
                  '操作步驟',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            ...step.content.asMap().entries.map((entry) {
              final index = entry.key;
              final content = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: Text(
                        content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTips(PairingGuideStep step) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小提示',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  step.tips,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: SecondaryButton(
                  text: '上一步',
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icons.arrow_back,
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: AppSizes.paddingM),
            Expanded(
              flex: _currentPage == 0 ? 1 : 1,
              child: CustomButton(
                text: _currentPage < _steps.length - 1 ? '下一步' : '開始配對',
                onPressed: () {
                  if (_currentPage < _steps.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: _currentPage < _steps.length - 1
                    ? Icons.arrow_forward
                    : Icons.bluetooth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PairingGuideStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> content;
  final String tips;

  PairingGuideStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
    required this.tips,
  });
}