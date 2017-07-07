package com.technology.oracle.scheduler.moduleroleprivilege.server.dao;
 
import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.PREFIX_DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.server.ModuleRolePrivilegeServerConstant.DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.server.ModuleRolePrivilegeServerConstant.RESOURCE_BUNDLE_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.*;

import javax.ejb.Local;
import javax.ejb.Remote;
import javax.ejb.Stateless;

import oracle.j2ee.ejb.StatelessDeployment;

import com.technology.jep.jepria.server.ejb.JepDataStandardBean;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;
import com.technology.oracle.scheduler.main.shared.field.DataSourceOptions;
import com.technology.oracle.scheduler.main.shared.field.ModuleOptions;
import com.technology.oracle.scheduler.main.shared.field.PrivilegeOptions;
import com.technology.oracle.scheduler.main.shared.field.RoleOptions;
import com.technology.oracle.scheduler.moduleroleprivilege.server.dao.ModuleRolePrivilege;
import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.field.option.JepOption;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
 
@Local( { ModuleRolePrivilegeLocal.class })
@Remote( { ModuleRolePrivilegeRemote.class })
@StatelessDeployment
@Stateless
public class ModuleRolePrivilegeBean extends SchedulerDao implements ModuleRolePrivilege {
 
  public ModuleRolePrivilegeBean() {
    super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
  }
 
  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin  " 
        +  "? := pkg_Scheduler.findModuleRolePrivilege(" 
            + "moduleRolePrivilegeId => ? " 
            + ", moduleId => ? " 
            + ", privilegeCode => ? " 
            + ", roleId => ? " 
          + ", maxRowCount => ? " 
          + ", operatorId => ? " 
        + ");"
     + " end;";

    final String dataSource = getValueFromOption(templateRecord.get(DATA_SOURCE));
    
    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {
        
        JepOption jepOption = new JepOption(dataSource, dataSource);
        record.set(DATA_SOURCE, jepOption);
        
        record.set(MODULE_ROLE_PRIVILEGE_ID, getInteger(rs, MODULE_ROLE_PRIVILEGE_ID));
        
        jepOption = new JepOption(rs.getString(MODULE_NAME), getInteger(rs, MODULE_ID));
        record.set(MODULE_ID, jepOption);
        record.set(MODULE_NAME, jepOption.getName());
        
        String privilegeCode = rs.getString(PRIVILEGE_CODE);
        jepOption = new JepOption(rs.getString(PRIVILEGE_NAME), rs.getString(PRIVILEGE_CODE));
        record.set(PRIVILEGE_CODE_STR, privilegeCode);
        record.set(PRIVILEGE_CODE, jepOption);
        record.set(PRIVILEGE_NAME, jepOption.getName());
        
        record.set(ROLE_SHORT_NAME, rs.getString(ROLE_SHORT_NAME));

        jepOption = new JepOption(rs.getString(ROLE_NAME), getInteger(rs, ROLE_ID));
        record.set(ROLE_ID, jepOption);
        record.set(ROLE_NAME, jepOption.getName());
        
        record.set(DATE_INS, getDate(rs, DATE_INS));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
      }
    };
    
    return DaoSupport.find(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
        resourceBundleName,
        resultSetMapper,
        JepRecord.class
        , templateRecord.get(MODULE_ROLE_PRIVILEGE_ID)
        , getValueFromOption(templateRecord.get(MODULE_ID))
        , getValueFromOption(templateRecord.get(PRIVILEGE_CODE))
        , getValueFromOption(templateRecord.get(ROLE_ID))
        , maxRowCount 
        , operatorId);
  }
  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        + "pkg_Scheduler.deleteModuleRolePrivilege(" 
            + "moduleRolePrivilegeId => ? " 
          + ", operatorId => ? " 
        + ");"
      + "end;";
    
    DaoSupport.delete(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
        resourceBundleName
        , record.get(MODULE_ROLE_PRIVILEGE_ID) 
        , operatorId);
  }
 
  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }
 
  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        + "? := pkg_Scheduler.createModuleRolePrivilege(" 
            + "moduleId => ? " 
            + ", privilegeCode => ? " 
            + ", roleId => ? " 
          + ", operatorId => ? " 
        + ");"
      + "end;";

    return DaoSupport.<Integer> create(sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
        resourceBundleName,
        Integer.class 
        , getValueFromOption(record.get(MODULE_ID))
        , getValueFromOption(record.get(PRIVILEGE_CODE))
        , getValueFromOption(record.get(ROLE_ID))
        , operatorId);
  }
  
  public List<JepOption> getModule(String dataSource) throws ApplicationException {
    String sqlQuery = 
      " begin " 
      + " ? := pkg_Scheduler.findModule;" 
      + " end;";
 
    return DaoSupport.find(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
        resourceBundleName,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(getInteger(rs, ModuleOptions.MODULE_ID));
            dto.setName(rs.getString(ModuleOptions.MODULE_NAME));
          }
        }
        , JepOption.class
    );
  }
 
  public List<JepOption> getPrivilege(String dataSource) throws ApplicationException {
    String sqlQuery = 
      " begin " 
      + " ? := pkg_Scheduler.getPrivilege;" 
      + " end;";
 
    return DaoSupport.find(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
        resourceBundleName,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(rs.getString(PrivilegeOptions.PRIVILEGE_CODE));
            dto.setName(rs.getString(PrivilegeOptions.PRIVILEGE_NAME));
          }
        }
        , JepOption.class
    );
  }
 
  public List<JepOption> getRole(String dataSource) throws ApplicationException {
    String sqlQuery = 
      " begin " 
      + " ? := pkg_Scheduler.getRole;" 
      + " end;";
    
    return DaoSupport.find(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
        resourceBundleName,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(getInteger(rs, RoleOptions.ROLE_ID));
            dto.setName(rs.getString(RoleOptions.ROLE_NAME));
          }
        },
        JepOption.class
    );
  }
}
