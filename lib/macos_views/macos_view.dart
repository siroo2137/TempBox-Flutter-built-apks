import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/macos_views/platform_menus.dart';
import 'package:tempbox/macos_views/views/add_address/macui_add_address.dart';
import 'package:tempbox/macos_views/views/mac_app_info/mac_app_info.dart';
import 'package:tempbox/macos_views/views/macui_export_import/macui_export.dart';
import 'package:tempbox/macos_views/views/macui_export_import/macui_import.dart';
import 'package:tempbox/macos_views/views/macui_removed_addresses/macui_removed_addresses.dart';
import 'package:tempbox/macos_views/views/selected_address_view/selected_address_view.dart';
import 'package:tempbox/macos_views/views/sidebar_view/sidebar_view.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/export_import_address.dart';
import 'package:tempbox/shared/components/custom_cupertino_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class MacOSView extends StatelessWidget {
  const MacOSView({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'TempBox',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DataBloc>(create: (BuildContext context) => DataBloc()),
        ],
        child: const MacosStarter(),
      ),
    );
  }
}

class MacosStarter extends StatelessWidget {
  const MacosStarter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        BlocProvider.of<DataBloc>(dataBlocContext).add(const LoginToAccountsEvent());
        return const MacOsHome();
      },
    );
  }
}

class MacOsHome extends StatelessWidget {
  const MacOsHome({super.key});

  _importAddresses(BuildContext context, BuildContext dataBlocContext) async {
    List<AddressData>? addresses = await ExportImportAddress.importAddreses();
    if (context.mounted && addresses != null) {
      showMacosSheet(
        context: context,
        builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: MacuiImport(addresses: addresses)),
      );
    }
  }

  _exportAddresses(BuildContext context, BuildContext dataBlocContext) async {
    showMacosSheet(
      context: context,
      builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const MacuiExport()),
    );
  }

  _removedAddresses(BuildContext context, BuildContext dataBlocContext) async {
    showMacosSheet(
      context: context,
      builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const MacUiRemovedAddresses()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return PlatformMenuBar(
        menus: menuBarItems(),
        child: MacosWindow(
          sidebar: Sidebar(
            top: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
              child: CupertinoListTile(
                title: Text('New Address', style: typography.body),
                trailing: MacosIcon(
                  CupertinoIcons.add_circled_solid,
                  size: 18,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
                backgroundColor: CupertinoColors.systemGrey2.resolveFrom(context).withAlpha(44),
                backgroundColorActivated: CupertinoColors.systemGrey4.resolveFrom(context),
                onTap: () {
                  showMacosSheet(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<DataBloc>(dataBlocContext),
                      child: const MacUIAddAddress(),
                    ),
                  );
                },
              ),
            ),
            minWidth: 270,
            maxWidth: 300,
            builder: (context, scrollController) => SidebarView(scrollController: scrollController),
            bottom: Column(
              children: [
                CustomSidebarItem(
                  title: 'Import Addresses',
                  trailingIcon: FluentIcons.import,
                  onTap: () => _importAddresses(context, dataBlocContext),
                ),
                CustomSidebarItem(
                  title: 'Export Addresses',
                  trailingIcon: FluentIcons.export,
                  onTap: () => _exportAddresses(context, dataBlocContext),
                ),
                const MacosPulldownMenuDivider(),
                CustomSidebarItem(
                  title: 'Removed Addresses',
                  trailingIcon: CupertinoIcons.clear_circled,
                  onTap: () => _removedAddresses(context, dataBlocContext),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Powered by ",
                        style: MacosTheme.of(context).typography.body,
                        children: <TextSpan>[
                          TextSpan(
                            text: 'mail.tm',
                            style: TextStyle(color: MacosTheme.of(context).primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                bool? choice = await AlertService.getConformation(
                                  context: context,
                                  title: 'Do you want to continue?',
                                  content: 'This will open mail.tm website.',
                                );
                                if (choice == true) {
                                  await launchUrl(Uri.parse('https://mail.tm'));
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                    MacosIconButton(
                      icon: const MacosIcon(CupertinoIcons.info_circle),
                      onPressed: () {
                        showMacosSheet(
                          context: context,
                          builder: (_) => BlocProvider.value(value: BlocProvider.of<DataBloc>(dataBlocContext), child: const MacAppInfo()),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          child: const SelectedAddressView(),
        ),
      );
    });
  }
}

class CustomSidebarItem extends StatelessWidget {
  const CustomSidebarItem({
    super.key,
    required this.title,
    required this.trailingIcon,
    this.leadingIcon,
    required this.onTap,
  });

  final String title;
  final IconData trailingIcon;
  final IconData? leadingIcon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2.5),
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
        child: CustomCupertinoListTile(
          leading: leadingIcon == null ? null : MacosIcon(leadingIcon, size: 18, color: CupertinoColors.systemGrey.resolveFrom(context)),
          title: Text(title, style: typography.callout),
          trailing: MacosIcon(trailingIcon, size: 18, color: CupertinoColors.systemGrey.resolveFrom(context)),
          backgroundColor: CupertinoColors.systemGrey2.resolveFrom(context).withAlpha(44),
          backgroundColorActivated: CupertinoColors.systemGrey4.resolveFrom(context),
          onTap: onTap,
        ),
      );
    });
  }
}
