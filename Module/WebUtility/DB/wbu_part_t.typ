create or replace type wbu_part_t force
as object
(
/* db object type: wbu_part_t
  Part of multipart HTTP request.

  SVN root: Oracle/Module/WebUtility
*/



/* var: part_name
  Part name
*/
part_name                  varchar2(256),

/* var: file_name
  File name (extend attribute of part)
*/
file_name                  varchar2(1024),

/* var: content_transfer_encode
  Content transfer encode
*/
content_transfer_encode    varchar2(1024),

/* var: part_content
  Content of the part (encoded with content_transfer_encode method)
*/
part_content               clob,


/* pfunc: wbu_part_t
  Create object

  Parameters:
  partName                    - Name of part
  partContent                 - Content ob part
  fileName                    - File name (option)
  contentTransferEncode       - Content transfer encode for part (option)

  ( <body::wbu_part_t>)
*/
constructor function wbu_part_t(
  partName                 varchar2
  , partContent            clob
  , fileName               varchar2 default null
  , contentTransferEncode  varchar2 default null
)
return self as result

)
/
