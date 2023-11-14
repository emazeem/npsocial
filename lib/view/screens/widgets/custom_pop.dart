import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

class ItemModel {
  String title;
  IconData icon;
  Color color;

  ItemModel(this.title, this.icon, this.color);
}

class PopupScreen extends StatefulWidget {
  const PopupScreen({super.key});

  @override
  State<PopupScreen> createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen> {
  CustomPopupMenuController _controller = CustomPopupMenuController();

  late List<ItemModel> menuItems;
  @override
  void initState() {
    super.initState();
    menuItems = [
      ItemModel('Delete', Icons.delete, Colors.red),
      ItemModel('Block', Icons.block, Colors.red),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('CustomPopupMenu'),leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ), actions: <Widget>[
      CostumPopup(menuItems: menuItems, controller: _controller),
    ]));
  }
}

class CostumPopup extends StatelessWidget {
  const CostumPopup({
    super.key,
    required this.menuItems,
    required CustomPopupMenuController controller,
  }) : _controller = controller;

  final List<ItemModel> menuItems;
  final CustomPopupMenuController _controller;

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      child: Container(
        child: Icon(Icons.add_circle_outline, color: Colors.white),
        padding: EdgeInsets.all(20),
      ),
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: const Color(0xFF4C4C4C),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: menuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _controller.hideMenu();
                      },
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 15,
                              color: Colors.red,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: _controller,
    );
  }
}
