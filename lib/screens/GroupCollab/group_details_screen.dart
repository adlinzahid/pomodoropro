import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatelessWidget {
  final String groupName;
  final String uniqueCode;
  final List<String> members;

  const GroupDetailsScreen({
    super.key,
    required this.groupName,
    required this.uniqueCode,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Code: $uniqueCode',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Members:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(members[index]),
                    leading: const Icon(Icons.person),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
