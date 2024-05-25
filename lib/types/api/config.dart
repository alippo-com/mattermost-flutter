// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Flutter representation of ClientConfig from Mattermost.
class ClientConfig {
  final String aboutLink;
  final String allowBannerDismissal;
  final String allowCustomThemes;
  final String allowEditPost;
  final String allowedThemes;
  final String androidAppDownloadLink;
  final String androidLatestVersion;
  final String androidMinVersion;
  final String appDownloadLink;
  final String asymmetricSigningPublicKey;
  final String availableLocales;
  final String bannerColor;
  final String bannerText;
  final String bannerTextColor;
  final String buildDate;
  final String buildEnterpriseReady;
  final String buildHash;
  final String buildHashEnterprise;
  final String buildNumber;
  final String closeUnusedDirectMessages;
  final String collapsedThreads;
  final String customBrandText;
  final String customDescriptionText;
  final String customTermsOfServiceId;
  final String customTermsOfServiceReAcceptancePeriod;
  final String customUrlSchemes;
  final String dataRetentionEnableFileDeletion;
  final String dataRetentionEnableMessageDeletion;
  final String dataRetentionFileRetentionDays;
  final String dataRetentionMessageRetentionDays;
  final String defaultClientLocale;
  final String defaultTheme;
  final String delayChannelAutocomplete;
  final String desktopLatestVersion;
  final String desktopMinVersion;
  final String diagnosticId;
  final String diagnosticsEnabled;
  final String emailLoginButtonBorderColor;
  final String emailLoginButtonColor;
  final String emailLoginButtonTextColor;
  final String emailNotificationContentsType;
  final String enableBanner;
  final String enableBotAccountCreation;
  final String enableChannelViewedMessages;
  final String enableCluster;
  final String enableCommands;
  final String enableCompliance;
  final String enableConfirmNotificationsToChannel;
  final String enableCustomBrand;
  final String enableCustomEmoji;
  final String enableCustomTermsOfService;
  final String enableCustomUserStatuses;
  final String enableDeveloper;
  final String enableDiagnostics;
  final String enableEmailBatching;
  final String enableEmailInvitations;
  final String enableEmojiPicker;
  final String enableFileAttachments;
  final String enableGifPicker;
  final String enableGuestAccounts;
  final String enableIncomingWebhooks;
  final String enableInlineLatex;
  final String enableLatex;
  final String enableLdap;
  final String enableLinkPreviews;
  final String enableMarketplace;
  final String enableMetrics;
  final String enableMobileFileDownload;
  final String enableMobileFileUpload;
  final String enableMultifactorAuthentication;
  final String enableOAuthServiceProvider;
  final String enableOpenServer;
  final String enableOutgoingWebhooks;
  final String enablePostIconOverride;
  final String enablePostUsernameOverride;
  final String enablePreviewFeatures;
  final String enablePreviewModeBanner;
  final String enablePublicLink;
  final String enableReliableWebSockets;
  final String enableSVGs;
  final String enableSaml;
  final String enableSignInWithEmail;
  final String enableSignInWithUsername;
  final String enableSignUpWithEmail;
  final String enableSignUpWithGitLab;
  final String enableSignUpWithGoogle;
  final String enableSignUpWithOffice365;
  final String enableSignUpWithOpenId;
  final String enableTesting;
  final String enableThemeSelection;
  final String enableTutorial;
  final String enableUserAccessTokens;
  final String enableUserCreation;
  final String enableUserDeactivation;
  final String enableUserTypingMessages;
  final String enableXToLeaveChannelsFromLHS;
  final String enforceMultifactorAuthentication;
  final String experimentalChannelOrganization;
  final String experimentalChannelSidebarOrganization;
  final String experimentalClientSideCertCheck;
  final String experimentalClientSideCertEnable;
  final String experimentalEnableAuthenticationTransfer;
  final String experimentalEnableAutomaticReplies;
  final String experimentalEnableClickToReply;
  final String experimentalEnableDefaultChannelLeaveJoinMessages;
  final String experimentalEnablePostMetadata;
  final String experimentalGroupUnreadChannels;
  final String experimentalHideTownSquareinLHS;
  final String experimentalNormalizeMarkdownLinks;
  final String experimentalPrimaryTeam;
  final String experimentalSharedChannels;
  final String experimentalTownSquareIsReadOnly;
  final String experimentalViewArchivedChannels;
  final String extendSessionLengthWithActivity;
  final String featureFlagAppsEnabled;
  final String featureFlagCollapsedThreads;
  final String featureFlagPostPriority;
  final String forgotPasswordLink;
  final String gfycatApiKey;
  final String gfycatApiSecret;
  final String googleDeveloperKey;
  final String guestAccountsEnforceMultifactorAuthentication;
  final String hasImageProxy;
  final String helpLink;
  final String hideGuestTags;
  final String iosAppDownloadLink;
  final String iosLatestVersion;
  final String iosMinVersion;
  final String ldapFirstNameAttributeSet;
  final String ldapLastNameAttributeSet;
  final String ldapLoginButtonBorderColor;
  final String ldapLoginButtonColor;
  final String ldapLoginButtonTextColor;
  final String ldapLoginFieldName;
  final String ldapNicknameAttributeSet;
  final String ldapPictureAttributeSet;
  final String ldapPositionAttributeSet;
  final String lockTeammateNameDisplay;
  final String maxFileSize;
  final String maxMarkdownNodes;
  final String maxNotificationsPerChannel;
  final String maxPostSize;
  final String minimumHashtagLength;
  final String openIdButtonColor;
  final String openIdButtonText;
  final String passwordEnableForgotLink;
  final String passwordMinimumLength;
  final String passwordRequireLowercase;
  final String passwordRequireNumber;
  final String passwordRequireSymbol;
  final String passwordRequireUppercase;
  final String pluginsEnabled;
  final String postEditTimeLimit;
  final String postPriority;
  final String postAcknowledgements;
  final String allowPersistentNotifications;
  final String persistentNotificationMaxRecipients;
  final String persistentNotificationInterval;
  final String allowPersistentNotificationsForGuests;
  final String persistentNotificationIntervalMinutes;
  final String privacyPolicyLink;
  final String reportAProblemLink;
  final String requireEmailVerification;
  final String restrictDirectMessage;
  final String runJobs;
  final String sqlDriverName;
  final String samlFirstNameAttributeSet;
  final String samlLastNameAttributeSet;
  final String samlLoginButtonBorderColor;
  final String samlLoginButtonColor;
  final String samlLoginButtonText;
  final String samlLoginButtonTextColor;
  final String samlNicknameAttributeSet;
  final String samlPositionAttributeSet;
  final String schemaVersion;
  final String sendEmailNotifications;
  final String sendPushNotifications;
  final String showEmailAddress;
  final String showFullName;
  final String siteName;
  final String siteURL;
  final String supportEmail;
  final String teammateNameDisplay;
  final String termsOfServiceLink;
  final String timeBetweenUserTypingUpdatesMilliseconds;
  final String version;
  final String websocketPort;
  final String websocketSecurePort;
  final String websocketURL;

