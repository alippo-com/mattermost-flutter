// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.


abstract class ClientEmojisMix {
  Future<CustomEmoji> getCustomEmoji(String id);
  Future<CustomEmoji> getCustomEmojiByName(String name);
  Future<List<CustomEmoji>> getCustomEmojis({int page = 0, int perPage = PER_PAGE_DEFAULT, String sort = ''});
  String getSystemEmojiImageUrl(String filename);
  String getCustomEmojiImageUrl(String id);
  Future<List<CustomEmoji>> searchCustomEmoji(String term, {Map<String, dynamic> options = const {}});
  Future<List<CustomEmoji>> autocompleteCustomEmoji(String name);
}

class ClientEmojis<TBase extends ClientBase> extends TBase {
  Future<CustomEmoji> getCustomEmoji(String id) async {
    return this.doFetch(
        '${this.getEmojisRoute()}/$id',
        {'method': 'get'},
    );
  }

  Future<CustomEmoji> getCustomEmojiByName(String name) async {
    return this.doFetch(
        '${this.getEmojisRoute()}/name/$name',
        {'method': 'get'},
    );
  }

  Future<List<CustomEmoji>> getCustomEmojis({int page = 0, int perPage = PER_PAGE_DEFAULT, String sort = ''}) async {
    return this.doFetch(
        '${this.getEmojisRoute()}${buildQueryString({'page': page, 'per_page': perPage, 'sort': sort})}',
        {'method': 'get'},
    );
  }

  String getSystemEmojiImageUrl(String filename) {
    return '${this.apiClient.baseUrl}static/emoji/$filename.png';
  }

  String getCustomEmojiImageUrl(String id) {
    return '${this.apiClient.baseUrl}${this.getEmojiRoute(id)}/image';
  }

  Future<List<CustomEmoji>> searchCustomEmoji(String term, {Map<String, dynamic> options = const {}}) async {
    return this.doFetch(
        '${this.getEmojisRoute()}/search',
        {'method': 'post', 'body': {'term': term, ...options}},
    );
  }

  Future<List<CustomEmoji>> autocompleteCustomEmoji(String name) async {
    return this.doFetch(
        '${this.getEmojisRoute()}/autocomplete${buildQueryString({'name': name})}',
        {'method': 'get'},
    );
  }
}
