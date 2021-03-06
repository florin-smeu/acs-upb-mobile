import 'dart:core';
import 'dart:math';

import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/pages/portal/service/website_provider.dart';
import 'package:acs_upb_mobile/pages/portal/view/website_view.dart';
import 'package:acs_upb_mobile/resources/custom_icons.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/storage_provider.dart';
import 'package:acs_upb_mobile/widgets/circle_image.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:url_launcher/url_launcher.dart';

class PortalPage extends StatefulWidget {
  @override
  _PortalPageState createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage>
    with AutomaticKeepAliveClientMixin {
  Future<Filter> filterFuture;
  List<Website> websites = [];

  // Only show user-added websites
  bool userOnly = false;

  bool editingEnabled = false;

  User user;

  _fetchUser() async {
    AuthProvider authProvider = Provider.of(context, listen: false);
    user = await authProvider.currentUser;
    if (mounted) {
      setState(() {});
    }
  }

  initState() {
    super.initState();
    _fetchUser();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      AppToast.show(S.of(context).errorCouldNotLaunchURL(url));
    }
  }

  Widget spoiler({String title, Widget content, bool initialExpanded = true}) =>
      ExpandableNotifier(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ExpandableTheme(
              data: ExpandableThemeData(
                  useInkWell: false,
                  crossFadePoint: 0.5,
                  hasIcon: true,
                  iconPlacement: ExpandablePanelIconPlacement.left,
                  iconColor: Theme.of(context).textTheme.headline6.color,
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  iconPadding: EdgeInsets.only()),
              child: ExpandablePanel(
                controller:
                    ExpandableController(initialExpanded: initialExpanded),
                header:
                    Text(title, style: Theme.of(context).textTheme.headline6),
                collapsed: SizedBox(height: 12.0),
                expanded: content,
              ),
            ),
          ],
        ),
      );

  Widget websiteCircle(Website website, double size) {
    StorageProvider storageProvider = Provider.of<StorageProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<ImageProvider<dynamic>>(
        future: storageProvider.imageFromPath(website.iconPath),
        builder: (context, snapshot) {
          var image;
          if (snapshot.hasData) {
            image = snapshot.data;
          } else {
            image = AssetImage('assets/' + website.iconPath) ??
                AssetImage('assets/images/white.png');
          }

          bool canEdit = editingEnabled &&
              (website.isPrivate || (user.canEditPublicWebsite ?? false));
          return CircleImage(
            label: website.label,
            tooltip: website.infoByLocale[LocaleProvider.localeString],
            image: image,
            enableOverlay: canEdit,
            circleSize: size,
            onTap: () => canEdit
                ? Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider<FilterProvider>(
                      create: (_) => FilterProvider(
                          defaultDegree: website.degree,
                          defaultRelevance: website.relevance),
                      child: WebsiteView(
                        website: website,
                        updateExisting: true,
                      ),
                    ),
                  ))
                : _launchURL(website.link),
          );
        },
      ),
    );
  }

  Widget listCategory(WebsiteCategory category, List<Website> websites) {
    bool hasContent = websites != null && websites.isNotEmpty;

    // The width available for displaying the circles (screen width minus a left
    // right padding of 8)
    double availableWidth = MediaQuery.of(context).size.width - 16;
    // The maximum size of a circle, regardless of screen size
    double maxCircleSize = 80;
    // The amount of circles that can fit on one row (given the screen size,
    // maximum circle size and the fact that there need to be at least 4 circles
    // on a row), including the padding.
    int circlesPerRow = max(4, (availableWidth / (maxCircleSize + 16)).floor());
    // The exact size of a circle (without the padding), so that they fit
    // perfectly in a row
    double circleSize = availableWidth / circlesPerRow - 16;

    Widget content;
    if (!hasContent) {
      // Display just the plus button (but set the height to mimic the rows with
      // content)
      content = Container(
        width: circleSize + 16.0,
        height: circleSize +
            16.0 + // padding
            40.0, // text
        child: Center(
          child: _AddWebsiteButton(
              key: ValueKey('add_website_' +
                  ReCase(category.toLocalizedString(context)).snakeCase),
              category: category),
        ),
      );
    } else {
      List<Row> rows = [];

      for (var i = 0; i < websites.length;) {
        List<Widget> children = [];
        for (var j = 0; j < circlesPerRow && i < websites.length; j++, i++) {
          children.add(websiteCircle(websites[i], circleSize));
        }

        // Add trailing "plus" button
        if (i == websites.length - 1 || i == websites.length) {
          if (children.length == circlesPerRow) {
            rows.add(Row(children: children));
            children = [];
          }
          children.add(Container(
            width: circleSize + 16,
            child: _AddWebsiteButton(
              key: ValueKey('add_website_' +
                  ReCase(category.toLocalizedString(context)).snakeCase),
              category: category,
              size: circleSize * 0.6,
            ),
          ));
        }

        rows.add(Row(children: children));
      }

      content = Column(children: rows);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: spoiler(
        title: category.toLocalizedString(context),
        initialExpanded: hasContent,
        content: content,
      ),
    );
  }

  List<Widget> listWebsitesByCategory(List<Website> websites) {
    assert(websites != null);

    Map<WebsiteCategory, List<Website>> map = Map();
    websites.forEach((website) {
      var category = website.category;
      map.putIfAbsent(category, () => List<Website>());
      map[category].add(website);
    });

    return [
      WebsiteCategory.learning,
      WebsiteCategory.administrative,
      WebsiteCategory.association,
      WebsiteCategory.resource,
      WebsiteCategory.other
    ].map((category) => listCategory(category, map[category])).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    WebsiteProvider websiteProvider = Provider.of<WebsiteProvider>(context);
    FilterProvider filterProvider = Provider.of<FilterProvider>(context);
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    if (filterFuture == null) {
      filterFuture = filterProvider.fetchFilter(context);
    }

    CircularProgressIndicator progressIndicator = CircularProgressIndicator();

    return AppScaffold(
      title: S.of(context).navigationPortal,
      actions: [
        AppScaffoldAction(
          icon: editingEnabled ? CustomIcons.edit_slash : Icons.edit,
          tooltip: editingEnabled
              ? S.of(context).actionDisableEditing
              : S.of(context).actionEnableEditing,
          onPressed: () {
            AuthProvider authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.isAuthenticatedFromCache &&
                !authProvider.isAnonymous) {
              // Show message if there is nothing the user can edit
              if (!editingEnabled) {
                user.hasEditableWebsites.then((canEdit) {
                  if (!canEdit)
                    AppToast.show(S.of(context).warningNothingToEdit +
                        ' ' +
                        S.of(context).messageAddCustomWebsite);
                });
              }

              setState(() => editingEnabled = !editingEnabled);
            } else {
              AppToast.show(S.of(context).warningAuthenticationNeeded);
            }
          },
        ),
        AppScaffoldAction(
          icon: CustomIcons.filter,
          tooltip: S.of(context).navigationFilter,
          items: {
            S.of(context).filterMenuRelevance: () {
              filterFuture = null; // reset filter cache
              userOnly = false;
              Navigator.pushNamed(context, Routes.filter);
            },
            S.of(context).filterMenuShowMine: () {
              if (authProvider.isAuthenticatedFromCache &&
                  !authProvider.isAnonymous) {
                // Show message if user has no private websites
                if (!userOnly) {
                  user.hasPrivateWebsites.then((hasPrivate) {
                    if (!hasPrivate)
                      AppToast.show(S.of(context).warningNoPrivateWebsite);
                  });

                  filterFuture = null; // reset filter cache
                  setState(() => userOnly = true);
                  filterProvider.enableFilter();
                } else {
                  AppToast.show(S.of(context).warningFilterAlreadyShowingYours);
                }
              } else {
                AppToast.show(S.of(context).warningAuthenticationNeeded);
              }
            },
            S.of(context).filterMenuShowAll: () {
              if (!filterProvider.filterEnabled) {
                AppToast.show(S.of(context).warningFilterAlreadyDisabled);
              } else {
                filterFuture = null; // reset filter cache
                userOnly = false;
                filterProvider.disableFilter();
              }
            },
          },
        ),
      ],
      body: FutureBuilder(
        future: filterFuture,
        builder: (BuildContext context, AsyncSnapshot<Filter> filterSnap) {
          if (filterSnap.hasData) {
            return FutureBuilder<List<Website>>(
                future: websiteProvider.fetchWebsites(
                  filterProvider.filterEnabled ? filterSnap.data : null,
                  userOnly: userOnly,
                  uid: authProvider.uid,
                ),
                builder: (context, AsyncSnapshot<List<Website>> websiteSnap) {
                  if (websiteSnap.hasData) {
                    websites = websiteSnap.data;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Column(
                          children: listWebsitesByCategory(websites),
                        ),
                      ),
                    );
                  } else if (websiteSnap.hasError) {
                    print(filterSnap.error);
                    // TODO: Show error toast
                    return Container();
                  } else {
                    return Center(child: progressIndicator);
                  }
                });
          } else if (filterSnap.hasError) {
            print(filterSnap.error);
            // TODO: Show error toast
            return Container();
          } else {
            return Center(child: progressIndicator);
          }
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _AddWebsiteButton extends StatelessWidget {
  final WebsiteCategory category;
  final double size;

  const _AddWebsiteButton(
      {Key key, this.category = WebsiteCategory.learning, this.size = 50})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Tooltip(
        message: S.of(context).actionAddWebsite,
        child: GestureDetector(
          onTap: () {
            AuthProvider authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.isAuthenticatedFromCache &&
                !authProvider.isAnonymous) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider<FilterProvider>(
                    create: (_) => FilterProvider(),
                    child: WebsiteView(
                      website: Website(
                          id: null,
                          isPrivate: true,
                          link: "",
                          category: category),
                    )),
              ));
            } else {
              AppToast.show(S.of(context).warningAuthenticationNeeded);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: CircleImage(
              icon: Icon(
                Icons.add,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              label: "",
              circleSize: size,
            ),
          ),
        ),
      );
}
