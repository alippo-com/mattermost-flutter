
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/error.dart';
import 'package:mattermost_flutter/base.dart';

class PoliciesResponse<T> {
  List<T> policies;
  int totalCount;

  PoliciesResponse({required this.policies, required this.totalCount});
}

abstract class ClientGeneralMix {
  Future<dynamic> ping({String? deviceId, int? timeoutInterval});
  Future<dynamic> logClientError(String message, {String level = 'ERROR'});
  Future<ClientConfig> getClientConfigOld();
  Future<ClientLicense> getClientLicenseOld();
  Future<List<String>> getTimezones();
  Future<GlobalDataRetentionPolicy> getGlobalDataRetentionPolicy();
  Future<PoliciesResponse<TeamDataRetentionPolicy>> getTeamDataRetentionPolicies(String userId, {int page = 0, int perPage = PER_PAGE_DEFAULT});
  Future<PoliciesResponse<ChannelDataRetentionPolicy>> getChannelDataRetentionPolicies(String userId, {int page = 0, int perPage = PER_PAGE_DEFAULT});
  Future<List<Role>> getRolesByNames(List<String> rolesNames);
  Future<Map<String, String>> getRedirectLocation(String urlParam);
}

class ClientGeneral<TBase extends ClientBase> extends TBase implements ClientGeneralMix {
  @override
  Future<dynamic> ping({String? deviceId, int? timeoutInterval}) async {
    var url = '${this.urlVersion}/system/ping?time=${DateTime.now().millisecondsSinceEpoch}';
    if (deviceId != null) {
      url = '$url&device_id=$deviceId';
    }
    return this.doFetch(url, method: 'get', timeoutInterval: timeoutInterval);
  }

  @override
  Future<dynamic> logClientError(String message, {String level = 'ERROR'}) async {
    final url = '${this.urlVersion}/logs';
    if (!this.enableLogging) {
      throw ClientError(this.apiClient.baseUrl, message: 'Logging disabled.', url: url);
    }
    return this.doFetch(url, method: 'post', body: {'message': message, 'level': level});
  }

  @override
  Future<ClientConfig> getClientConfigOld() async {
    return this.doFetch('${this.urlVersion}/config/client?format=old', method: 'get');
  }

  @override
  Future<ClientLicense> getClientLicenseOld() async {
    return this.doFetch('${this.urlVersion}/license/client?format=old', method: 'get');
  }

  @override
  Future<List<String>> getTimezones() async {
    return this.doFetch('${this.getTimezonesRoute()}', method: 'get');
  }

  @override
  Future<GlobalDataRetentionPolicy> getGlobalDataRetentionPolicy() async {
    return this.doFetch('${this.getGlobalDataRetentionRoute()}/policy', method: 'get');
  }

  @override
  Future<PoliciesResponse<TeamDataRetentionPolicy>> getTeamDataRetentionPolicies(String userId, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    return this.doFetch('${this.getGranularDataRetentionRoute(userId)}/team_policies${buildQueryString({'page': page, 'per_page': perPage})}', method: 'get');
  }

  @override
  Future<PoliciesResponse<ChannelDataRetentionPolicy>> getChannelDataRetentionPolicies(String userId, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    return this.doFetch('${this.getGranularDataRetentionRoute(userId)}/channel_policies${buildQueryString({'page': page, 'per_page': perPage})}', method: 'get');
  }

  @override
  Future<List<Role>> getRolesByNames(List<String> rolesNames) async {
    return this.doFetch('${this.getRolesRoute()}/names', method: 'post', body: rolesNames);
  }

  @override
  Future<Map<String, String>> getRedirectLocation(String urlParam) async {
    if (urlParam.isEmpty) {
      return {};
    }
    final url = '${this.getRedirectLocationRoute()}${buildQueryString({'url': urlParam})}';
    return this.doFetch(url, method: 'get');
  }
}
