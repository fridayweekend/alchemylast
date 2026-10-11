import 'package:flutter/material.dart';

import 'commerce/commerce_prototype_store.dart';
import 'shared/auth_prototype_store.dart';
import 'theme.dart';

const navItems = <String, String>{
  'Home': '/',
  'About': '/about',
  'Services': '/services',
  'Upskilling': '/upskilling',
  'Store': '/store',
  'Insights': '/insights',
  'Contact': '/contact',
  'Login': '/login',
  'Register': '/register',
  'Cart': '/cart',
  'Sitemap': '/sitemap',
};

const corporateNavItems = <String, String>{
  'Individual Coaching': '/coaching',
  'Organizations': '/organizations',
  'Corporate Programmes': '/programmes',
  'Impact Stories': '/impact',
};

void go(BuildContext context, String route, {Object? arguments}) {
  if (ModalRoute.of(context)?.settings.name != route) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }
}

class SiteShell extends StatelessWidget {
  const SiteShell({super.key, required this.route, required this.child});
  final String route;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1500;
    final compactHeader = MediaQuery.sizeOf(context).width < 440;
    final signedIn = AuthPrototypeStore.instance.isSignedIn;
    final role = AuthPrototypeStore.instance.role;
    final canViewCorporateWebsite =
        signedIn && const {'Employer', 'Admin'}.contains(role);
    final visibleCorporateNavItems = canViewCorporateWebsite
        ? corporateNavItems
        : <String, String>{
            'Individual Coaching': '/coaching',
            'Organizations': '/organizations',
            'Public Programmes': '/programmes',
            'Impact Stories': '/impact',
          };
    final workspaceRoute = switch (role) {
      'Admin' => '/admin',
      'Employer' => '/employer',
      'Learner' => '/dashboard',
      'Trainer' => '/trainer-dashboard',
      _ => null,
    };
    final workspaceLabel = switch (role) {
      'Admin' => 'Admin portal',
      'Employer' => 'Employer portal',
      'Learner' => 'Learner dashboard',
      'Trainer' => 'Trainer dashboard',
      _ => null,
    };
    void signOut() {
      AuthPrototypeStore.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }

