# Set values of tests parameters only for "install-test" goal
ifneq ($(filter install-test, $(MAKECMDGOALS)),)

SQL_DEFINE = \
  ,TestHttpAbsentHost=http://nonexistent.example.com \
  ,TestHttpAbsentPath=http://www.example.com/nonexistent.html \
  ,TestHttpEchoUrl=http://httpbin.org/anything \
  ,TestHttpHeadersUrl=http://httpbin.org/headers \
  ,TestHttpTextPattern=%Example Domain% \
  ,TestHttpTextUrl=http://www.example.com \

endif
