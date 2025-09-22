import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget profileNameColumnbuild(
  BuildContext context,
  String name,
  String userName,
  String userId,
) {
  return Center(
    child: Column(
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: "@KaviMark"));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Username copied to clipboard')),
                );
              },
              child: Text(
                "@$userName",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: "0000000"));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ID copied to clipboard')),
                );
              },
              child: Text(
                userId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget profileNameRowbuild(
  BuildContext context,
  String name,
  String userName,
  String userId,
) {
  return Center(
    child: Column(
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: "@KaviMark"));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Username copied to clipboard')),
                );
              },
              child: Text(
                "@$userName",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: "0000000"));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ID copied to clipboard')),
                );
              },
              child: Text(
                userId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget profileNameDesktopRowbuild(
  BuildContext context,
  String name,
  String userName,
  String userId,
) {
  return Row(
    children: [
      SizedBox(width: 370),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: "@KaviMark"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Username copied to clipboard')),
                  );
                },
                child: Text(
                  "@$userName",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: "0000000"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ID copied to clipboard')),
                  );
                },
                child: Text(
                  userId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
