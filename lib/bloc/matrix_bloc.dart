import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../PathFinder.dart';

part 'matrix_event.dart';
part 'matrix_state.dart';

class MatrixBloc extends Bloc<MatrixEvent, MatrixState> {
  MatrixBloc() : super(MatrixInitial()) {
    on<GenerateMatrixEvent>(generateMatrix);
  }

  Future<void> generateMatrix(GenerateMatrixEvent event,Emitter<MatrixState> emit) async {
    emit(Loading());

    List<List<int>> grid = [
      [0,0,0,0,0,0,],
      [0,0,0,0,0,0,],
      [0,0,0,0,0,0,],
      [0,0,0,0,0,0,],
      [0,0,0,0,0,0,],
      [0,0,0,0,0,0,],
    ];

    int gW = grid[0].length;
    int gH = grid.length;

    int source = Random().nextInt(gW*gH);


    List<List<int>> paths = [];

    var assigned = [];
    var destinations = [];
    var sourceNeigh = [];

    Map overAllPath = {};

    do{

      int? des;

      do{

        int rand = Random().nextInt(gW*gH);

        if(source!= rand && !assigned.contains(rand)){
          des = rand;
        }
      }while(des==null);



      List blocks = [];

      Map connectingTypes = {};

      if(destinations.isNotEmpty){
        blocks = destinations;
        grid = [
          [0,0,0,0,0,0,],
          [0,0,0,0,0,0,],
          [0,0,0,0,0,0,],
          [0,0,0,0,0,0,],
          [0,0,0,0,0,0,],
          [0,0,0,0,0,0,],
        ];
        if(destinations.length<gW/2){

          do{

            int block = Random().nextInt(gW*gH);

            if(source!= block && des!=block){
              blocks.add(block);
              grid[block~/gW][block%gW]=-1;
            }
          }while(blocks.length<gW/2);

        }else{
          for (var val in blocks) {
            grid[val~/gW][val%gW]=-1;
          }
        }


      }else{
        do{

          int block = Random().nextInt(gW*gH);

          if(source!= block && des!=block){
            blocks.add(block);
            grid[block~/gW][block%gW]=-1;
          }
        }while(blocks.length<gW/2);
      }

      PathFinder pathFinder = PathFinder(grid,source,des);
      List<int> points = [];

      for (var val in pathFinder.path) {
        points.add(pathFinder.convert2Dto1D(val));
      }

      paths.add(points);
      assigned = assigned+points;

      assigned = [...{...assigned}];

      destinations.add(des);

      if(pathFinder.pathExists){

//         print("source: $source | des: $des | blocks: $blocks");

        List<int> points = [];

        for (var val in pathFinder.path) {
          points.add(pathFinder.convert2Dto1D(val));
        }

        paths.add(points);
        print(points);

        var neighbourR = pathFinder.getCell1R(cell1: source,cell2: points[1]);

        if(!sourceNeigh.contains(neighbourR)){
          sourceNeigh.add( neighbourR );
        }

        connectingTypes = pathFinder.getCPT(points);

        if(overAllPath.isNotEmpty){
          overAllPath = pathFinder.combineConnectingPoints(source,overAllPath , connectingTypes);
        }else{
          overAllPath = connectingTypes;
        }

//         print("points: $points");
      }


    }while(assigned.length<gW*gH);

    CellInfo sourceCellInfo = overAllPath[source];

    if(sourceNeigh.length==2){

      if((sourceNeigh.contains("L") && sourceNeigh.contains("R")) || (sourceNeigh.contains("T") && sourceNeigh.contains("B"))){
        sourceCellInfo.type = 5;
      }else {
        sourceCellInfo.type = 2;
      }

    }else{
      sourceCellInfo.type = sourceNeigh.length;
    }

    overAllPath[source] = sourceCellInfo;

    for(var key in overAllPath.keys){
      print("cell $key");
      print("type ${overAllPath[key].type}");
      print("rT ${overAllPath[key].rT}");
      print("");
    }


    emit(MatrixGenerated(cPT: overAllPath));



    // emit(MatrixGenerated(cPT: type));
    // emit(MatrixGenerated(cPT: type));

  }
}
