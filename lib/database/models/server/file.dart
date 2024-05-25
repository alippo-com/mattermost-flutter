// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/file_model_interface.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

const FILE = MM_TABLES.SERVER['FILE'];
const POST = MM_TABLES.SERVER['POST'];

/**
 * The File model works in pair with the Post model. It hosts information about the files attached to a Post
 */
class FileModel extends Model with FileModelInterface {
  /** table (name) : File */
  static final String tableName = FILE;

  /** associations : Describes every relationship to this table. */
  static final Map<String, Association> associations = {
    /** A POST has a 1:N relationship with FILE. */
    POST: Association(type: AssociationType.belongsTo, key: 'post_id'),
  };

  /** extension : The file's extension */
  @Field('extension')
  late String extension;

  /** height : The height for the image */
  @Field('height')
  late int height;

  /** image_thumbnail : A base64 representation of an image */
  @Field('image_thumbnail')
  late String imageThumbnail;

  /** local_path : Local path of the file that has been uploaded to server */
  @Field('local_path')
  late String localPath;

  /** mime_type : The media type */
  @Field('mime_type')
  late String mimeType;

  /** name : The name for the file object */
  @Field('name')
  late String name;

  /** post_id : The foreign key of the related Post model */
  @Field('post_id')
  late String postId;

  /** size : The numeric value of the size for the file */
  @Field('size')
  late int size;

  /** width : The width of the file object/image */
  @Field('width')
  late int width;

  /** post : The related Post record for this file */
  @ImmutableRelation(POST, 'post_id')
  late Relation<PostModel> post;

  FileInfo toFileInfo(String authorId) {
    return FileInfo(
      id: id,
      userId: authorId,
      postId: postId,
      name: name,
      extension: extension,
      miniPreview: imageThumbnail,
      size: size,
      mimeType: mimeType,
      height: height,
      hasPreviewImage: imageThumbnail.isNotEmpty,
      localPath: localPath,
      width: width,
    );
  }
}
