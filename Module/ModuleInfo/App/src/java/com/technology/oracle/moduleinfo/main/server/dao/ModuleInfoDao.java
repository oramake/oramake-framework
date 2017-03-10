package com.technology.oracle.moduleinfo.main.server.dao;

import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;

public class ModuleInfoDao implements ModuleInfo {

  public Integer startAppInstall(
      String moduleSvnRoot
      , String moduleInitialSvnPath
      , String moduleVersion
      , String deploymentPath
      , String installVersion
      , String svnPath
      , String svnVersionInfo
      , Integer operatorId) throws ApplicationException {
    
    return DaoSupport.<Integer>execute(
        "begin " 
          + " ? := pkg_ModuleInfo.startAppInstall(" 
              + "moduleSvnRoot => ? " 
              + ", moduleInitialSvnPath => ? " 
              + ", moduleVersion => ? "
              + ", deploymentPath => ? "
              + ", installVersion => ? "
              + ", svnPath => ? "
              + ", svnVersionInfo => ? "
              + ", operatorId => ? "
          + ");"
        + "end;",
        Integer.class,
        moduleSvnRoot,
        moduleInitialSvnPath, 
        moduleVersion, 
        deploymentPath,
        installVersion,
        svnPath,
        svnVersionInfo,
        operatorId);
    
  }
  
  public void finishAppInstall (
      Integer appInstallResultId
      , Integer javaReturnCode
      , String errorMessage
      , Integer operatorId) throws ApplicationException {
    
    DaoSupport.execute(
        "begin " 
          + " pkg_ModuleInfo.finishAppInstall(" 
            + "appInstallResultId => ? " 
            + ", javaReturnCode => ? " 
            + ", errorMessage => ? "
            + ", operatorId => ? "
          + ");"
        + "end;",
        appInstallResultId,
        javaReturnCode, 
        errorMessage, 
        operatorId);
    
  }
}
