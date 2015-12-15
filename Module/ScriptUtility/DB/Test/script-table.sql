declare
  tableName varchar2(30) := 'gt_template';
  userName varchar2(30) := user;
  outPath varchar2(1000) := '\\test-disk\Code-Generation';

  i integer;
  tab_comment varchar2 (4000);
  column_comments varchar2 (4000);
  pk_name varchar2 (30);
  pk_columns varchar2 (255);
  idx_columns varchar2 (4000);


begin
  for t in
  (
    select table_name from user_tables
    where table_name = upper( tableName) or tableName is null
    order by table_name
  )
  loop
    pkg_File.deleteUnloadData();
    column_comments := '';
    pkg_File.appendUnloadData ('-- table: ' || t.table_name);
    begin
      select trim (comments) --|| decode (substr (comments, -1, 1), '.', '', '.')
      into tab_comment
      from user_tab_comments
      where table_name = t.table_name;
      if tab_comment is not null then
        pkg_File.appendUnloadData ('-- ' || tab_comment);
      end if;
    exception
      when NO_DATA_FOUND then null;
    end;

    pkg_File.appendUnloadData ('');
    pkg_File.appendUnloadData ('create table ' || t.table_name);
    pkg_File.appendUnloadData ('(');
    -- описание таблицы
    i := 0;
    for c in
    (
      select *
      from user_tab_columns
      left join user_col_comments using (table_name, column_name)
      where table_name = t.table_name
      order by column_id
    )
    loop
      pkg_File.appendUnloadData ('  '|| case when i!=0 then ', ' else '  ' end ||c.column_name ||' '|| c.data_type || case when instr (c.data_type, 'CHAR') != 0 then '('|| c.char_length ||')' else case when c.data_precision is not null and c.data_scale is not null then '('|| c.data_precision ||')' end end || case when trim(c.data_default) is not null then ' default '|| trim(c.data_default) end || case when c.nullable = 'N' then ' not null' end);
      if c.comments is not null then
        column_comments := column_comments || 'comment on column ' || c.table_name ||'.'|| c.column_name ||' is '''|| c.comments ||''';' || chr(10);
      end if;
      i := i+1;
    end loop;
    -- первичный ключ
    begin
      select constraint_name
      into pk_name
      from user_constraints
      where table_name = t.table_name
        and constraint_type = 'P';
      i:=0;
      for c in (select column_name from user_cons_columns cc where constraint_name = pk_name) loop
        pk_columns := pk_columns || case when i!=0 then ', ' end || c.column_name;
        i:=i+1;
      end loop;

      pkg_File.appendUnloadData ('  , constraint ' || pk_name ||' primary key (' || pk_columns ||') using index tablespace &' || 'indexTablespace');
    exception
      when NO_DATA_FOUND then null;
    end;

    pkg_File.appendUnloadData (');');
    -- комментарий на таблицу
    if tab_comment is not null then
      pkg_File.appendUnloadData ('');
      pkg_File.appendUnloadData ('comment on table ' || t.table_name ||' is '''|| tab_comment ||''';');
    end if;
    -- комментарии на столбцы (формируется выше)
    pkg_File.appendUnloadData (column_comments);
    -- индексы
    for idx in
    (
      select index_name
      from user_indexes
      left join user_constraints using (table_name, index_name)
      where table_name = t.table_name
        and constraint_name is null
      order by index_name
    )
    loop
      i:=0;
      idx_columns := '';

      for ic in
      (
        select column_name from sys.user_ind_columns
        where index_name = idx.index_name
          and column_name not like 'SYS%'
        order by column_position
      )
      loop
        idx_columns := idx_columns || case when i!=0 then ', ' end || trim (ic.column_name);
        i:=i+1;
      end loop;

      for ie in
      (
        select column_expression from user_ind_expressions
        where index_name = idx.index_name
        order by column_position
      )
      loop
        idx_columns := idx_columns || case when i!=0 then ', ' end || trim (ie.column_expression);
        i:=i+1;
     end loop;

      pkg_File.appendUnloadData ('create index ' || idx.index_name ||' on '|| t.table_name ||' (' || idx_columns ||') tablespace &' || 'indexTablespace;');
    end loop;

    pkg_File.appendUnloadData ('---------------------------------------------------------------------------------------');
    pkg_File.unloadTxt(
      toPath => pkg_File.getFilePath(
        outPath
        , lower( t.table_name) || '.tab'
      )
      , writeMode => pkg_File.Mode_Rewrite
    );
  end loop;
end;

