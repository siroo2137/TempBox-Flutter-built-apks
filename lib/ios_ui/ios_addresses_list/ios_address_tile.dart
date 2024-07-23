import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/ios_address_info/ios_address_info.dart';
import 'package:tempbox/ios_ui/ios_messages_list/ios_messages_list.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';

class IosAddressTile extends StatelessWidget {
  final int index;
  const IosAddressTile({super.key, required this.index});

  _openAddressInfoSheet(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    showCupertinoModalSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: IosAddressInfo(addressData: addressData),
      ),
    );
  }

  _navigateToMessagesList(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    BlocProvider.of<DataBloc>(dataBlocContext).add(SelectAddressEvent(addressData));
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: const IosMessagesList(),
      ),
    ));
  }

  _deleteAddress(BuildContext context, BuildContext dataBlocContext, AddressData addressData) async {
    bool? choice = await AlertService.getConformation(
      context: context,
      title: 'Alert',
      content: 'Are you sure you want to delete this address?',
    );
    if (choice == true && dataBlocContext.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteAddressEvent(addressData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (dataBlocContext, dataState) {
      AddressData addressData = dataState.addressList[index];
      return Slidable(
        groupTag: 'AddressItem',
        key: ValueKey(addressData.authenticatedUser.account.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _openAddressInfoSheet(context, dataBlocContext, addressData),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.info_circle_fill,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _deleteAddress(context, dataBlocContext, addressData),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: CupertinoIcons.trash_fill,
            ),
          ],
        ),
        child: CupertinoListTile.notched(
          title: Text(UiService.getAccountName(addressData)),
          leading: const Icon(CupertinoIcons.tray),
          trailing: const CupertinoListTileChevron(),
          additionalInfo: Text((dataState.accountIdToAddressesMap[addressData.authenticatedUser.account.id]?.length ?? '').toString()),
          onTap: () => _navigateToMessagesList(context, dataBlocContext, addressData),
        ),
      );
    });
  }
}
