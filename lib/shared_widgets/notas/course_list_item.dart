import 'package:flutter/material.dart';

class CourseListItem extends StatelessWidget {
  final String courseName;
  final String? subtitle;
  final bool hasSubItems;
  final List<String>? subItems;
  final ThemeData? theme;

  const CourseListItem({
    Key? key,
    required this.courseName,
    this.subtitle,
    this.hasSubItems = false,
    this.subItems,
    this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentTheme = theme ?? Theme.of(context);
    final isDarkMode = currentTheme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                    activeColor: currentTheme.colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                ],
              ),
              if (hasSubItems && subItems != null) _buildSubItems(currentTheme),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildSubItems(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 8),
      child: Column(
        children:
            subItems!.map((item) => _buildSubItem(item, isDarkMode)).toList(),
      ),
    );
  }

  Widget _buildSubItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {},
            activeColor: isDarkMode ? Colors.blue[200] : Colors.blue[800],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
