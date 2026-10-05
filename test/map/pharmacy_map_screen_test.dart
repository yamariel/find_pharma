import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:find_pharma/map/pharmacy_map_screen.dart';
import 'package:find_pharma/map/models/map_pharmacy.dart';
import 'package:find_pharma/map/services/location_service.dart';
import 'package:find_pharma/map/services/routing_service.dart';

import 'map_controller_test.dart'
    show FakeLocation, FakeRouting, pharmacies, road;

class MemoryTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
        ),
      );
}

void main() {
  late FakeLocation location;
  late FakeRouting routing;
  setUp(() {
    location = FakeLocation();
    routing = FakeRouting();
  });
  Future<void> show(
    WidgetTester tester, {
    List<MapPharmacy>? data,
    MedicineContext? medicine,
    String? selectedId,
    ValueChanged<MapPharmacy>? onView,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PharmacyMapScreen(
          pharmacies: data ?? pharmacies,
          medicine: medicine,
          selectedPharmacyId: selectedId,
          locationService: location,
          routingService: routing,
          tileProvider: MemoryTiles(),
          onViewPharmacy: onView,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'map available without position, marker selection and detail callback',
    (tester) async {
      MapPharmacy? viewed;
      await show(tester, onView: (p) => viewed = p);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.textContaining('Kinshasa'), findsOneWidget);
      expect(location.calls, 0);
      await tester.tap(find.byTooltip('A, Ouverture inconnue'));
      await tester.pumpAndSettle();
      expect(find.text('Présence des vendeurs non renseignée'), findsOneWidget);
      await tester.ensureVisible(find.text('Voir la pharmacie'));
      await tester.tap(find.text('Voir la pharmacie'));
      expect(viewed?.id, 'a');
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty medicine result remains a browsable map', (tester) async {
    await show(
      tester,
      data: [],
      medicine: const MedicineContext(id: 'm', label: 'Test'),
    );
    expect(find.text('Aucun résultat pour ce médicament.'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(PolylineLayer), findsNothing);
  });
  testWidgets('denied position does not hide pharmacies', (tester) async {
    location.failure = const LocationFailure(LocationProblem.denied);
    await show(tester);
    await tester.tap(find.byTooltip('Me localiser et recentrer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Localisation refusée'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byTooltip('A, Ouverture inconnue'), findsOneWidget);
  });
  testWidgets('road polyline, metrics and clear action', (tester) async {
    await show(tester, selectedId: 'a');
    await tester.ensureVisible(find.text('Itinéraire'));
    await tester.tap(find.text('Itinéraire'));
    await tester.pump();
    await tester.pump();
    routing.requests.single.complete(road(2500));
    await tester.pumpAndSettle();
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.textContaining('2.5 km par la route'), findsOneWidget);
    final camera = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .mapController!
        .camera;
    for (final point in road(2500).points) {
      expect(camera.visibleBounds.contains(point), isTrue);
    }
    await tester.ensureVisible(find.text('Effacer le trajet'));
    await tester.tap(find.text('Effacer le trajet'));
    await tester.pumpAndSettle();
    expect(find.byType(PolylineLayer), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('identical coordinates can be selected individually', (
    tester,
  ) async {
    final overlapping = [
      pharmacies.first,
      MapPharmacy(
        id: 'c',
        name: 'C',
        latitude: pharmacies.first.latitude,
        longitude: pharmacies.first.longitude,
      ),
    ];
    await show(tester, data: overlapping);
    await tester.tap(find.byTooltip('2 pharmacies'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();
    expect(find.text('C'), findsOneWidget);
    expect(find.text('Itinéraire'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('small landscape viewport has no overflow', (tester) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await show(tester, selectedId: 'a');
    expect(tester.takeException(), isNull);
  });
  testWidgets('routing failure is shown without drawing a substitute route', (
    tester,
  ) async {
    await show(tester, selectedId: 'a');
    await tester.ensureVisible(find.text('Itinéraire'));
    await tester.tap(find.text('Itinéraire'));
    await tester.pump();
    await tester.pump();
    routing.requests.single.completeError(
      const RoutingFailure('Service indisponible'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Service indisponible'), findsOneWidget);
    expect(find.byType(PolylineLayer), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
