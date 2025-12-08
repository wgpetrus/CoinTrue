import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants.dart';
import '../../../utils/theme_helper.dart';

/// Gráfico de Preço Animado
/// 
/// Gráfico interativo com:
/// - Animação de entrada suave
/// - Tooltip ao tocar
/// - Gradiente de fundo
/// - Indicador de tendência
class AnimatedPriceChart extends StatefulWidget {
  final List<FlSpot> data;
  final String period;
  final bool isPositive;

  const AnimatedPriceChart({
    super.key,
    required this.data,
    required this.period,
    required this.isPositive,
  });

  @override
  State<AnimatedPriceChart> createState() => _AnimatedPriceChartState();
}

class _AnimatedPriceChartState extends State<AnimatedPriceChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    if (widget.data.isEmpty) {
      return _buildEmptyState(colors);
    }

    return SizedBox(
      height: 240, // Altura fixa para evitar "pulo"
      child: Stack(
        children: [
          // Indicador de preço no topo (posição fixa)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _touchedIndex != null
                    ? _buildTouchIndicator(colors)
                    : const SizedBox(height: 32), // Espaço reservado
              ),
            ),
          ),
          
          // Gráfico
          Positioned(
            top: 40, // Espaço para o indicador
            left: 0,
            right: 0,
            bottom: 0,
            child: LineChart(
              _buildChartData(colors),
              duration: const Duration(milliseconds: 250),
            ).animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOut),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.chartLine(),
              size: 48,
              color: colors.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Dados indisponíveis',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTouchIndicator(AppColors colors) {
    if (_touchedIndex == null || _touchedIndex! >= widget.data.length) {
      return const SizedBox.shrink();
    }

    final spot = widget.data[_touchedIndex!];
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.onBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        formatter.format(spot.y),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.background,
        ),
      ),
    ).animate()
      .fadeIn(duration: 150.ms)
      .scale(begin: const Offset(0.8, 0.8), duration: 150.ms);
  }

  LineChartData _buildChartData(AppColors colors) {
    final lineColor = widget.isPositive ? colors.success : colors.error;
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: null,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colors.outline,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: widget.data.first.x,
      maxX: widget.data.last.x,
      minY: _getMinY(),
      maxY: _getMaxY(),
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            if (touchResponse == null || touchResponse.lineBarSpots == null) {
              _touchedIndex = null;
              return;
            }
            _touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
          });
        },
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: colors.onBackground.withOpacity(0.5),
                strokeWidth: 2,
                dashArray: [5, 5],
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: colors.background,
                    strokeWidth: 3,
                    strokeColor: lineColor,
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 0,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return const LineTooltipItem('', TextStyle());
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: widget.data,
          isCurved: true,
          curveSmoothness: 0.35,
          color: lineColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lineColor.withOpacity(0.3),
                lineColor.withOpacity(0.05),
                lineColor.withOpacity(0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  double _getMinY() {
    final values = widget.data.map((spot) => spot.y).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    return min * 0.995; // 0.5% abaixo do mínimo
  }

  double _getMaxY() {
    final values = widget.data.map((spot) => spot.y).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    return max * 1.005; // 0.5% acima do máximo
  }
}
