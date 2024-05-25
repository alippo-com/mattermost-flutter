String nonBreakingString(String s) {
    return s.replaceAll(' ', '\xa0');
}
