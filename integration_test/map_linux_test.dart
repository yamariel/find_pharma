// Run on the native Linux engine, not flutter_tester:
// xvfb-run -a flutter test integration_test/map_linux_test.dart -d linux
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:find_pharma/main.dart' as app;
import 'package:find_pharma/map/demo/demo_pharmacies.dart';
import 'package:find_pharma/map/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:latlong2/latlong.dart';

// Only the route origin is simulated. Tiles and OSRM use actual HTTPS requests.
class TestOrigin implements LocationService {
  @override
  Future<LatLng> locate() async => const LatLng(-4.325, 15.322);
  @override
  Future<bool> openSettings({required bool locationSettings}) async => false;
}

class DeniedLocation extends TestOrigin {
  @override
  Future<LatLng> locate() async =>
      throw const LocationFailure(LocationProblem.denied);
}

class ObservedRouting implements RoutingService {
  ObservedRouting(String url) : delegate = OsrmRoutingService(baseUrl: url);
  final OsrmRoutingService delegate;
  RoadRoute? result;
  Object? failure;
  @override
  Future<RoadRoute> route(LatLng origin, LatLng destination) async {
    try {
      return result = await delegate.route(origin, destination);
    } catch (error) {
      failure = error;
      rethrow;
    }
  }

  @override
  void dispose() => delegate.dispose();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final captureKey = GlobalKey();
  final artifacts = Directory(
    const String.fromEnvironment(
      'MAP_TEST_ARTIFACT_DIR',
      defaultValue: '/tmp/find-pharma-linux-validation',
    ),
  );
  final report = <String, Object?>{};

  Future<void> saveReport() async {
    await artifacts.create(recursive: true);
    await File('${artifacts.path}/results.json')
        .writeAsString(const JsonEncoder.withIndent('  ').convert(report));
  }

  Future<void> show(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(RepaintBoundary(key: captureKey, child: child));
    await tester.pumpAndSettle();
  }

  Future<void> until(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 40),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition() && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(
      condition(),
      isTrue,
      reason: 'Condition non atteinte avant $timeout',
    );
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    final boundary =
        captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await artifacts.create(recursive: true);
    await File('${artifacts.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> scenario(WidgetTester tester, String label) async {
    await tap(tester, find.byType(DropdownButton<String>));
    await tap(tester, find.text(label).last);
  }

  tearDownAll(saveReport);

