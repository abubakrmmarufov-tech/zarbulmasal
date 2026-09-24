import 'package:flutter/services.dart';

/// Longest query any search field accepts.
const int searchQueryMaxLength = 256;

/// Enforces [searchQueryMaxLength] without the visible "0/256" counter that
/// `TextField.maxLength` draws under the field.
final List<TextInputFormatter> searchQueryFormatters = List.unmodifiable([
  LengthLimitingTextInputFormatter(searchQueryMaxLength),
]);
