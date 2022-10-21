import 'package:flutter/material.dart';

typedef RemovedItemBuilder<T> = Widget Function(
    T item, BuildContext context, Animation<double> animation);

/// Keeps a Dart [List] in sync with an [AnimatedList].
///
/// The [insert] and [removeAt] methods apply to both the internal list and
/// the animated list that belongs to [listKey].
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that
/// mutate the list must make the same changes to the animated list in terms
/// of [AnimatedListState.insertItem] and [AnimatedList.removeItem].
class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;
  final Duration animationDuration = const Duration(milliseconds: 350);

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList!.insertItem(index, duration: animationDuration);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    // callback();
    if (removedItem != null) {
      _animatedList!.removeItem(index,  (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
        duration: animationDuration
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];
  void operator []= (int index, E item) => _items[index] = item;

  int indexOf(E item) => _items.indexOf(item);
}