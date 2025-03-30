import 'package:flutter/material.dart';

class CourseListItem extends StatelessWidget {
  final String courseName;
  final String? subtitle;
  final bool hasSubItems;
  final List<String>? subItems;

  const CourseListItem({
    super.key,
    required this.courseName,
    this.subtitle,
    this.hasSubItems = false,
    this.subItems,
  });

  @override
  Widget build(BuildContext context) {
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
                    activeColor: Colors.blue[800],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                ],
              ),
              if (hasSubItems && subItems != null) _buildSubItems(),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildSubItems() {
    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 8),
      child: Column(
        children: subItems!.map((item) => _buildSubItem(item)).toList(),
      ),
    );
  }

  Widget _buildSubItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {},
            activeColor: Colors.blue[800],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}