-- script: Test/interface-table.sql
-- Ãåíåğàöèÿ ñêğèïòà èíòåğôåéñíîé òàáëèöû ïî èñõîäíîìó ïğåäñòàâëåíèş
-- ( òåñòîâûé ñêğèïò).

@reconn

declare

  outputFilePath varchar2(1000) :=
    '&outputFilePath'
  ;

begin
  pkg_ScriptUtility.generateInterfaceTable(
    outputFilePath      => outputFilePath
    , objectPrefix      => 'ct'
  );
end;
/
