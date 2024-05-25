
    final sendActionDisabled = !canSend || mentionsData['noMentionsError'];

    return Column(
      children: [
        Typing(channelId: channelId, rootId: rootId),
        SafeArea(
          left: true,
          right: true,
          child: Container(
            onLayout: handleLayout,
            decoration: style.inputWrapper,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 7),
              child: Column(
                children: [
                  Header(noMentionsError: mentionsData['noMentionsError'], postPriority: postPriority),
                  PostInput(
                    testID: testID,
                    channelId: channelId,
                    maxMessageLength: maxMessageLength,
                    rootId: rootId,
                    cursorPosition: cursorPosition,
                    updateCursorPosition: updateCursorPosition,
                    updateValue: updateValue,
                    value: value,
                    addFiles: addFiles,
                    sendMessage: handleSendMessage,
                    inputRef: inputRef,
                    setIsFocused: setIsFocused,
                  ),
                  Uploads(
                    currentUserId: currentUserId,
                    files: files,
                    uploadFileError: uploadFileError,
                    channelId: channelId,
                    rootId: rootId,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuickActions(
                        testID: testID,
                        fileCount: files.length,
                        addFiles: addFiles,
                        updateValue: updateValue,
                        value: value,
                        postPriority: postPriority,
                        updatePostPriority: updatePostPriority,
                        canShowPostPriority: canShowPostPriority,
                        focus: focus,
                      ),
                      SendAction(
                        testID: testID,
                        disabled: sendActionDisabled,
                        sendMessage: handleSendMessage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
