import 'package:flutter/material.dart';

Widget buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_awesome, size: 64, color: Colors.deepPurple),
        const SizedBox(height: 16),
        const Text(
          "No sparks yet 🚀",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Be the first to share your spark!",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              _showCreateSparkDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Create Spark"),
          ),
        ),
      ],
    ),
  );
}

void showComments(BuildContext context, String sparkId, String username) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Comments by $username"),
      content: const Text("Comments feature will be implemented soon!"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void _showCreateSparkDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Create New Spark"),
      content: const Text("Spark creation feature will be implemented soon!"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
