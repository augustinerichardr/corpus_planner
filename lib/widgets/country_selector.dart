import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../services/country_service.dart';

class CountrySelectorDropdown extends StatefulWidget {
  final Function(CountryModel) onCountryChanged;

  const CountrySelectorDropdown({super.key, required this.onCountryChanged});

  @override
  State<CountrySelectorDropdown> createState() =>
      _CountrySelectorDropdownState();
}

class _CountrySelectorDropdownState extends State<CountrySelectorDropdown> {
  List<CountryModel> _countries = [];
  CountryModel? _selectedCountry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final list = await CountryService.getCountries();
    final saved = await CountryService.getSavedCountry();

    final targetCode = saved?.code ?? 'IN';
    final matchedCountry = list.firstWhere(
      (c) => c.code == targetCode,
      orElse: () => list.first,
    );

    if (mounted) {
      setState(() {
        _countries = list;
        _selectedCountry = matchedCountry;
        _isLoading = false;
      });

      widget.onCountryChanged(matchedCountry);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryModel>(
          value: _selectedCountry,
          isDense: true,
          items: _countries.map((CountryModel country) {
            return DropdownMenuItem<CountryModel>(
              value: country,
              child: Text(
                '${country.name} (${country.currencySymbol} ${country.currencyCode})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (CountryModel? newCountry) {
            if (newCountry != null) {
              setState(() => _selectedCountry = newCountry);
              CountryService.saveSelectedCountry(newCountry);
              widget.onCountryChanged(newCountry);
            }
          },
        ),
      ),
    );
  }
}
