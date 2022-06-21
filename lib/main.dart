import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_find/PathFinder.dart';
import 'package:random_find/bloc/matrix_bloc.dart';
import 'package:random_find/matrix.dart';
import 'widgets/RotateTrans.dart';
import 'canvas/arc_painter.dart';
import 'canvas/end_point.dart';


main() => runApp(const MaterialApp(home: App(), debugShowCheckedModeBanner: false));

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {

  late MatrixBloc bloc;


  late AnimationController animationController;
  late Tween tween;
  late Animation animation;

  int total = 36;
  Map<int, Map<String, dynamic>> map = {};
  List joins = [];
  var rng = Random();
  late int start;
  late int end;
  late int connectingPoints;

  @override
  void initState() {
    bloc = MatrixBloc();

    bloc.add(GenerateMatrixEvent());

    start = rng.nextInt(total-1);
    do {
      end = rng.nextInt(total - 1);
    }while(end==start);

    List.generate(total, (index) {
      Map<String, dynamic> map1 = {};
      animationController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
      tween = Tween<double>(begin: 0.0, end: 0.0);
      animation = tween.animate(animationController);

      map1["controller"] = animationController;
      map1["tween"] = tween;
      map1["animation"] = animation;
      map1["type"] = -1;
      map1["rTime"] = 1;
      map1["cRTime"] = 0;
      map1["isCorrect"] = false;


      map[index] = map1;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black12,
        body: BlocBuilder<MatrixBloc, MatrixState>(
            bloc: bloc,
            builder: (context, state) {
            if(state is Loading){
              return const CircularProgressIndicator();
            }else if(state is MatrixGenerated){
              print("state ${state.cPT}");

              for (var element in state.cPT.keys) {

                CellInfo info = state.cPT[element];

                map[element]!["type"] = info.type;
                map[element]!["cRTime"] = info.rT;

              }

              for (var key in state.cPT.keys) {
                if(state.cPT[key]==1) {
                  map[key]!["isCorrect"] = true;
                  start = key;
                  if(joins.isEmpty) {
                    joins.add(key);
                  }
                }
                if(map[key]!["isCorrect"]) break;
              }

              return SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: body()
              );
            }else{
              return const Center(
                child: Text("Failed"),
              );
            }
          }
        )
      )
    );
  }

  Widget body(){
    return Center(
        child: Container(
            padding: const EdgeInsets.all(50),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: sqrt(total).toInt()),
              itemBuilder: (BuildContext context,index){
                return InkWell(
                    onTap:()=> rotateChildContinuously(index),
                    child:Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black12
                          )
                      ),
                      child: map[index]!["type"]==-1?Container():
                      RotateTrans(
                          child: CustomPaint(
                            painter:
                            (map[index]!["type"]==1 || map[index]!["type"]==0)
                                ? EndPoint(isJoined: map[index]!["isCorrect"])
                                : ArcPainter(isJoined: map[index]!["isCorrect"],joins: map[index]!["type"]),
                          ) ,
                          animation: map[index]!["animation"]!
                      ),
                      width: 100,
                      height: 100,
                    )
                );
              },
              itemCount: total,
            )
        )
    );
  }

  rotateChildContinuously(int index) async{
    print("1");
    Tween cTween = map[index]!["tween"];
    print(cTween);
    AnimationController cAnimationController =  map[index]!["controller"];
    cTween.begin = cTween.end;
    cTween.end = double.parse("${cTween.end}") + pi / 2;

    if (map[index]!["rTime"] != 4) {
      map[index]!["rTime"] = map[index]!["rTime"] + 1;
    } else {
      map[index]!["rTime"] = 1;
    }

    for(int i=0;i<total;i++){
      if(map[i]!["type"]==4){
        map[i]!["isCorrect"] = true;
      }else{
        if(map[i]!["rTime"] == map[i]!["cRTime"]) {
          map[i]!["isCorrect"] = true;
        }else{
          map[i]!["isCorrect"] = false;
        }
      }

    }

    cAnimationController.forward(from: 0);
    setState(() {

    });
  }

  List checkingCells = [];

  checkJoinFlow(List index){

    if(checkingCells.isEmpty){
      return;
    }

    for (var element in index) {
      List sides = Matrix().getSL(element,16);
      for (var i in sides) {
        bool val = Matrix().canJoin(i, map[i]!["rTime"],  map[i]!["type"], element, map[element]!["rTime"],  map[element]!["type"], 4);
        if(val) {
          joins.add(i);
          checkingCells.add(i);
        }else{
          checkingCells.remove(i);
        }
      }
    }

    checkJoinFlow(checkingCells);
  }

}
