import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tile_table/cell/tile_cell.dart';
import 'package:tile_table/cell/tile_cell_position.dart';

import '../table/table_clipboard.dart';
import 'tile_table_view.dart';
import 'list_model.dart';

typedef CellGroupCallback<T> = void Function(TileCell<T>);

class CellGroupContainer<T> extends StatefulWidget {
  const CellGroupContainer({
    Key? key,
    required this.cells,
    required this.commit,
    required this.cellHeight,
    this.selection,
    this.cellBuilder,

    this.onSelect,
    this.onAddToSelection,
    this.onRemove,
    this.onAdd,
  }) : super(key: key);

  final double cellHeight;
  final CellBuilder<T>? cellBuilder;
  final CommitCallback commit;
  final List<TileCell<T>> cells;
  final TableClipboard<T>? selection;

  // ---------------- TABLE CALL BACKS -------------- //
  final CellGroupCallback<T>? onSelect;
  final CellGroupCallback<T>? onAddToSelection;
  final CellGroupCallback<T>? onRemove;
  final CellGroupCallback<T>? onAdd;

  @override
  State<StatefulWidget> createState() {
    return CellGroupContainerState<T>();
  }
}

class CellGroupContainerState<T> extends State<CellGroupContainer<T>> {

  // ------------------- PROPS -----------------------
  TableClipboard? get _selection => widget.selection;
  CellBuilder<T>? get cellBuilder => widget.cellBuilder;
  CommitCallback get _commit => widget.commit;
  List<TileCell<T>> get _initialList => widget.cells;

  double get cellHeight => widget.cellHeight;

  // ------------------- INTERNAL STATE --------------
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel _groupList;

  // ------------------- EVENT HANDLERS ---------------
  CellGroupCallback<T>? get _onSelect => widget.onSelect;

  Widget _buildRemovedItem(TileCell<T> item, BuildContext context, Animation<double> animation) {
    return SizeTransition(
        key: UniqueKey(),
        sizeFactor: animation,
        child: Container(
          // color: Colors.red,
        )
    );
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    final TileCell<T> cell = _groupList[index];

    final bool isSelected = _selection != null && _selection!.isCellSelected(cell);
    final bool isCopied = _selection != null && _selection!.isCellInClipBoard(cell);
    final Color selectionColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);

    Widget cellChild = cellBuilder?.call(
        context,
        cell,
        _commit,
            () {
          _onSelect?.call(cell);
        }
    ) ?? Text("${cell.value}");

    Border? cellBorder;
    if (isSelected) {
      cellBorder = Border.all(color: Theme.of(context).colorScheme.primary, strokeAlign: BorderSide.strokeAlignInside);
    }

    Widget cellContainer = Container(
      height: cellHeight,
      decoration: BoxDecoration(
      // color: isSelected ? selectionColor : Colors.white,
      //   border: cellBorder
      ),
      child: cellChild
    );

    // if (isCopied) {
    //   cellContainer = DottedBorder(
    //     color: Theme.of(context).colorScheme.primary,
    //     dashPattern: const [3, 3],
    //     strokeWidth: 3,
    //     child: cellChild,
    //   );
    // }

    return SizeTransition(
        key: ValueKey(index),
        sizeFactor: animation,
        child: cellContainer
    );
  }

  @override
  void initState() {
    _groupList = ListModel<TileCell<T>>(
      listKey: _listKey,
      removedItemBuilder: _buildRemovedItem,
      initialItems: _initialList
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _groupList.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: _buildItem,
    );
  }
}