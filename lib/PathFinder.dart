
import 'dart:collection';

class PathFinder{

  late List<List<int>> grid;

  int gridWidth = 0;
  int gridHeight = 0;

  late Queue<Point> path;
  late bool pathExists;

  PathFinder(this.grid, source, des){

    //holds path front
    Queue<int> frontier = Queue<int>();

    gridWidth = grid[0].length;
    gridHeight = grid.length;

    //dummy list of grid size
    List<int> cameFrom = List.generate(
      gridWidth * gridHeight,
          (int index) => -1,
      growable: false,
    );

    Point sourceCell = convert1Dto2D(source);
    Point desCell = convert1Dto2D(des);

    frontier.add(convert2Dto1D(sourceCell));

    while(frontier.isNotEmpty){

      int current = frontier.removeFirst();

      Queue<Point> neighbors =  this.neighbors(convert1Dto2D(current));

      for (Point node in neighbors) {

        int node1d = convert2Dto1D(node);

        if (cameFrom[node1d] == -1) {
          frontier.add(node1d);
          cameFrom[node1d] = current;
        }
      }

    }

    pathExists = true;

    path = Queue<Point>();

    Point endNode = desCell;

    path.add(endNode);

    while (
    endNode.x != sourceCell.x || endNode.y != sourceCell.y) {
      int endNode1d = convert2Dto1D(endNode);


      if (cameFrom[endNode1d] == -1) {
        pathExists = false;
//         print("no solution");
        break;
      }

      endNode = convert1Dto2D(cameFrom[endNode1d]);
      path.addFirst(endNode);
    }

//     print("solution exists");

    return;
  }

  int convert2Dto1D(Point node){
    return node.y * gridWidth + node.x;
  }

  Point convert1Dto2D(int node){
    int y = node ~/ gridWidth;
    int x = node - y * gridWidth;

    return Point(x:x,y:y);
  }

  Queue<Point> neighbors(Point node) {

    Queue<Point> neighbors = Queue<Point>();

    for (int dx = -1; dx <= 1; dx += 2) {
      Point neighborNode = Point(y: node.y, x: node.x + dx);
      if (isValidNode(neighborNode)) {
        neighbors.add(neighborNode);
      }
    }
    for (int dy = -1; dy <= 1; dy += 2) {
      Point neighborNode = Point(y: node.y + dy, x: node.x);
      if (isValidNode(neighborNode)) {
        neighbors.add(neighborNode);
      }
    }

    return neighbors;
  }

  bool isValidNode(Point node) {
    if (node.x >= 0 &&
        node.y >= 0 &&
        node.x < gridWidth &&
        node.y < gridHeight &&
        grid[node.y][node.x] != -1) {
      return true;
    }
    return false;
  }

  Map getCPT(List path){

    Map cPT = {};

    for(int i=0;i<path.length;i++){

      int type;
      int rT = 1;

      if(i==0){
        type = 1;
        int after = path[i+1];
        int current = path[i];
        String r1 = getCell1R(cell1: current, cell2: after);

        if(r1=="R"){
          rT=1;
        }else if(r1=="B"){
          rT=2;
        }else if(r1=="L"){
          rT=3;
        }else if(r1=="T"){
          rT=4;
        }


      }else if(i==path.length-1){
        type = 0;
        rT = 1;
      }else{

        int current = path[i];
        int before = path[i-1];
        int after = path[i+1];

        String r1 = getCell1R(cell1: before, cell2: current);
        String r2 = getCell1R(cell1: current, cell2: after);

        if(r1==r2){
          type = 5;
        }else{
          type = 2;
        }

        r1 = getCell1R(cell1: current, cell2: before);
        r2 = getCell1R(cell1: current, cell2: after);

        String cR = r1+r2;

        if(type==2){

          if(cR=="RB" || cR=="BR"){
            rT=1;
          }else if(cR=="LB" || cR=="BL"){
            rT=2;
          }else if(cR=="LT" || cR=="TL"){
            rT=3;
          }else if(cR=="TR" || cR=="RT"){
            rT=4;
          }

        }else if(type==5){

          if(cR=="RL" || cR=="LR"){
            rT=1;
          }else if(cR=="TB" || cR=="BT"){
            rT=2;
          }

        }

      }

      CellInfo info = CellInfo(type: type, rT: rT);

      cPT[path[i]] = info;
    }

    return cPT;
  }

  Map combineConnectingPoints(int source,Map path1, Map path2){

    for(var key1 in path1.keys){

      CellInfo info1 = path1[key1];

      if(info1.type!=1 && info1.type!=-1){

        path2.keys.any((key2){
          if(key2==key1){

            CellInfo info2 = path2[key2];

            int type1 = info1.type;
            int type2 = info2.type;
            int rT1 = info1.rT;
            int rT2 = info2.rT;

            int diff = (rT1-rT2).abs();

            if(type1==2 && type2==2){

              if(diff==0){

              }else if(diff%2 != 0){
                info1.type = 3;

                if(diff==1){
                  info1.rT = 1;
                }else{
                  info1.rT = 4;
                }

              }else if(diff%2 == 0){
                info1.type = 4;
              }

            }else if(type1==3 && type2==3){

              if(diff!=0){
                info1.type = 4;
              }else {
                info1.type = 3;
              }

            }else if(type1==5 && type2==5){

              if(diff==0){
                info1.type = 5;
              }else if(diff%2 != 0){
                info1.type = 4;
              }else if(diff%2 == 0){
                info1.type = 5;
              }

            }else if((type1==2 && type2==3) || (type1==3 && type2==2)){

              if((type1==2 && type2==3)){
                diff = rT1-rT2;
                info1.rT = info2.rT;
              }else {
                diff = rT2-rT1;
              }

              if(diff==-3 || diff==0 || diff==1){
                info1.type = 3;
              }else{
                info1.type = 4;
              }

            }else if((type1==5 && type2==2) || (type2==5 && type1==2)){

              int rT1 = 1;
              int rT2 = 1;

              if((type1==5 && type2==2)){
                rT1 = info2.rT;
                rT2 = info1.rT;
              }else{
                rT1 = info1.rT;
                rT2 = info2.rT;
              }

              int diff = rT1-rT2;

              if(rT2==1){

                if(diff<=1){
                  info1.rT = 1;
                }else{
                  info1.rT = 3;
                }

              }else{
                if(diff==0 || diff==1){
                  info1.rT = 2;
                }else{
                  info1.rT = 4;
                }
              }

              info1.type = 3;



            }else if((type1==5 && type2==3) || (type2==5 && type1==3)){

              if((type1==5 && type2==3)){
                info1.rT = info2.rT;
              }else {
              }

              if(diff==0 || diff%2==0){
                info1.type = 3;
              }else{
                info1.type = 4;
              }

            }

            path1[key1] = info1;

            path2.remove(key2);
            return true;
          }
          return false;
        });

      }

    }

    path1.addAll(path2);

    return path1;
  }

  String getCell1R({required int cell1, required int cell2}){

    if(cell2==cell1-1){
      return "L";
    }else if(cell2==cell1+1){
      return "R";
    }else if(cell2==cell1-gridWidth){
      return "T";
    }else if(cell2==cell1+gridWidth){
      return "B";
    }else{
      return "NR";
    }

  }
}

class CellInfo{
  int type;
  int rT;
  CellInfo({required this.type, required this.rT});
}

class Point{
  int x;
  int y;
  Point ({required this.x,required this.y});
}