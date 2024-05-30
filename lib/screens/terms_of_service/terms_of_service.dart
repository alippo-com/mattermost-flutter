import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/button.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class TermsOfService extends StatefulWidget {
  final String siteName;
  final bool showToS;
  final String componentId;

  TermsOfService({
    this.siteName = 'Mattermost',
    required this.showToS,
    required this.componentId,
  });

  @override
  _TermsOfServiceState createState() => _TermsOfServiceState();
}

class _TermsOfServiceState extends State<TermsOfService> {
  late ThemeData theme;
  late String serverUrl;
  late EdgeInsets insets;

  bool loading = true;
  bool getTermsError = false;
  String termsId = '';
  String termsText = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Provider.of<ThemeContext>(context).theme;
    serverUrl = Provider.of<ServerContext>(context).serverUrl;
    insets = MediaQuery.of(context).viewPadding;
    getTerms();
  }

  Future<void> getTerms() async {
    setState(() {
      loading = true;
      getTermsError = false;
    });

    final terms = await fetchTermsOfService(serverUrl);
    if (terms != null) {
      setState(() {
        loading = false;
        termsId = terms.id;
        termsText = terms.text;
      });
    } else {
      setState(() {
        loading = false;
        getTermsError = true;
      });
    }
  }

  void closeTermsAndLogout() {
    Navigator.of(context).pop();
    logout(serverUrl);
  }

  void alertError(Function retry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.siteName),
        content: Text(
          'Unable to complete the request. If this issue persists, contact your System Administrator.',
        ),
        actions: [
          TextButton(
            onPressed: closeTermsAndLogout,
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => retry(),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void alertDecline() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'You must accept the terms of service',
        ),
        content: Text(
          'You must accept the terms of service to access this server. Please contact your system administrator for more details. You will now be logged out. Log in again to accept the terms of service.',
        ),
        actions: [
          TextButton(
            onPressed: closeTermsAndLogout,
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> acceptTerms() async {
    setState(() {
      loading = true;
    });

    final error = await updateTermsOfServiceStatus(serverUrl, termsId, true);
    if (error != null) {
      alertError(acceptTerms);
    }
  }

  Future<void> declineTerms() async {
    setState(() {
      loading = true;
    });

    final error = await updateTermsOfServiceStatus(serverUrl, termsId, false);
    if (error != null) {
      alertError(declineTerms);
    } else {
      alertDecline();
    }
  }

  void onPressClose() {
    if (getTermsError) {
      closeTermsAndLogout();
    } else {
      declineTerms();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = Center(
        child: Loading(color: theme.primaryColor),
      );
    } else if (getTermsError) {
      content = Column(
        children: [
          Text(
            'Failed to get the ToS.',
            style: theme.textTheme.titleLarge,
          ),
          Text(
            'It was not possible to get the Terms of Service from the Server.',
            style: theme.textTheme.bodyMedium,
          ),
          Button(
            onPress: getTerms,
            text: 'Retry',
            theme: theme,
          ),
          Button(
            onPress: onPressClose,
            text: 'Logout',
            theme: theme,
            buttonType: ButtonType.link,
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Markdown(
                data: termsText,
                styleSheet: markdownStyleSheetFromTheme(theme),
              ),
            ),
          ),
          Button(
            onPress: acceptTerms,
            text: 'Accept',
            theme: theme,
          ),
          Button(
            onPress: onPressClose,
            text: 'Decline',
            theme: theme,
            buttonType: ButtonType.link,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.5),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              insets.left + 24,
              insets.top + 24,
              insets.right + 24,
              insets.bottom,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Terms of Service',
                      style: theme.textTheme.headlineSmall,
                    ),
                    content,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
