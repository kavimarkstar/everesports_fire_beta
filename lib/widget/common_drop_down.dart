import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:everesports/database/config/config.dart';

const TextStyle kCommonDropDownTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.black87,
);

class GameDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> games;
  final Map<String, dynamic>? selectedGame;
  final ValueChanged<Map<String, dynamic>?>? onChanged;
  final String hint;

  const GameDropdown({
    Key? key,
    required this.games,
    this.selectedGame,
    this.onChanged,
    this.hint = 'Select Game',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DropdownSearch<Map<String, dynamic>>(
      items: games,
      selectedItem: selectedGame,
      itemAsString: (g) => g['name'] ?? '',
      onChanged: onChanged,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: mainColor, width: 0.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, g, isSelected) {
          final String imageUrl =
              g['image_path'] != null && g['image_path'].toString().isNotEmpty
              ? (g['image_path'].toString().startsWith('/')
                    ? '$fileServerBaseUrl${g['image_path']}'
                    : '$fileServerBaseUrl/${g['image_path']}')
              : '';
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(6),
              child: Image.network(imageUrl, height: 30),
            ),
            title: Text(
              g['name'] ?? '',
              style: TextStyle(
                color: isDarkMode ? mainWhiteColor : mainBlackColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
      dropdownBuilder: (context, g) {
        if (g == null) return Text(hint);
        final String imageUrl =
            g['image_path'] != null && g['image_path'].toString().isNotEmpty
            ? (g['image_path'].toString().startsWith('/')
                  ? '$fileServerBaseUrl${g['image_path']}'
                  : '$fileServerBaseUrl/${g['image_path']}')
            : '';
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(6),
              child: Image.network(imageUrl, height: 30),
            ),

            SizedBox(width: 12),
            Text(
              g['name'] ?? '',
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    );
  }
}
