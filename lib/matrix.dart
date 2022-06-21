import 'dart:math';
import 'dart:collection';


class Matrix {

  canJoin(int cell1, int cell1RT, int cell1Type,int cell2, int cell2RT, int cell2Type, int side){

    dynamic cell1ACS = getACSides(cell1RT, cell1Type);

    dynamic cell2ACS = getACSides(cell2RT, cell2Type);

    String R = getCell1R(cell1,cell2,side);


    switch(R){
      case "R" : return cell1ACS.contains("R") && cell2ACS.contains("L");
      case "L" : return cell1ACS.contains("L") && cell2ACS.contains("R");
      case "B" : return cell1ACS.contains("B") && cell2ACS.contains("T");
      case "T" : return cell1ACS.contains("T") && cell2ACS.contains("B");
      case "NR" : return false;
    }
  }

  getCell1R(int cell1, int cell2, int side){

    int n = side;

    if(cell1-n == cell2){
      return "T";
    }else if(cell1+n == cell2 ){
      return "B";
    }else if(cell1-1 == cell2){
      return "L";
    }else if(cell1+1 == cell2){
      return "R";
    }else{
      return "NR";
    }
  }

  getACSides(int rT, int type){

    if(type==5){
      if(rT%2==0){
        return ["T","B"];
      }else{
        return ["L","R"];
      }
    }

    List cSides = ["R","B","L","T"];
    int len = cSides.length;

    List sides = cSides;

    if(type==1){
      return sides[rT-1];
    }else if(type==len){
      return sides;
    }

    if(rT+type-1<=len){
      sides = sides.sublist(rT-1,rT+type-1);
    }else{
      sides = sides.sublist(rT-1,len);
    }

    int mVal = type - sides.length;

    sides = sides + cSides.sublist(0, mVal);

    return sides;
  }

  generateRM(int size, int nEP)async{

    int side = sqrt(size).toInt();

    List matrix = List.generate(size,(i)=>i);
    List blocks = List.generate(side,(i)=>Random().nextInt(size));

    int sP = 0;

    while(blocks.contains(sP)){
      sP = Random().nextInt(size);
    }

    int eP = sP;

    while((eP==sP) || blocks.contains(eP)){
      eP = Random().nextInt(size);
    }

    for(var cell in blocks){
      matrix[cell] = -1;
    }

    var gotP = await getP(sP, eP, matrix, blocks);

    return gotP;
  }

  getP(int sP, int eP, List matrix, List blocks) async{

    Queue path = Queue();

    path.addFirst(sP);

    var generatedP = await generateP(sP,eP,matrix,path, blocks);

    return generatedP;
  }

  List checked = [];
  List checkedCell = [];

  bool isForward = true;

  generateP(int sP, int eP, List matrix, Queue path, List blocks) async {
    while(true) {
      var sides = getSides(sP, matrix.length);

      if (sides["R"] != null && matrix[sides["R"]] != -1 &&
          !path.contains(sides["R"]) && !checked.contains("R")) {
        checked.add("R");
        checkedCell.add(sides["R"]);
        path.addFirst(sides["R"]);
      } else if (sides["L"] != null && matrix[sides["L"]] != -1 &&
          !path.contains(sides["L"]) && !checked.contains("L")) {
        checked.add("L");
        path.addFirst(sides["L"]);
        checkedCell.add(sides["L"]);
      } else if (sides["T"] != null && matrix[sides["T"]] != -1 &&
          !path.contains(sides["T"]) && !checked.contains("T")) {
        checked.add("T");
        checkedCell.add(sides["T"]);
        path.addFirst(sides["T"]);
      } else if (sides["B"] != null && matrix[sides["B"]] != -1 &&
          !path.contains(sides["B"]) && !checked.contains("B")) {
        checked.add("B");
        checkedCell.add(sides["B"]);
        path.addFirst(sides["B"]);
      }

      if (path.isEmpty) {
        break;
      }
      if (path.first == eP) {
        break;
      }

      path.first;

      List sides1 = getSL(path.first, matrix.length);

      sides1.removeWhere((cell) =>
      (
          blocks.contains(cell) ||
              path.contains(cell) ||
              checkedCell.contains(cell)
      ));

      if (sides1.isEmpty) {
        path.removeFirst();
      } else {
        checked = [];
      }

      if (path.isEmpty) {
        break;
      }

      generateP(path.first, eP, matrix, path, blocks);
    }

    if(path.isEmpty){
      return -1;
    }else{
      return path;
    }
  }

  getSides(int cell, int size){

    int n = sqrt(size).toInt();
    Map sides = {};

    var L = cell-1;
    var R = cell+1;
    var B = cell+n;
    var T = cell-n;

    if((L!=-1) && (cell%n!=0)) sides["L"] = L;
    if(((cell+1)%n!=0) && (R<size)) sides["R"] = R;
    if(T>=0) sides["T"] = T;
    if(B<size) sides["B"] = B;

    return sides;
  }

  getSL(int cell, int size){

    int n = sqrt(size).toInt();

    var sidesL= [];
    var L = cell-1;
    var R = cell+1;
    var B = cell+n;
    var T = cell-n;

    if((L!=-1) && (cell%n!=0)) sidesL.add(L);
    if(((cell+1)%n!=0) && (R<size)) sidesL.add(R);
    if(T>=0) sidesL.add(T);
    if(B<size) sidesL.add(B);

    return sidesL;
  }

  getCPT(List cP, int side){
    Map cPT = {};

    for(int i=0; i<cP.length; i++){
      if((i==0) || (i==cP.length-1)){
        cPT[cP[i]] = 1;
      }else{
        String R1 = getCell1R(cP[i-1],cP[i],side);
        String R2 = getCell1R(cP[i],cP[i+1],side);
        if(R1==R2){
          cPT[cP[i]] = 5;
        }else{
          cPT[cP[i]] = 2;
        }
      }
    }
    return cPT;
  }

}