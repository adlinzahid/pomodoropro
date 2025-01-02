import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodororpo/screens/GroupCollab/group_data_handler.dart';
import 'package:pomodororpo/screens/GroupCollab/group_details_screen.dart';

class ViewGroupsList extends StatelessWidget {
  ViewGroupsList({super.key});

  final GroupDataHandler _groupDataHandler = GroupDataHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Groups'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _groupDataHandler.fetchUserGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No groups found.'));
          } else {
            final groups = snapshot.data!;

            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final groupName = group['groupName'] ?? 'No Group Name';
                final uniqueCode = group['uniqueCode'] ?? 'No Group Code';
                final description = group['description'] ?? 'No Description';

                // Fetching members in parallel
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(uniqueCode)
                      .collection('members')
                      .get(),
                  builder: (context, memberSnapshot) {
                    if (memberSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (memberSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${memberSnapshot.error}'));
                    } else if (!memberSnapshot.hasData ||
                        memberSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No members found.'));
                    } else {
                      final members = memberSnapshot.data!.docs;
                      final memberCount = members.length;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        color: Colors.green[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            groupName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: const Color.fromARGB(255, 8, 50, 11),
                            ),
                          ),
                          subtitle: Text(
                            '$memberCount Members • $description • Group Code: $uniqueCode',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupDetailsScreen(
                                  groupName: groupName,
                                  uniqueCode: uniqueCode,
                                  members: members
                                      .map((doc) => doc['name'] as String)
                                      .toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