  ClientConfig({
    required this.aboutLink,
    required this.allowBannerDismissal,
    required this.allowCustomThemes,
    required this.allowEditPost,
    required this.allowedThemes,
    required this.androidAppDownloadLink,
    required this.androidLatestVersion,
    required this.androidMinVersion,
    required this.appDownloadLink,
    required this.asymmetricSigningPublicKey,
    required this.availableLocales,
    required this.bannerColor,
    required this.bannerText,
    required this.bannerTextColor,
    required this.buildDate,
    required this.buildEnterpriseReady,
    required this.buildHash,
    required this.buildHashEnterprise,
    required this.buildNumber,
    required this.closeUnusedDirectMessages,
    required this.collapsedThreads,
    required this.customBrandText,
    required this.customDescriptionText,
    required this.customTermsOfServiceId,
    required this.customTermsOfServiceReAcceptancePeriod,
    required this.customUrlSchemes,
    required this.dataRetentionEnableFileDeletion,
    required this.dataRetentionEnableMessageDeletion,
    required this.dataRetentionFileRetentionDays,
    required this.dataRetentionMessageRetentionDays,
    required this.defaultClientLocale,
    required this.defaultTheme,
    required this.delayChannelAutocomplete,
    required this.desktopLatestVersion,
    required this.desktopMinVersion,
    required this.diagnosticId,
    required this.diagnosticsEnabled,
    required this.emailLoginButtonBorderColor,
    required this.emailLoginButtonColor,
    required this.emailLoginButtonTextColor,
    required this.emailNotificationContentsType,
    required this.enableBanner,
    required this.enableBotAccountCreation,
    required this.enableChannelViewedMessages,
    required this.enableCluster,
    required this.enableCommands,
    required this.enableCompliance,
    required this.enableConfirmNotificationsToChannel,
    required this.enableCustomBrand,
    required this.enableCustomEmoji,
    required this.enableCustomTermsOfService,
    required this.enableCustomUserStatuses,
    required this.enableDeveloper,
    required this.enableDiagnostics,
    required this.enableEmailBatching,
    required this.enableEmailInvitations,
    required this.enableEmojiPicker,
    required this.enableFileAttachments,
    required this.enableGifPicker,
    required this.enableGuestAccounts,
    required this.enableIncomingWebhooks,
    required this.enableInlineLatex,
    required this.enableLatex,
    required this.enableLdap,
    required this.enableLinkPreviews,
    required this.enableMarketplace,
    required this.enableMetrics,
    required this.enableMobileFileDownload,
    required this.enableMobileFileUpload,
    required this.enableMultifactorAuthentication,
    required this.enableOAuthServiceProvider,
    required this.enableOpenServer,
    required this.enableOutgoingWebhooks,
    required this.enablePostIconOverride,
    required this.enablePostUsernameOverride,
    required this.enablePreviewFeatures,
    required this.enablePreviewModeBanner,
    required this.enablePublicLink,
    required this.enableReliableWebSockets,
    required this.enableSVGs,
    required this.enableSaml,
    required this.enableSignInWithEmail,
    required this.enableSignInWithUsername,
    required this.enableSignUpWithEmail,
    required this.enableSignUpWithGitLab,
    required this.enableSignUpWithGoogle,
    required this.enableSignUpWithOffice365,
    required this.enableSignUpWithOpenId,
    required this.enableTesting,
    required this.enableThemeSelection,
    required this.enableTutorial,
    required this.enableUserAccessTokens,
    required this.enableUserCreation,
    required this.enableUserDeactivation,
    required this.enableUserTypingMessages,
    required this.enableXToLeaveChannelsFromLHS,
    required this.enforceMultifactorAuthentication,
    required this.experimentalChannelOrganization,
    required this.experimentalChannelSidebarOrganization,
    required this.experimentalClientSideCertCheck,
    required this.experimentalClientSideCertEnable,
    required this.experimentalEnableAuthenticationTransfer,
    required this.experimentalEnableAutomaticReplies,
    required this.experimentalEnableClickToReply,
    required this.experimentalEnableDefaultChannelLeaveJoinMessages,
    required this.experimentalEnablePostMetadata,
    required this.experimentalGroupUnreadChannels,
    required this.experimentalHideTownSquareinLHS,
    required this.experimentalNormalizeMarkdownLinks,
    required this.experimentalPrimaryTeam,
    required this.experimentalSharedChannels,
    required this.experimentalTownSquareIsReadOnly,
    required this.experimentalViewArchivedChannels,
    required this.extendSessionLengthWithActivity,
    required this.featureFlagAppsEnabled,
    required this.featureFlagCollapsedThreads,
    required this.featureFlagPostPriority,
    required this.forgotPasswordLink,
    required this.gfycatApiKey,
    required this.gfycatApiSecret,
    required this.googleDeveloperKey,
    required this.guestAccountsEnforceMultifactorAuthentication,
    required this.hasImageProxy,
    required this.helpLink,
    required this.hideGuestTags,
    required this.iosAppDownloadLink,
    required this.iosLatestVersion,
    required this.iosMinVersion,
    required this.ldapFirstNameAttributeSet,
    required this.ldapLastNameAttributeSet,
    required this.ldapLoginButtonBorderColor,
    required this.ldapLoginButtonColor,
    required this.ldapLoginButtonTextColor,
    required this.ldapLoginFieldName,
    required this.ldapNicknameAttributeSet,
    required this.ldapPictureAttributeSet,
    required this.ldapPositionAttributeSet,
    required this.lockTeammateNameDisplay,
    required this.maxFileSize,
    required this.maxMarkdownNodes,
    required this.maxNotificationsPerChannel,
    required this.maxPostSize,
    required this.minimumHashtagLength,
    required this.openIdButtonColor,
    required this.openIdButtonText,
    required this.passwordEnableForgotLink,
    required this.passwordMinimumLength,
    required this.passwordRequireLowercase,
    required this.passwordRequireNumber,
    required this.passwordRequireSymbol,
    required this.passwordRequireUppercase,
    required this.pluginsEnabled,
    required this.postEditTimeLimit,
    required this.postPriority,
    required this.postAcknowledgements,
    required this.allowPersistentNotifications,
    required this.persistentNotificationMaxRecipients,
    required this.persistentNotificationInterval,
    required this.allowPersistentNotificationsForGuests,
    required this.persistentNotificationIntervalMinutes,
    required this.privacyPolicyLink,
    required this.reportAProblemLink,
    required this.requireEmailVerification,
    required this.restrictDirectMessage,
    required this.runJobs,
    required this.sqlDriverName,
    required this.samlFirstNameAttributeSet,
    required this.samlLastNameAttributeSet,
    required this.samlLoginButtonBorderColor,
    required this.samlLoginButtonColor,
    required this.samlLoginButtonText,
    required this.samlLoginButtonTextColor,
    required this.samlNicknameAttributeSet,
    required this.samlPositionAttributeSet,
    required this.schemaVersion,
    required this.sendEmailNotifications,
    required this.sendPushNotifications,
    required this.showEmailAddress,
    required this.showFullName,
    required this.siteName,
    required this.siteURL,
    required this.supportEmail,
    required this.teammateNameDisplay,
    required this.termsOfServiceLink,
    required this.timeBetweenUserTypingUpdatesMilliseconds,
    required this.version,
    required this.websocketPort,
    required this.websocketSecurePort,
    required this.websocketURL,
  });
}
