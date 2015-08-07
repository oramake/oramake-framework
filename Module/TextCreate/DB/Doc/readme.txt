title: Описание

Модуль предназначен для формирования текстовых данных.

Возможности:

- обеспечивает буферизованное формирование clob
	с учётом рекомендаций по размеру буфера
	( см. <http://download.oracle.com/docs/cd/B28359_01/appdev.111/b28419/d_lob.htm#ARPLS600>);

Пример формирования clob:

( code)
begin
  pkg_TextCreate.newText();
  pkg_TextCreate.append( 'Hello, text!');
  pkg_Common.outputMessage(
    to_char( pkg_TextCreate.getClob())
  );
end;
/
( end code)

- конвертация текстовых данных из двоичных, и обратно;
