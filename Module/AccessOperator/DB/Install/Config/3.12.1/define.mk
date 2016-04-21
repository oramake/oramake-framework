LOAD_FILE_MASK = \
  Install/Schema/Last/v_op_role.vw \
  , pkg_Operator.pk[sb]

override SKIP_FILE_MASK += ,*oms-check-lock*
