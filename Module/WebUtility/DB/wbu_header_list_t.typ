create or replace type wbu_header_list_t force
as
/* db object type: wbu_header_list_t
  Headers of HTTP request.

  SVN root: Oracle/Module/WebUtility
*/
table of wbu_header_t
/
