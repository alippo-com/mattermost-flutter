import 'package:mattermost_flutter/types/model.dart'; // Assuming Model is defined in this path in Dart

/// The Global model will act as a dictionary of name-value pairs. The value field can be a JSON object or any other
/// data type. It will hold information that applies to the whole app (e.g., sidebar settings for tablets)
class GlobalModel extends Model {
  /// table (name) : global
  static const String table = 'global';

  /// value : The value part of the key-value combination and whose key will be the id column
  dynamic value;
}