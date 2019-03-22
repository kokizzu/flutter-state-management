import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_state_management/_bloc_lib/_bloc.dart';
import 'package:flutter_state_management/_bloc/_events.dart';
import 'package:flutter_state_management/item.model.dart';

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ItemsBloc _itemsBloc = ItemsBloc();
  final CheckedItemsBloc _checkedItemsBloc = CheckedItemsBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
        blocProviders: [
          BlocProvider<ItemsBloc>(bloc: _itemsBloc),
          BlocProvider<CheckedItemsBloc>(bloc: _checkedItemsBloc)
        ],
        child: MaterialApp(
          title: 'BLoC Lib Sample',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Page(title: 'BLoC Lib Sample'),
        ));
  }

  @override
  void dispose() {
    _itemsBloc.dispose();
    _checkedItemsBloc.dispose();
    super.dispose();
  }
}

class Page extends StatelessWidget {
  Page({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final ItemsBloc _itemsBloc = BlocProvider.of<ItemsBloc>(context);
    final CheckedItemsBloc _checkedItemsBloc =
        BlocProvider.of<CheckedItemsBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            BlocBuilder(
                bloc: _checkedItemsBloc,
                builder: (BuildContext context, Set<String> checkedItemIds) {
                  return Visibility(
                      visible: checkedItemIds.isNotEmpty,
                      child: IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: 'Delete selected items',
                          onPressed: () {
                            _itemsBloc
                                .dispatch(RemoveItemsEvent(checkedItemIds));
                            _checkedItemsBloc
                                .dispatch(ClearCheckedItemsEvent());
                          }));
                })
          ],
        ),
        body: ListViewWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _itemsBloc
                .dispatch(AddItemEvent(Item(title: DateTime.now().toString())));
          },
          tooltip: 'Add',
          child: Icon(Icons.add),
        ));
  }
}

class ListViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ItemsBloc _itemsBloc = BlocProvider.of<ItemsBloc>(context);

    return BlocBuilder<ItemEvent, List<Item>>(
        bloc: _itemsBloc,
        builder: (BuildContext context, List<Item> items) {
          return ListView.builder(
              padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final CheckedItemsBloc _checkedItemsBloc =
                    BlocProvider.of<CheckedItemsBloc>(context);

                return BlocBuilder(
                    bloc: _checkedItemsBloc,
                    builder:
                        (BuildContext context, Set<String> checkedItemIds) {
                      final item = items[index];

                      return CheckboxListTile(
                          title: Text(item.title),
                          value: checkedItemIds.contains(item.id),
                          onChanged: (bool value) {
                            final event = value
                                ? CheckItemEvent(item.id)
                                : UncheckItemEvent(item.id);
                            _checkedItemsBloc.dispatch(event);
                          });
                    });
              });
        });
  }
}
