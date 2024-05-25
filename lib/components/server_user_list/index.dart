import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/user_list.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/helpers/api/general.dart';
import 'package:mattermost_flutter/utils/user.dart';

class ServerUserList extends StatefulWidget {
  final String currentUserId;
  final bool tutorialWatched;
  final Function(UserProfile) handleSelectProfile;
  final String term;
  final Map<String, UserProfile> selectedIds;
  final Future<List<UserProfile>> Function(int) fetchFunction;
  final Future<List<UserProfile>> Function(String) searchFunction;
  final Function(List<UserProfile>, String) createFilter;
  final String testID;

  const ServerUserList({
    Key? key,
    required this.currentUserId,
    required this.tutorialWatched,
    required this.handleSelectProfile,
    required this.term,
    required this.selectedIds,
    required this.fetchFunction,
    required this.searchFunction,
    required this.createFilter,
    required this.testID,
  }) : super(key: key);

  @override
  _ServerUserListState createState() => _ServerUserListState();
}

class _ServerUserListState extends State<ServerUserList> {
  final searchTimeoutId = useRef<Timeout>(null);
  final next = useRef(true);
  final page = useRef(-1);
  final mounted = useRef(false);

  List<UserProfile> profiles = [];
  List<UserProfile> searchResults = [];
  bool loading = false;

  bool get isSearch => widget.term.isNotEmpty;

  @override
  void initState() {
    super.initState();
    mounted.current = true;
    getProfiles();
  }

  @override
  void dispose() {
    mounted.current = false;
    super.dispose();
  }

  void loadedProfiles(List<UserProfile> users) {
    if (mounted.current) {
      if (users.isEmpty) {
        next.current = false;
      }

      page.current += 1;
      setState(() {
        loading = false;
        profiles = [...profiles, ...users];
      });
    }
  }

  void getProfiles() {
    if (next.current && !loading && widget.term.isEmpty && mounted.current) {
      setState(() {
        loading = true;
      });
      widget.fetchFunction(page.current + 1).then(loadedProfiles);
    }
  }

  void searchUsers(String searchTerm) async {
    setState(() {
      loading = true;
    });
    final data = await widget.searchFunction(searchTerm);
    setState(() {
      searchResults = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = useMemo(() {
      if (isSearch) {
        final exactMatches = <UserProfile>[];
        final filterByTerm = widget.createFilter(exactMatches, widget.term);

        final profilesToFilter = searchResults.isNotEmpty ? searchResults : profiles;
        final results = filterProfilesMatchingTerm(profilesToFilter, widget.term).where(filterByTerm).toList();
        return [...exactMatches, ...results];
      }
      return profiles;
    }, [widget.term, isSearch, isSearch && searchResults, profiles]);

    return UserList(
      currentUserId: widget.currentUserId,
      handleSelectProfile: widget.handleSelectProfile,
      loading: loading,
      profiles: data,
      selectedIds: widget.selectedIds,
      showNoResults: !loading && page.current != -1,
      fetchMore: getProfiles,
      term: widget.term,
      testID: widget.testID,
      tutorialWatched: widget.tutorialWatched,
      includeUserMargin: true,
    );
  }
}
