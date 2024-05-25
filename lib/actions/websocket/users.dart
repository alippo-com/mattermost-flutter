void recordingAlert(bool isHost, bool transcriptionsEnabled, IntlShape intl) {
  if (recordingAlertLock) {
    return;
  }
  recordingAlertLock = true;

  final formatMessage = intl.formatMessage;

  final hostTitle = formatMessage('mobile.calls_host_rec_title', 'You are recording');
  final hostMessage = formatMessage('mobile.calls_host_rec', 'Consider letting everyone know that this meeting is being recorded.');

  final participantTitle = formatMessage('mobile.calls_participant_rec_title', 'Recording is in progress');
  final participantMessage = formatMessage('mobile.calls_participant_rec', 'The host has started recording this meeting. By staying in the meeting you give consent to being recorded.');

  final hostTranscriptionTitle = formatMessage('mobile.calls_host_transcription_title', 'Recording and transcription has started');
  final hostTranscriptionMessage = formatMessage('mobile.calls_host_transcription', 'Consider letting everyone know that this meeting is being recorded and transcribed.');

  final participantTranscriptionTitle = formatMessage('mobile.calls_participant_transcription_title', 'Recording and transcription is in progress');
  final participantTranscriptionMessage = formatMessage('mobile.calls_participant_transcription', 'The host has started recording and transcription for this meeting. By staying in the meeting, you give consent to being recorded and transcribed.');

  final hTitle = transcriptionsEnabled ? hostTranscriptionTitle : hostTitle;
  final hMessage = transcriptionsEnabled ? hostTranscriptionMessage : hostMessage;
  final pTitle = transcriptionsEnabled ? participantTranscriptionTitle : participantTitle;
  final pMessage = transcriptionsEnabled ? participantTranscriptionMessage : participantMessage;

  final participantButtons = <Widget>[
    TextButton(
      child: Text(formatMessage('mobile.calls_leave', 'Leave')),
      onPressed: () async {
        await leaveCall();
      },
    ),
    TextButton(
      child: Text(formatMessage('mobile.calls_okay', 'Okay')),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  ];
  final hostButton = [
    TextButton(
      child: Text(formatMessage('mobile.calls_dismiss', 'Dismiss')),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(isHost ? hTitle : pTitle),
        content: Text(isHost ? hMessage : pMessage),
        actions: isHost ? hostButton : participantButtons,
      );
    },
  );
}

void needsRecordingWillBePostedAlert() {
  recordingWillBePostedLock = false;
}
