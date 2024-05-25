// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

const AT_MENTION_REGEX = r'/\B(@([^@\r\n]*))$/i';

const AT_MENTION_REGEX_GLOBAL = r'/\B(@([^@\r\n]*))/gi';

const AT_MENTION_SEARCH_REGEX = r'/\bfrom:\s*([^\r\n]*)$/i';

const CHANNEL_MENTION_REGEX = r'/\B(~([^~\r\n]*))$/i';

const CHANNEL_MENTION_REGEX_DELAYED = r'/\B(~([^~\r\n]{2,}))$/i';

const CHANNEL_MENTION_SEARCH_REGEX = r'/\b(?:in|channel):\s*([^\r\n]*)$/i';

const DATE_MENTION_SEARCH_REGEX = r'/\b(?:on|before|after):\s*(\S*)$/i';

const ALL_SEARCH_FLAGS_REGEX = r'/\b\w+:/g';

const CODE_REGEX =
    r'/(`+)([^`]|[^`][\s\S]*?[^`])\1(?!`)| *(`{3,}|~{3,})[ .]*(\S+)? *\n([\s\S]*?\s*)\3 *(?:\n+|$)/g';

const MENTIONS_REGEX = r'/(?:\B|\b_+)@([\p{L}0-9.\-_]+)(?<![.])/gui';

const SPECIAL_MENTIONS_REGEX =
    r'/(?:\B|\b_+)@(channel|all|here)(?!(\.|-|_)*[^\W_])/gi';

const MAX_LIST_HEIGHT = 230;
const MAX_LIST_TABLET_DIFF = 90;
