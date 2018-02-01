# Set values of tests parameters only for "install-test" goal
ifneq ($(filter install-test, $(MAKECMDGOALS)),)

SQL_DEFINE = \
  ,TestHttpAbsentPath=http://www.example.com/nonexistent.html \
  ,TestHttpAbsentHost=http://nonexistent.example.com \
  ,TestHttpTextPattern=%Example Domain% \
  ,TestHttpTextUrl=http://www.example.com \

endif
