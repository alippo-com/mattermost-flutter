
    // Converted from ./mattermost-mobile/app/constants/deep_linking.ts
    // In Dart, instead of exporting a class, we use a class with static variables where we need to use them.
    // The original file content is as follows:

    /*
    const DeepLinkType = {
        Channel: 'channel',
        DirectMessage: 'dm',
        GroupMessage: 'gm',
        Invalid: 'invalid',
        Permalink: 'permalink',
        Redirect: '_redirect',
    } as const;

    export default DeepLinkType;
    */

    // Dart equivalent
    class DeepLinkType {
        static const String Channel = 'channel';
        static const String DirectMessage = 'dm';
        static const String GroupMessage = 'gm';
        static const String Invalid = 'invalid';
        static const String Permalink = 'permalink';
        static const String Redirect = '_redirect';
    }
    