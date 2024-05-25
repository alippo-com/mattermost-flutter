
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:core';

List<String> splitLatexCodeInLines(String content) {
    var outLines = content.split('\\');

    var i = 0;
    while (i < outLines.length) {
        if (testLatexLineBreak(outLines[i])) { //Line has no linebreak in between brackets
            i += 1;
        } else if (i < outLines.length - 1) {
            outLines = outLines.sublist(0, i)..add(outLines[i] + '\\' + outLines[i + 1])..addAll(outLines.sublist(i + 2));
        } else {
            break;
        }
    }

    return outLines.map((line) => line.trim()).toList();
}

bool testLatexLineBreak(String latexCode) {
    var beginCases = 0;
    var endCases = 0;

    var i = 0;
    while (i < latexCode.length) {
        var firstBegin = latexCode.indexOf('\begin{', i);
        var firstEnd = latexCode.indexOf('\end{', i);

        if (firstBegin == -1 && firstEnd == -1) {
            break;
        }

        if (firstBegin != -1 && (firstBegin < firstEnd || firstEnd == -1)) {
            if (latexCode[firstBegin - 1] != '\') {
                beginCases += 1;
            }
            i = firstBegin + '\begin{'.length;
        } else {
            if (latexCode[firstEnd - 1] != '\') {
                endCases += 1;
            }
            i = firstEnd + '\end{'.length;
        }
    }

    if (beginCases != endCases) {
        return false;
    }

    var curlyOpenCases = 0;
    var curlyCloseCases = 0;

    i = 0;
    while (i < latexCode.length) {
        var firstBegin = latexCode.indexOf('{', i);
        var firstEnd = latexCode.indexOf('}', i);

        if (firstBegin == -1 && firstEnd == -1) {
            break;
        }

        if (firstBegin != -1 && (firstBegin < firstEnd || firstEnd == -1)) {
            if (latexCode[firstBegin - 1] != '\') {
                curlyOpenCases += 1;
            }
            i = firstBegin + 1;
        } else {
            if (latexCode[firstEnd - 1] != '\') {
                curlyCloseCases += 1;
            }
            i = firstEnd + 1;
        }
    }

    if (curlyOpenCases != curlyCloseCases) {
        return false;
    }

    return true;
}
