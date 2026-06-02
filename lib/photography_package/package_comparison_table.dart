import 'package:flutter/material.dart';
import 'package:nobochitro/utilities/package_standard.dart';

class PackageComparisonTable extends StatelessWidget {
  final List<Map<String, dynamic>> comparisonPackages;
  final bool isLoading;
  final bool isDark;
  final Color cardColor;
  final Color primaryAccent;

  const PackageComparisonTable({
    super.key,
    required this.comparisonPackages,
    required this.isLoading,
    required this.isDark,
    required this.cardColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    /// does not display comparison table if exist of one package any category
    if (comparisonPackages.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columnSpacing: comparisonPackages.length == 2
                      ? (constraints.maxWidth / 3.5)
                      : 25,
                  horizontalMargin: 20,
                  headingRowColor: WidgetStateProperty.all(
                    primaryAccent.withOpacity(0.1),
                  ),
                  columns: [
                    const DataColumn(
                      label: Text(
                        'Comparison',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...comparisonPackages.map(
                      (pkg) => DataColumn(
                        label: Text(
                          /// Utility to call from class
                          PackageStandard.getBadgeLabel(pkg['base_price']),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    _buildRow(
                      "Package",
                      (pkg) => pkg['title'] ?? "N/A",
                      isBold: true,
                    ),
                    _buildRow(
                      "Price",
                      (pkg) => "৳${pkg['base_price']}",
                      color: primaryAccent,
                      isBold: true,
                    ),
                    _buildRow("Extras", (pkg) {
                      int count =
                          (pkg['features']?.toString().split(',') ?? []).length;
                      return "$count Items";
                    }),
                    _buildRow(
                      "Duration",
                      (pkg) => "${pkg['base_hours'] ?? 0} hrs",
                    ),
                    DataRow(
                      cells: [
                        const DataCell(
                          Text(
                            "Level",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                        ...comparisonPackages.map((pkg) {
                          /// Utility icon set from class level
                          String label = PackageStandard.getBadgeLabel(
                            pkg['base_price'],
                          );
                          return DataCell(
                            Icon(
                              label == 'Budget'
                                  ? Icons.trending_up
                                  : label == 'Standard'
                                  ? Icons.auto_awesome
                                  : Icons.workspace_premium,
                              size: 16,
                              color: primaryAccent.withOpacity(0.7),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DataRow _buildRow(
    String label,
    String Function(Map<String, dynamic>) valueExtractor, {
    Color? color,
    bool isBold = false,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ),
        ...comparisonPackages.map(
          (pkg) => DataCell(
            Text(
              valueExtractor(pkg),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
