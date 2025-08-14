import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/currency_utils.dart';

class LineChartWidget extends StatefulWidget {
  final List<FlSpot> incomeData;
  final List<FlSpot> expenseData;
  final List<String> xLabels;
  final String title;
  final double height;

  const LineChartWidget({
    super.key,
    required this.incomeData,
    required this.expenseData,
    required this.xLabels,
    required this.title,
    this.height = 300,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              height: widget.height,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getHorizontalInterval(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: _buildBottomTitle,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getHorizontalInterval(),
                        getTitlesWidget: _buildLeftTitle,
                        reservedSize: 50,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: widget.xLabels.isNotEmpty
                      ? (widget.xLabels.length - 1).toDouble()
                      : 0,
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    _buildIncomeLineData(),
                    _buildExpenseLineData(),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.9),
                      tooltipBorder: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      getTooltipItems: _buildTooltipItems,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  LineChartBarData _buildIncomeLineData() {
    return LineChartBarData(
      spots: widget.incomeData
          .map((spot) => FlSpot(spot.x, spot.y * _animation.value))
          .toList(),
      isCurved: true,
      color: const Color(0xFF10B981),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFF10B981).withOpacity(0.1),
      ),
    );
  }

  LineChartBarData _buildExpenseLineData() {
    return LineChartBarData(
      spots: widget.expenseData
          .map((spot) => FlSpot(spot.x, spot.y * _animation.value))
          .toList(),
      isCurved: true,
      color: const Color(0xFFEF4444),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFFEF4444).withOpacity(0.1),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('Income', const Color(0xFF10B981)),
        const SizedBox(width: 24),
        _buildLegendItem('Expense', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildBottomTitle(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= widget.xLabels.length) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        widget.xLabels[index],
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildLeftTitle(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        CurrencyUtils.formatCompactAmount(value),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  List<LineTooltipItem> _buildTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      final textStyle = TextStyle(
        color: touchedSpot.bar.color,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );

      final label = touchedSpot.barIndex == 0 ? 'Income' : 'Expense';
      final amount = CurrencyUtils.formatAmount(touchedSpot.y);

      return LineTooltipItem('$label: $amount', textStyle);
    }).toList();
  }

  double _getMaxY() {
    double maxIncome = widget.incomeData.isNotEmpty
        ? widget.incomeData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;
    double maxExpense = widget.expenseData.isNotEmpty
        ? widget.expenseData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;

    final maxVal = maxIncome > maxExpense ? maxIncome : maxExpense;
    final padded = maxVal * 1.2; // Add 20% padding
    // Ensure a positive maxY to avoid zero intervals when data is empty
    return padded > 0 ? padded : 1.0;
  }

  double _getHorizontalInterval() {
    final maxY = _getMaxY();
    final interval = maxY / 5; // 5 horizontal lines
    // fl_chart requires a positive non-zero interval
    return interval > 0 ? interval : 1.0;
  }
}
