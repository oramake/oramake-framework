begin
  pkg_Operator.setCurrentUserId( operatorId => 1);
end;
/

select pkg_Operator.getCurrentUserId() from dual
/

