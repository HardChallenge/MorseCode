import 'package:flutter/material.dart';

List<BottomNavigationBarItem> _navigationItems =
    const <BottomNavigationBarItem>[
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Morse Code',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.sms),
    label: 'Send SMS',
  ),
];

List<BottomNavigationBarItem> getNavigationItems() {
  return _navigationItems;
}
