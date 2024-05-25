
  @override
  Future<Map<String, dynamic>> getAllGroupsAssociatedToTeam(
    String teamId, {
    bool filterAllowReference = false,
  }) async {
    return this.doFetch(
      '${this.urlVersion}/teams/$teamId/groups${buildQueryString({
        'paginate': false,
        'filter_allow_reference': filterAllowReference,
      })}',
      {'method': 'get'},
    );
  }
}
