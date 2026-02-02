import 'package:flutter/material.dart';

class SurveyProgressIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageSelected;
  final List<String> pageNames;

  const SurveyProgressIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    required this.pageNames,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Mobile: Horizontal scrollable progress bar
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(totalPages, (index) {
              final isActive = index == currentPage;
              final isCompleted = index < currentPage;

              return GestureDetector(
                onTap: () => onPageSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? Colors.green[600]
                              : isCompleted
                                  ? Colors.green[200]
                                  : Colors.grey[300],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isActive || isCompleted ? Colors.white : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 40,
                        child: Text(
                          pageNames[index],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8,
                            color: isActive ? Colors.green[600] : Colors.grey[600],
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
    } else {
      // Desktop: Vertical sidebar
      return Container(
        width: 140,
        color: Colors.grey[100],
        padding: const EdgeInsets.all(8),
        child: ListView.separated(
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemCount: totalPages,
          itemBuilder: (context, index) {
            final isActive = index == currentPage;
            final isCompleted = index < currentPage;

            return GestureDetector(
              onTap: () => onPageSelected(index),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green[600]
                      : isCompleted
                          ? Colors.green[100]
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive ? Border.all(color: Colors.green[800]!, width: 2) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.white
                                : isCompleted
                                    ? Colors.green[700]
                                    : Colors.grey[400],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive || isCompleted ? Colors.green[700] : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pageNames[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              color: isActive ? Colors.white : Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
