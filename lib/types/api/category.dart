enum CategorySorting { alpha, manual, recent }
enum CategoryType { channels, direct_messages, favorites, custom }
class CategoryChannel {
  String? id;
  String category_id;
  String channel_id;
  int sort_order;
}
class Category {
  String id;
  String team_id;
  String display_name;
  int sort_order;
  CategorySorting sorting;
  CategoryType type;
  bool muted;
  bool collapsed;
}
class CategoryWithChannels extends Category {
  List<String> channel_ids;
}
class CategoriesWithOrder {
  List<CategoryWithChannels> categories;
  List<String> order;
}