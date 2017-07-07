package com.technology.oracle.scheduler.main.server.dao;
 
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.jep.jepria.server.dao.JepDao;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.shared.field.ModuleOptions;
import com.technology.oracle.scheduler.main.shared.field.PrivilegeOptions;
import com.technology.oracle.scheduler.main.shared.field.RoleOptions;
 
public class SchedulerDao extends JepDao implements Scheduler {

  @Override
  public List<JepRecord> find(JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, 
      Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  @Override
  public Object create(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  @Override
  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  @Override
  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }
 

  public List<JepOption> getPrivilege() throws ApplicationException {
    String sqlQuery = 
      " begin " 
      + " ? := pkg_Scheduler.getPrivilege;" 
      + " end;";
     
    return super.getOptions(
        sqlQuery,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(rs.getString(PrivilegeOptions.PRIVILEGE_CODE));
            dto.setName(rs.getString(PrivilegeOptions.PRIVILEGE_NAME));
          }
        }
    );
  }
 
  public List<JepOption> getRole(String roleName) throws ApplicationException {
    String sqlQuery = 
      " begin " 
      + " ? := pkg_Scheduler.getRole(" 
          + "searchStr => ? " 
        +");" 
      + " end;";
 
    return super.getOptions(sqlQuery, 
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(getInteger(rs, RoleOptions.ROLE_ID));
            dto.setName(rs.getString(RoleOptions.ROLE_NAME));
          }
        }
        , roleName
    );
  }
  
   
  public List<JepOption> getModule() throws ApplicationException {
    String sqlQuery = 
      " begin " 
          + " ? := pkg_Scheduler.findModule;" 
      + " end;";
    
    return super.getOptions(
        sqlQuery,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(getInteger(rs, ModuleOptions.MODULE_ID));
            dto.setName(rs.getString(ModuleOptions.MODULE_NAME));
          }
        }
    ); 
  }
}
