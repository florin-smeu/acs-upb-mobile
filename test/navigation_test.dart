import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/main.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/filter/view/filter_page.dart';
import 'package:acs_upb_mobile/pages/home/home_page.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/pages/portal/service/website_provider.dart';
import 'package:acs_upb_mobile/pages/portal/view/portal_page.dart';
import 'package:acs_upb_mobile/pages/settings/settings_page.dart';
import 'package:acs_upb_mobile/resources/custom_icons.dart';
import 'package:acs_upb_mobile/resources/storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class MockStorageProvider extends Mock implements StorageProvider {}

class MockWebsiteProvider extends Mock implements WebsiteProvider {}

class MockFilterProvider extends Mock implements FilterProvider {}

void main() {
  AuthProvider mockAuthProvider;
  StorageProvider mockStorageProvider;
  WebsiteProvider mockWebsiteProvider;
  FilterProvider mockFilterProvider;

  const double PORTRAIT_WIDTH = 400.0;
  const double PORTRAIT_HEIGHT = 800.0;
  const double LANDSCAPE_WIDTH = PORTRAIT_HEIGHT;
  const double LANDSCAPE_HEIGHT = PORTRAIT_WIDTH;

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    PrefService.enableCaching();
    PrefService.cache = {};
    PrefService.setString('language', 'en');

    // Pretend an anonymous user is already logged in
    mockAuthProvider = MockAuthProvider();
    when(mockAuthProvider.isAuthenticatedFromCache).thenReturn(true);
    // ignore: invalid_use_of_protected_member
    when(mockAuthProvider.hasListeners).thenReturn(false);
    when(mockAuthProvider.isAnonymous).thenReturn(true);
    when(mockAuthProvider.isAuthenticatedFromService)
        .thenAnswer((_) => Future.value(true));

    mockStorageProvider = MockStorageProvider();
    // ignore: invalid_use_of_protected_member
    when(mockStorageProvider.hasListeners).thenReturn(false);

    mockWebsiteProvider = MockWebsiteProvider();
    // ignore: invalid_use_of_protected_member
    when(mockWebsiteProvider.hasListeners).thenReturn(false);
    when(mockWebsiteProvider.getWebsites(any)).thenAnswer((_) => Future.value([
          Website(
            category: WebsiteCategory.learning,
            iconPath: 'icons/websites/moodle.png',
            infoByLocale: {'en': 'info-en', 'ro': 'info-ro'},
            label: 'Moodle',
            link: 'http://acs.curs.pub.ro/',
          ),
          Website(
            category: WebsiteCategory.learning,
            iconPath: 'icons/websites/ocw.png',
            infoByLocale: {},
            label: 'OCW',
            link: 'https://ocw.cs.pub.ro/',
          ),
          Website(
            category: WebsiteCategory.learning,
            iconPath: 'icons/websites/moodle.png',
            infoByLocale: {'en': 'info-en', 'ro': 'info-ro'},
            label: 'Moodle',
            link: 'http://acs.curs.pub.ro/',
          ),
          Website(
            category: WebsiteCategory.learning,
            iconPath: 'icons/websites/ocw.png',
            infoByLocale: {},
            label: 'OCW',
            link: 'https://ocw.cs.pub.ro/',
          ),
          Website(
            category: WebsiteCategory.association,
            iconPath: 'icons/websites/lsac.png',
            infoByLocale: {},
            label: 'LSAC',
            link: 'https://lsacbucuresti.ro/',
          ),
          Website(
            category: WebsiteCategory.administrative,
            iconPath: 'icons/websites/lsac.png',
            infoByLocale: {},
            label: 'LSAC',
            link: 'https://lsacbucuresti.ro/',
          ),
          Website(
            category: WebsiteCategory.resource,
            iconPath: 'icons/websites/lsac.png',
            infoByLocale: {},
            label: 'LSAC',
            link: 'https://lsacbucuresti.ro/',
          ),
          Website(
            category: WebsiteCategory.other,
            iconPath: 'icons/websites/lsac.png',
            infoByLocale: {},
            label: 'LSAC',
            link: 'https://lsacbucuresti.ro/',
          ),
        ]));

    mockFilterProvider = MockFilterProvider();
    // ignore: invalid_use_of_protected_member
    when(mockFilterProvider.hasListeners).thenReturn(false);
    when(mockFilterProvider.filterEnabled).thenReturn(true);
    when(mockFilterProvider.getRelevanceFilter(any))
        .thenAnswer((_) => Future.value(Filter(
                localizedLevelNames: [
                  {'en': 'Degree', 'ro': 'Nivel de studiu'},
                  {'en': 'Major', 'ro': 'Specializare'},
                  {'en': 'Year', 'ro': 'An'},
                  {'en': 'Series', 'ro': 'Serie'},
                  {'en': 'Group', 'ro': 'Group'}
                ],
                root: FilterNode(name: 'All', value: true, children: [
                  FilterNode(name: 'BSc', value: true, children: [
                    FilterNode(name: 'CTI', value: true, children: [
                      FilterNode(name: 'CTI-1', value: true, children: [
                        FilterNode(name: '1-CA'),
                        FilterNode(
                          name: '1-CB',
                          value: true,
                          children: [
                            FilterNode(name: '311CB'),
                            FilterNode(name: '312CB'),
                            FilterNode(name: '313CB'),
                            FilterNode(
                              name: '314CB',
                              value: true,
                            ),
                          ],
                        ),
                        FilterNode(name: '1-CC'),
                        FilterNode(
                          name: '1-CD',
                          children: [
                            FilterNode(name: '311CD'),
                            FilterNode(name: '312CD'),
                            FilterNode(name: '313CD'),
                            FilterNode(name: '314CD'),
                          ],
                        ),
                      ]),
                      FilterNode(
                        name: 'CTI-2',
                      ),
                      FilterNode(
                        name: 'CTI-3',
                      ),
                      FilterNode(
                        name: 'CTI-4',
                      ),
                    ]),
                    FilterNode(name: 'IS')
                  ]),
                  FilterNode(name: 'MSc', children: [
                    FilterNode(
                      name: 'IA',
                    ),
                    FilterNode(name: 'SPRC'),
                  ])
                ]))));
  });

  group('Home', () {
    testWidgets('Portrait', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Landscape', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('Timetable', () {
    testWidgets('Portrait', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open timetable
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // TODO: Replace with page when implemented
      expect(find.text('Timetable'), findsNWidgets(2));
    });

    testWidgets('Landscape', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open timetable
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // TODO: Replace with page when implemented
      expect(find.text('Timetable'), findsNWidgets(2));
    });
  });

  group('Map', () {
    testWidgets('Portrait', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open map
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();

      // TODO: Replace with page when implemented
      expect(find.text('Map'), findsNWidgets(2));
    });

    testWidgets('Landscape', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open timetable
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();

      // TODO: Replace with page when implemented
      expect(find.text('Map'), findsNWidgets(2));
    });
  });

  group('Portal', () {
    testWidgets('Portrait', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<StorageProvider>(
              create: (_) => mockStorageProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<FilterProvider>(
              create: (_) => mockFilterProvider),
        ],
        child: MyApp(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open portal
      await tester.tap(find.byIcon(Icons.public));
      await tester.pumpAndSettle();

      expect(find.byType(PortalPage), findsOneWidget);
    });

    testWidgets('Landscape', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<StorageProvider>(
              create: (_) => mockStorageProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<FilterProvider>(
              create: (_) => mockFilterProvider),
        ],
        child: MyApp(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open portal
      await tester.tap(find.byIcon(Icons.public));
      await tester.pumpAndSettle();

      expect(find.byType(PortalPage), findsOneWidget);
    });
  });

  group('Profile', () {
    testWidgets('Portrait', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // TODO: Replace with page when implemented
      expect(find.text('Profile'), findsNWidgets(2));
    });

    testWidgets('Landscape', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      // Open profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // TODO: Replace with page when implemented
      expect(find.text('Profile'), findsNWidgets(2));
    });
  });

  group('Settings', () {
    testWidgets('Portrait', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('Landscape', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));

      await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
          create: (_) => mockAuthProvider, child: MyApp()));
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });

  group('Filter', () {
    testWidgets('Portrait', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(PORTRAIT_WIDTH, PORTRAIT_HEIGHT));

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<StorageProvider>(
              create: (_) => mockStorageProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<FilterProvider>(
              create: (_) => mockFilterProvider),
        ],
        child: MyApp(),
      ));
      await tester.pumpAndSettle();

      // Open filter popup menu
      await tester.tap(find.byIcon(Icons.public));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CustomIcons.filter));
      await tester.pumpAndSettle();

      // Open filter on portal page
      await tester.tap(find.text('Filter by relevance'));
      await tester.pumpAndSettle();

      expect(find.byType(FilterPage), findsOneWidget);
    });

    testWidgets('Landscape', (WidgetTester tester) async {
      await binding.setSurfaceSize(Size(LANDSCAPE_WIDTH, LANDSCAPE_HEIGHT));

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<StorageProvider>(
              create: (_) => mockStorageProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<FilterProvider>(
              create: (_) => mockFilterProvider),
        ],
        child: MyApp(),
      ));
      await tester.pumpAndSettle();

      // Open filter popup menu
      await tester.tap(find.byIcon(Icons.public));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CustomIcons.filter));
      await tester.pumpAndSettle();

      // Open filter on portal page
      await tester.tap(find.text('Filter by relevance'));
      await tester.pumpAndSettle();

      expect(find.byType(FilterPage), findsOneWidget);
    });
  });
}
