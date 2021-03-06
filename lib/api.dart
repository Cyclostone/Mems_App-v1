import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/storage.dart';
import 'package:mime/mime.dart';

class CloudApi {
  final auth.ServiceAccountCredentials _credentials;
  auth.AutoRefreshingAuthClient _client;

  CloudApi(String json)
      : _credentials = auth.ServiceAccountCredentials.fromJson(json);

  Future<ObjectInfo> save(String name, Uint8List imgBytes) async {
    // Create a Client
    if (_client == null)
      _client =
          await auth.clientViaServiceAccount(_credentials, Storage.SCOPES);

    // TODO Instantiate objects to Cloud Storage
    var storage = Storage(_client, 'flutterImageUpload-v1');
    var bucket = storage.bucket('firstbucket_06032021');

    //TODO Save to Bucket
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final type = lookupMimeType(name);
    return await bucket.writeBytes(name, imgBytes,
        metadata: ObjectMetadata(contentType: type, custom: {
          'timestamp': '$timestamp',
        }));
  }
}
