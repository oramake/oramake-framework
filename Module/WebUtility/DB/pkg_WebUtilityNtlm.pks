create or replace package pkg_WebUtilityNtlm is

/* package: pkg_WebUtilityUtil
  Perform NTLM authentification.

  SVN root: Oracle/Module/WebUtility
*/



/* group: Functions */



/* pfunc: ntlmLogin
  Perform NTLM authentification

  Параметры:
  requestUrl                  - URL of web service
  username                    - The username for the authentication
  password                    - The password for the HTTP authentication
  domain                      - The user domain for the authentication

  Return:
  ntlm token.

*/
function ntlmLogin(
  requestUrl                varchar2
  , username                varchar2
  , password                varchar2
  , domain                  varchar2
)
return varchar2;

/* pfunc: ntlmLogin
  Close session.
*/
procedure ntlmLogoff;



end pkg_WebUtilityNtlm;
/
