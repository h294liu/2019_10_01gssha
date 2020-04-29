#!/bin/csh

foreach Dir1 (*grids)
  foreach Dir2 ($Dir1/mb*)
    mkdir -p $Dir1.tmp/$Dir2:t/
    echo trimming files in $Dir1/$Dir2:t/

    foreach F ( $Dir1/$Dir2:t/*Temp.asc )
      awk '{if(NR>5){for(i=1;i<=NF;i++)printf("%.1f ",$i);printf("\n")}else{print}}' $F > $Dir1.tmp/$Dir2:t/$F:t
    end
  end
end
