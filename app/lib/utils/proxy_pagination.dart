import 'package:nitella_app/local/nitella_local.pb.dart' as local;
import 'package:nitella_app/local/nitella_local.pbgrpc.dart' as local_grpc;

Future<List<local.ProxyInfo>> listAllNodeProxiesPaginated({
  required local_grpc.MobileLogicServiceClient client,
  required String nodeId,
  int pageSize = 200,
  int maxPages = 100,
}) async {
  final proxies = <local.ProxyInfo>[];
  var offset = 0;
  var pages = 0;
  var totalCount = 0;

  while (pages < maxPages) {
    pages++;
    final resp = await client.listProxies(local.ListProxiesRequest(
      nodeId: nodeId,
      limit: pageSize,
      offset: offset,
    ));
    totalCount = resp.totalCount;
    final page = resp.proxies;
    if (page.isEmpty) {
      break;
    }
    proxies.addAll(page);
    offset += page.length;
    if (offset >= totalCount) {
      break;
    }
  }

  return proxies;
}