    void goBackOrWorkspace() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else if (workspaceRoute != null) {
        Navigator.pushReplacementNamed(context, workspaceRoute);
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: desktop
            ? null
            : Builder(
                builder: (context) => Row(
                  children: [
                    if (Navigator.canPop(context))
                      IconButton(
                        tooltip: 'Go back',
                        icon: const Icon(Icons.arrow_back),
                        onPressed: goBackOrWorkspace,
                      ),
                    IconButton(
                      tooltip: 'Open navigation',
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ],
                ),
              ),
        leadingWidth: desktop ? null : (Navigator.canPop(context) ? 104 : 56),
        toolbarHeight: 84,
        titleSpacing: desktop ? 36 : 16,
        title: InkWell(
          onTap: () => go(context, '/'),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo_mt_alchemy.jpeg',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MT ALCHEMY',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (!compactHeader)
                    const Text(
                      'People grow. Organizations thrive.',
                      style: TextStyle(fontSize: 10, color: purple),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: desktop
            ? [
                if (Navigator.canPop(context))
                  IconButton(
                    tooltip: 'Go back',
                    onPressed: goBackOrWorkspace,
                    icon: const Icon(Icons.arrow_back),
                  ),
                for (final item in navItems.entries.take(3))
                  TextButton(
                    onPressed: () => go(context, item.value),
                    child: Text(
                      item.key,
                      style: TextStyle(
                        fontWeight: route == item.value
                            ? FontWeight.w900
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                if (visibleCorporateNavItems.isNotEmpty)
                  PopupMenuButton<String>(
                    tooltip: 'Corporate pages',
                    onSelected: (value) => go(context, value),
                    itemBuilder: (_) => [
                      for (final item in visibleCorporateNavItems.entries)
                        PopupMenuItem(value: item.value, child: Text(item.key)),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            'Corporate',
                            style: TextStyle(
                              fontWeight: corporateNavItems.containsValue(route)
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 19),
                        ],
                      ),
                    ),
                  ),
                for (final item
                    in navItems.entries
                        .skip(3)
                        .where(
                          (item) =>
                              !signedIn ||
                              !const {'Login', 'Register'}.contains(item.key),
                        ))
                  TextButton(
                    onPressed: () => go(context, item.value),
                    child: item.key == 'Cart'
                        ? AnimatedBuilder(
                            animation: CommercePrototypeStore.instance,
                            builder: (context, _) => Badge(
                              isLabelVisible:
                                  CommercePrototypeStore.instance.cartCount > 0,
                              label: Text(
                                '${CommercePrototypeStore.instance.cartCount}',
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 20,
                              ),
                            ),
                          )
                        : Text(
                            item.key,
                            style: TextStyle(
                              fontWeight: route == item.value
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                            ),
                          ),
                  ),
                if (workspaceRoute != null && workspaceLabel != null)
                  TextButton.icon(
                    onPressed: () => go(context, workspaceRoute),
                    icon: Icon(
                      role == 'Admin'
                          ? Icons.admin_panel_settings_outlined
                          : Icons.business_outlined,
                      size: 18,
                    ),
                    label: Text(
                      workspaceLabel,
                      style: TextStyle(
                        fontWeight: route == workspaceRoute
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                if (signedIn)
                  TextButton.icon(
                    onPressed: signOut,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign out'),
                  ),
                const SizedBox(width: 24),
              ]
            : null,
      ),
      drawer: desktop
          ? null
          : Drawer(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'MT ALCHEMY',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: deepBlue,
                        ),
                      ),
                    ),
                    for (final item in navItems.entries.where(
                      (item) =>
                          !signedIn ||
                          !const {'Login', 'Register'}.contains(item.key),
                    ))
                      Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          title: Text(item.key),
                          selected: route == item.value,
                          selectedColor: deepBlue,
                          selectedTileColor: softYellow.withValues(alpha: .28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            go(context, item.value);
                          },
                        ),
                      ),
                    if (workspaceRoute != null && workspaceLabel != null)
                      Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          leading: Icon(
                            role == 'Admin'
                                ? Icons.admin_panel_settings_outlined
                                : Icons.business_outlined,
                          ),
                          title: Text(workspaceLabel),
                          selected: route == workspaceRoute,
                          selectedColor: deepBlue,
                          selectedTileColor: softYellow.withValues(alpha: .28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            go(context, workspaceRoute);
                          },
                        ),
                      ),
                    if (signedIn)
                      Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Sign out'),
                          onTap: () {
                            Navigator.pop(context);
                            signOut();
                          },
                        ),
                      ),
                    if (visibleCorporateNavItems.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'CORPORATE WEBSITE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: purple,
                          ),
                        ),
                      ),
                      for (final item in visibleCorporateNavItems.entries)
                        Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            title: Text(item.key),
                            selected: route == item.value,
                            selectedColor: deepBlue,
                            selectedTileColor: softYellow.withValues(alpha: .28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              go(context, item.value);
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListenableBuilder(
              listenable: CommercePrototypeStore.instance,
              builder: (context, _) {
                final error = CommercePrototypeStore.instance.storageError;
                return error == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
              },
            ),
            child,
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child, this.padding = true});
  final Widget child;
  final bool padding;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1240),
      child: Padding(
        padding: padding
            ? EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width < 600 ? 20 : 40,
              )
            : EdgeInsets.zero,
        child: child,
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.eyebrow,
    this.subtitle,
    this.center = false,
  });
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final bool center;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 72, bottom: 28),
    child: Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) Eyebrow(eyebrow!),
        if (eyebrow != null) const SizedBox(height: 12),
        Text(
          title,
          textAlign: center ? TextAlign.center : null,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              subtitle!,
              textAlign: center ? TextAlign.center : null,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ],
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.light = false});
  final String text;
  final bool light;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: light ? softYellow : purple,
      fontSize: 12,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
    ),
  );
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = 26,
  });
  final Widget child;
  final Color color;
  final double padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: deepBlue.withValues(alpha: .08)),
      boxShadow: [
        BoxShadow(
          color: deepBlue.withValues(alpha: .05),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minWidth = 280,
  });
  final List<Widget> children;
  final double minWidth;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final columns = box.maxWidth >= 1000
          ? 3
          : box.maxWidth >= 620
          ? 2
          : 1;
      final width = (box.maxWidth - (columns - 1) * 20) / columns;
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (final child in children)
            SizedBox(
              width: width < minWidth ? box.maxWidth : width,
              child: child,
            ),
        ],
      );
    },
  );
}

class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.path,
    required this.title,
    required this.subtitle,
    this.height = 260,
  });
  final String path;
  final String title;
  final String subtitle;
  final double height;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: Container(
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.bottomLeft,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xD900001F)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    ),
  );
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 80),
    color: deepBlue,
    padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 24),
    child: PageWidth(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 40,
        runSpacing: 32,
        children: [
          const SizedBox(
            width: 330,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MT ALCHEMY',
                  style: TextStyle(
                    color: softYellow,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Building emotionally intelligent leaders and resilient workplace cultures.',
                  style: TextStyle(color: Colors.white, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTACT',
                  style: TextStyle(
                    color: softYellow,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '+60 11-7239 9249\nmabeltan.alchemy@gmail.com',
                  style: TextStyle(color: Colors.white, height: 1.8),
                ),
              ],
            ),
          ),
          const Text(
            'NET4207 · Flutter UI prototype',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    ),
  );
}
