import 'package:flutter/material.dart';

class SurveyProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const SurveyProgressBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentPage + 1) / totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${currentPage + 1} of $totalPages',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${((progress) * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Page Indicators - Show max 20 indicators or scale down
          LayoutBuilder(
            builder: (context, constraints) {
              final maxIndicators = totalPages > 20 ? 20 : totalPages;
              final indicatorSize = totalPages > 20 ? 4.0 : 6.0;
              final spacing = totalPages > 20 ? 1.0 : 2.0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  maxIndicators,
                  (index) {
                    // For large page counts, show representative indicators
                    int actualIndex;
                    if (totalPages <= 20) {
                      actualIndex = index;
                    } else {
                      // Show first 10, last 10, but highlight current appropriately
                      if (index < 9) {
                        actualIndex = index;
                      } else if (index == 9) {
                        actualIndex = (currentPage / (totalPages - 1) * 19).round();
                      } else {
                        actualIndex = totalPages - (20 - index);
                      }
                    }

                    return Container(
                      width: indicatorSize,
                      height: indicatorSize,
                      margin: EdgeInsets.symmetric(horizontal: spacing),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: actualIndex <= currentPage
                            ? Colors.green
                            : Colors.grey[300],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
