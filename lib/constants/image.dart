
// Converted from ./mattermost-mobile/app/constants/image.ts
// In Dart, instead of exporting a class, we use a class with static variables where we need to use them.
// The original file content is as follows:

/*
export const IMAGE_MAX_HEIGHT = 350;
export const IMAGE_MIN_DIMENSION = 50;
export const MAX_GIF_SIZE = 100 * 1024 * 1024;
export const VIEWPORT_IMAGE_OFFSET = 70;
export const VIEWPORT_IMAGE_REPLY_OFFSET = 11;
export const MAX_RESOLUTION = 7680 * 4320; // 8K, ~33MPX

export default {
    IMAGE_MAX_HEIGHT,
    IMAGE_MIN_DIMENSION,
    MAX_GIF_SIZE,
    MAX_RESOLUTION,
    VIEWPORT_IMAGE_OFFSET,
    VIEWPORT_IMAGE_REPLY_OFFSET,
};
*/

// Dart equivalent
class ImageConstants {
    static const int IMAGE_MAX_HEIGHT = 350;
    static const int IMAGE_MIN_DIMENSION = 50;
    static const int MAX_GIF_SIZE = 100 * 1024 * 1024;
    static const int VIEWPORT_IMAGE_OFFSET = 70;
    static const int VIEWPORT_IMAGE_REPLY_OFFSET = 11;
    static const int MAX_RESOLUTION = 7680 * 4320; // 8K, ~33MPX
}
