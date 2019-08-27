import 'package:flutter/material.dart';
import 'dart:ui';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'today'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var habitsList = [];
  var percentage = 0.0;
  var activeIndex = 0; // 当前操作的条目

  void _handleEditHabit(habit) {
    
    setState(() {
      habitsList.add({
        'name': habit,
        'count': 0
      });
    });
  }

  void _onPanUpdate (details, index) {
    // 记录当前操作的条目
    activeIndex = index;

    // 从右到左滑
    var deltaX = details.delta.dx;
    if (deltaX <= 0) {
      setState(() {
        percentage += deltaX;
      });
    }
  }

  void _handlePanEnd (details) {
    setState(() {
      percentage = 0;
    });
  }


  List<Widget> _buildCard() {
    return this.habitsList.asMap().map((index, habit) {
      return MapEntry(index, GestureDetector(
        onPanUpdate: (details) {
          this._onPanUpdate(details, index);
        },
        onPanEnd: this._handlePanEnd,
        child: 
          Stack(
            children: <Widget>[
              Positioned(
                right: -60-(index == activeIndex ? percentage : 0.0),
                child: 
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(20),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 30
                    ),
                  ),
              ),
              Container(
                transform: Matrix4.translationValues(index == activeIndex ? percentage : 0.0, 0, 0),
                child:
                  ListTile(
                    trailing: Icon(Icons.check_circle_outline),
                    title: Text(
                      habit['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      )
                    ),
                    subtitle: Text(
                      habit['count'].toString() + '次签到',
                      style: TextStyle(
                        color: Colors.grey[350]
                      )
                    )
                  ),
              ),
            ],
          )
      ));
    }).values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: 
        Stack(
          children: <Widget>[
            Image.network(
              'https://n.sinaimg.cn/sinacn20122/725/w1125h2000/20190515/869b-hwzkfpu4684180.jpg',
              fit: BoxFit.cover,
              width: 480,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10
              ),
              child: Container(
                color:  Colors.black.withOpacity(0.3),
              ),
            ),
            ListView(
              children: this._buildCard(),
            ),
          ],  
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => EditHabit(
              callback: (val) => this._handleEditHabit(val)
            ),
          );
        },
        tooltip: 'editHabit',
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}

// 新增一个习惯
class EditHabit extends StatelessWidget {
  
  EditHabit({this.callback});
  
  final callback;

  var editController = TextEditingController();

  _editHabit(context) {
    Navigator.pop(context, '');
    this.callback(editController.text);
    // todo 增加该条目
    // editController.text
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SimpleDialog(
        title: Text('增加新习惯'),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: editController,
                )
              ),
            ],
          ),
          RaisedButton(
            color: Colors.blueGrey,
            onPressed: () => this._editHabit(context),
            child: const Text('confirm'),
          ),
        ],
      ),
    );
  }
}

// 编辑对应的习惯
// todo ...