  testWidgets(
    'Linux: real tiles, selection, overlapping markers and demo scenarios',
    (tester) async {
      await show(tester, const app.MainApp());
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.textContaining('DÉMONSTRATION'), findsOneWidget);
      expect(find.textContaining('Kinshasa'), findsOneWidget);
      // At least one decoded raster tile, not just a map widget on a blank canvas.
      await until(
        tester,
        () => tester
            .widgetList<RawImage>(find.byType(RawImage))
            .any((image) => image.image != null),
      );
      report['real_osm_tiles_rendered'] = true;
      await capture(tester, '01-map');

      await tap(tester, find.byTooltip('Pharmacie Démo Gombe, Ouverte'));
      expect(find.text('Vendeurs présents : Vendeur Démo'), findsOneWidget);
      await tap(tester, find.text('Voir la pharmacie'));
      expect(find.textContaining('Callback reçu'), findsOneWidget);
      await capture(tester, '02-selection');
      await tap(tester, find.byTooltip('Fermer la fiche'));
      await tap(tester, find.byTooltip('2 pharmacies'));
      await tap(tester, find.text('Pharmacie Démo voisine'));
      expect(find.text('Ouverture inconnue'), findsOneWidget);
      await tap(tester, find.byTooltip('Fermer la fiche'));

      await scenario(tester, 'Démo : résultats médicament');
      await tap(tester, find.byTooltip('Pharmacie Démo Gombe, Ouverte'));
      expect(find.text('Disponible selon la recherche'), findsOneWidget);
      expect(find.textContaining('2 500 CDF'), findsOneWidget);
      await scenario(tester, 'Démo : aucun résultat');
      expect(find.text('Aucun résultat pour ce médicament.'), findsOneWidget);
      await capture(tester, '03-no-results');
      await scenario(tester, 'Démo : erreur de données');
      expect(
        find.textContaining('chargement des pharmacies impossible'),
        findsOneWidget,
      );
      await tap(tester, find.text('Réessayer'));
      expect(find.byTooltip('Pharmacie Démo Gombe, Ouverte'), findsOneWidget);
      report['selection_search_empty_error_retry'] = 'passed';
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Linux: actual OSRM driving route, viewport and clearing', (
    tester,
  ) async {
    final routing = ObservedRouting(const MapConfig().routingUrl);
    addTearDown(routing.dispose);
    await show(
      tester,
      MaterialApp(
        home: PharmacyMapScreen(
          pharmacies: demoPharmacies,
          isDemo: true,
          selectedPharmacyId: 'demo-1',
          locationService: TestOrigin(),
          routingService: routing,
        ),
      ),
    );
    await tap(tester, find.text('Itinéraire'));
    await until(
      tester,
      () => routing.result != null || routing.failure != null,
    );
    expect(routing.failure, isNull, reason: '${routing.failure}');
    final route = routing.result!;
    expect(route.points.length, greaterThan(2));
    expect(route.distanceMeters, greaterThan(0));
    expect(route.durationSeconds, greaterThan(0));
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.textContaining('Sans trafic en temps réel'), findsOneWidget);
    final camera = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .mapController!
        .camera;
    expect(route.points.every(camera.visibleBounds.contains), isTrue);
    report['real_osrm_route'] = {
      'origin': 'fixed synthetic test coordinate in Kinshasa',
      'geometry_points': route.points.length,
      'distance_m': route.distanceMeters,
      'duration_s': route.durationSeconds,
      'all_points_visible': true,
    };
    await capture(tester, '04-real-osrm-route');
    await tap(tester, find.text('Effacer le trajet'));
    expect(find.byType(PolylineLayer), findsNothing);
    report['clear_route'] = 'passed';
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Linux: simulated refusal and real unreachable routing server', (
    tester,
  ) async {
    await show(
      tester,
      MaterialApp(
        home: PharmacyMapScreen(
          pharmacies: demoPharmacies,
          isDemo: true,
          locationService: DeniedLocation(),
        ),
      ),
    );
    await tap(tester, find.byTooltip('Me localiser et recentrer'));
    expect(find.textContaining('Localisation refusée'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    await capture(tester, '05-location-denied');

    final routing = ObservedRouting('https://127.0.0.1:1');
    addTearDown(routing.dispose);
    await show(
      tester,
      MaterialApp(
        home: PharmacyMapScreen(
          pharmacies: demoPharmacies,
          isDemo: true,
          selectedPharmacyId: 'demo-1',
          locationService: TestOrigin(),
          routingService: routing,
        ),
      ),
    );
    await tap(tester, find.text('Itinéraire'));
    await until(tester, () => routing.failure != null);
    expect(find.byType(PolylineLayer), findsNothing);
    expect(
      find.textContaining('Connexion au routage impossible'),
      findsOneWidget,
    );
    await capture(tester, '06-routing-network-error');
    report['simulated_permission_refusal'] = 'passed';
    report['real_network_failure_without_fake_route'] = 'passed';
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Linux: actual system location probe (no coordinates persisted)',
    (tester) async {
      await show(tester, const app.MainApp());
      await tap(tester, find.byTooltip('Me localiser et recentrer'));
      await until(
        tester,
        () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
        timeout: const Duration(seconds: 30),
      );
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .toList();
      final errors = texts
          .where(
            (text) =>
                text.startsWith('Localisation ') ||
                text.startsWith('Le service de localisation ') ||
                text.startsWith('Position ') ||
                text.startsWith('La localisation '),
          )
          .toList();
      if (errors.isEmpty) {
        expect(find.byTooltip('Votre position relevée'), findsOneWidget);
        report['native_location'] =
            'position acquired; coordinates intentionally omitted';
      } else {
        report['native_location'] = {
          'available': false,
          'message': errors.join(' '),
        };
        expect(find.byType(FlutterMap), findsOneWidget);
      }
      // No screenshot here: a successful real location must not be persisted.
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
