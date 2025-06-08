import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../repo/navigation_repo.dart';

class MapService {


  final NavigationRepo navigationRepo = NavigationRepo();


  static Future<Map<String, dynamic>> loadMapData() async {
    final jsonString = await rootBundle.loadString('assets/map_data.json');
    return jsonDecode(jsonString);
  }
  static Future<Map<String, dynamic>> loadVenueNodes(int currentFloorId) async {
    return await NavigationRepo.getVenueNodes(currentFloorId);
  }

  

  // static Future<List<NavPath>> loadPaths() async {
  //   final data = await loadMapData();
  //   final paths = <NavPath>[];

  //   for (var edge in data['edges']) {
  //     paths.add(NavPath(
  //       id: '${edge['from'][0]}-${edge['from'][1]}_to_${edge['to'][0]}-${edge['to'][1]}',
  //       points: [
  //         Offset(edge['from'][0].toDouble(), edge['from'][1].toDouble()),
  //         Offset(edge['to'][0].toDouble(), edge['to'][1].toDouble()),
  //       ],
  //     ));
  //   }

  //   return paths;
  // }

  // static Future<List<MapNode>> loadNodes() async {
  //   final data = await loadMapData();
  //   return (data['nodes'] as List).map((node) {
  //     return MapNode(
  //       id: '${node['x']}-${node['y']}',
  //       position: Offset(node['x'].toDouble(), node['y'].toDouble()),
  //     );
  //   }).toList();
  // }

  // static Future<List<MapNode>> loadPois() async {
  //   final data = await loadMapData();
  //   return (data['pois'] as List).map((poi) {
  //     return MapNode(
  //       id: poi['label'],
  //       position: Offset(poi['x'].toDouble(), poi['y'].toDouble()),
  //       label: poi['label'],
  //       color: Colors.red,
  //       radius: 8.0,
  //     );
  //   }).toList();
  // }

  // static Future<List<String>> loadPoisName() async {

  //   final data = await loadPois();
  //   int i = 0;
  //   List<String> poiNameList = [] ;
  //   while( i < data.length){
  //     poiNameList.add(data[i].id);
  //     i ++;
  //   }

  //  return poiNameList;
  // }

  // Simpler and often preferred way using PictureInfo:
  static Future<Size> getSvgSize(String assetPath) async {
    final String svgString = await rootBundle.loadString(assetPath);
    final SvgStringLoader svgLoader = SvgStringLoader(svgString);
    final PictureInfo pictureInfo = await vg.loadPicture(svgLoader, null);
    return pictureInfo.size;
  }

// static Future<Size> getSvgSize() async {
  //
  //   final data = await loadMapData();
  //   return Size(
  //     data['svg_dimensions']['width'].toDouble(),
  //     data['svg_dimensions']['height'].toDouble(),
  //   );
  // }
  //
  // // static Future<List<MapNode>> loadNodes() async {
  // //   // final data = await loadMapData();
  // //
  // //   //mock data
  // //   List<MapNode> mapNodes = [];
  // //   MapNode MKP1 = MapNode(id: "MKP1", position: Offset(1671.25, 561.03));
  // //   MapNode MKP2 = MapNode(id: "MKP2", position: Offset(1837.12, 795.16));
  // //   MapNode MKP5 = MapNode(id: "test2", position: Offset(300.12, 400.16));
  // //
  // //   mapNodes.add(MKP1);
  // //   mapNodes.add(MKP2);
  // //   mapNodes.add(MKP5);
  // //   // return (data['nodes'] as List).map((node) {
  // //   //   return MapNode(
  // //   //     id: '${node['x']}-${node['y']}',
  // //   //     position: Offset(node['x'].toDouble(), node['y'].toDouble()),
  // //   //   );
  // //   // }).toList();
  // //   return mapNodes;
  // // }


  // // 新方法：从API获取导航路径
  // static Future<NavigationResponse> fetchNavigationPath(String source, String destination) async {
  //   // static Future<List<Offset>> fetchNavigationPath(Offset start, Offset end) async {
  //   // 模拟API调用，实际项目中替换为真实API请求
  //   print("service fetchNavigationPath");
  //   final response = await NavigationRepo.getNavigationPath(source: source, destination: destination);


  //   // // 这里应该是从API获取的响应数据
  //   // final mockResponse = {
  //   //   "path": [
  //   // [1671.25, 561.03],
  //   //     [1646.7, 575.47],
  //   //     [1701.15, 657.07],
  //   //     [1603.92, 724.99],
  //   //     [1671.49, 823.88],
  //   //     [1635.08, 850.38],
  //   //     [1598.44, 876.57],
  //   //     [1584.62, 857.24],
  //   //     [1543.18, 799.27],
  //   //
  //   //
  //   //     [1517.17, 816.66]
  //   //   ]
  //   // };

  //   return response;
  // }

  // 新方法：创建导航路径
  // static Future<NavPath> createNavigationPath(String source, String destination) async {
  //
  //   List<Offset> points = await fetchNavigationPath(source,destination);
  //   return NavPath(
  //     id: 'navigation_path_${DateTime.now().millisecondsSinceEpoch}',
  //     points: points,
  //     color: Colors.blue,
  //     width: 6.0,
  //   );
  // }

  // static Future<MapMarker> getUserLocation() async{
  //
  //   List<Offset> points = await fetchNavigationPath();
  //
  //   // Mock Response : Fetch user offset
  //   Offset startPoint = points[0];
  //   return MapMarker(
  //     position: startPoint,
  //     label: 'You',
  //     color: Colors.blue, // Differentiate user marker
  //     radius: 15.0, // Slightly larger
  //   );
  //
  // }




}