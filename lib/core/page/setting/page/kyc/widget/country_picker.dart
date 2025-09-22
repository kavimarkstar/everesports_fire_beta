import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

class CountryPickerField extends StatelessWidget {
  final List<String> countries;
  final String? selectedCountry;
  final ValueChanged<String?> onCountrySelected;
  final String? Function(String?)? validator;

  const CountryPickerField({
    super.key,
    required this.countries,
    this.selectedCountry,
    required this.onCountrySelected,
    this.validator,
  });

  Future<String?> _showCountryPicker(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String query = '';
        final TextEditingController searchCtrl = TextEditingController();
        List<String> filtered = List.of(countries);

        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              void applyFilter(String q) {
                query = q;
                final lower = query.toLowerCase();
                filtered = countries
                    .where((c) => c.toLowerCase().contains(lower))
                    .toList();
                setSheetState(() {});
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchCtrl,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Search country',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: applyFilter,
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: filtered.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('No results'),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final country = filtered[index];
                                final selected = country == selectedCountry;
                                return ListTile(
                                  title: Text(country),
                                  trailing: selected
                                      ? const Icon(Icons.check)
                                      : null,
                                  onTap: () => Navigator.pop(context, country),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (countries.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () async {
        final selected = await _showCountryPicker(context);
        if (selected != null) {
          onCountrySelected(selected);
        }
      },
      child: AbsorbPointer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Country',
              suffixIcon: const Icon(Icons.search),
              hintText: 'Select country',
              hintStyle: const TextStyle(color: Colors.grey),
              labelStyle: TextStyle(color: mainColor),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: mainColor, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: mainColor, width: 0.5),
              ),
            ),
            controller: TextEditingController(text: selectedCountry),
            validator: validator,
          ),
        ),
      ),
    );
  }
}

class CountryService {
  static Future<List<String>> loadCountries() async {
    try {
      // This would typically load from your KycService
      // For now, return a basic list
      return [
        'Afghanistan',
        'Albania',
        'Algeria',
        'Argentina',
        'Australia',
        'Austria',
        'Bangladesh',
        'Belgium',
        'Brazil',
        'Canada',
        'China',
        'France',
        'Germany',
        'India',
        'Indonesia',
        'Italy',
        'Japan',
        'Malaysia',
        'Netherlands',
        'Singapore',
        'Sri Lanka',
        'United Kingdom',
        'United States',
      ];
    } catch (e) {
      return [];
    }
  }
}
