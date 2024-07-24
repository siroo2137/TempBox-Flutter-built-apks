import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/ios_ui/ios_message_detail/ios_message_detail.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/services/alert_service.dart';
import 'package:tempbox/services/ui_service.dart';
import 'package:tempbox/shared/components/blank_badge.dart';

class IosMessageTile extends StatelessWidget {
  const IosMessageTile({
    super.key,
    required this.message,
    required this.selectedAddress,
  });

  final Message message;
  final AddressData selectedAddress;

  _navigateToMessagesDetail(BuildContext context, BuildContext dataBlocContext, AddressData addressData) {
    BlocProvider.of<DataBloc>(dataBlocContext).add(SelectMessageEvent(message: message, addressData: addressData));
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<DataBloc>(dataBlocContext),
        child: IosMessageDetail(message: message),
      ),
    ));
  }

  _deleteMessage(BuildContext context, BuildContext dataBlocContext, AddressData address) async {
    bool? choice = await AlertService.getConformation(context: context, title: 'Alert', content: 'Are you sure you want to delete this message?');
    if (choice == true && dataBlocContext.mounted) {
      BlocProvider.of<DataBloc>(dataBlocContext).add(DeleteMessageEvent(message: message, addressData: address));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizedBox hGap(double size) => SizedBox(width: size);
    return BlocBuilder<DataBloc, DataState>(
      buildWhen: (previous, current) => false,
      builder: (dataBlocContext, dataState) {
        return Slidable(
          groupTag: 'MessageItem',
          key: ValueKey(message.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  BlocProvider.of<DataBloc>(dataBlocContext).add(ToggleMessageReadUnread(
                    addressData: dataState.selectedAddress!,
                    message: message,
                  ));
                },
                backgroundColor: const Color(0XFF0B84FF),
                foregroundColor: CupertinoColors.white,
                icon: message.seen ? CupertinoIcons.envelope_badge_fill : CupertinoIcons.envelope_open_fill,
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _deleteMessage(context, dataBlocContext, dataState.selectedAddress!),
                backgroundColor: CupertinoColors.systemRed,
                foregroundColor: CupertinoColors.white,
                icon: CupertinoIcons.trash_fill,
              ),
            ],
          ),
          child: CupertinoListTile.notched(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (!message.seen) const BlankBadge(),
                    if (!message.seen) hGap(10),
                    Text(
                      UiService.getMessageFromName(message),
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      UiService.formatTimeTo12Hour(message.createdAt),
                      style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(fontSize: 14),
                    ),
                    hGap(5),
                    const CupertinoListTileChevron(),
                  ],
                )
              ],
            ),
            subtitle: Text(message.subject),
            onTap: () => _navigateToMessagesDetail(context, dataBlocContext, dataState.selectedAddress!),
          ),
        );
      },
    );
  }
}
