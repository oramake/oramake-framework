package com.technology.oracle.moduleinfo.main.server;

import static com.technology.oracle.moduleinfo.main.server.ModuleInfoServerConstant.FINISH_APP_INSTALL_ACTION_NAME;
import static com.technology.oracle.moduleinfo.main.server.ModuleInfoServerConstant.START_APP_INSTALL_ACTION_NAME;
import static com.technology.oracle.moduleinfo.main.server.ModuleInfoServerConstant.DATA_SOURCE_JNDI_NAME;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.technology.jep.jepcommon.security.pkg_Operator;
import com.technology.jep.jepria.server.db.Db;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.oracle.moduleinfo.main.server.dao.ModuleInfo;

public class VersionServlet extends HttpServlet {
  
  private static final long serialVersionUID = 1L;
  
  protected static final Logger logger = Logger.getLogger(VersionServlet.class.getName());
    
  @Override
  public void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    appInstallAction(request, response);
  }
  
  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException{
    doPost(request, response);
  }
  
  
  private void appInstallAction(HttpServletRequest request, HttpServletResponse response) throws ServletException {
    
    String action = request.getParameter("action");
    if (!START_APP_INSTALL_ACTION_NAME.equals(action) && !FINISH_APP_INSTALL_ACTION_NAME.equals(action)) {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      return;
    } 

    Db db = null;
    Integer operatorId = null;
    try {
      
      String login = decode(request.getParameter("login"));
      String password = decode(request.getParameter("password"));
      
      db = new Db(DATA_SOURCE_JNDI_NAME);
      // ?????????????? ???????????????? ?????????????????????????? ????????????????????????.
      logger.trace("BEGIN login(" + login + ", " + password + ")");
      operatorId = pkg_Operator.logon(db, login, password);
      logger.trace("END login(" + login + ", " + password + ")");
      
    } catch (Throwable th) {
      
      String message = "Wrong login/password or encoding";
      
      response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
      logger.error(message, th);
      th.printStackTrace();
      
      return;
    } finally {
      if (db != null) db.closeAll();
    }
    
    ModuleInfo dao = ModuleInfoServerFactory.instance.getDao();
    
    if (START_APP_INSTALL_ACTION_NAME.equals(action)) {
      
      String moduleSvnRoot = request.getParameter("svnRoot");
      String moduleInitialSvnPath = request.getParameter("initPath");
      String moduleVersion = request.getParameter("modVersion");
      String installVersion = request.getParameter("instVersion");
      String deploymentPath = request.getParameter("deployPath");
      String svnPath = request.getParameter("svnPath");
      String svnVersionInfo = request.getParameter("svnVersionInfo");
      
      logger.trace("BEGIN startAppInstall(" 
          + moduleSvnRoot + ", " + moduleInitialSvnPath + ", " + moduleVersion + ", " 
          + deploymentPath + ", " + installVersion + ", " + operatorId + ")");
      
      Integer appInstallResultId = null;
      try {
        // C???????????? ???????????? ???? ?????????????????????????????? ????????????.
        appInstallResultId = dao.startAppInstall(
          moduleSvnRoot
          , moduleInitialSvnPath
          , moduleVersion
          , deploymentPath
          , installVersion
          , svnPath
          , svnVersionInfo
          , operatorId);
        
        if (appInstallResultId != null) {
          response.addHeader("appInstallResultId", appInstallResultId.toString());
        }
      } catch (Throwable th) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        
        String message = "startAppInstall error";
        logger.error(message, th);
        th.printStackTrace();
        
        return;
      } 
      
      logger.trace("END startAppInstall was succeeded : ID = " + appInstallResultId + "(" 
          + moduleSvnRoot + ", " + moduleInitialSvnPath + ", " + moduleVersion + ", " 
          + deploymentPath+ ", " + installVersion + ", " + operatorId + ")");
    
    } else if (FINISH_APP_INSTALL_ACTION_NAME.equals(action)) {

      String appInstallResultIdParam = request.getParameter("appInstallResultId");
      
      String statusCode = request.getParameter("statusCode");
      if(statusCode == null) {
        //???????? ???? ?????????? statusCode, ???????????????????????? ???????????????? javaReturnCode.
        //???????????????? ?????????????????????????? ?????? ?????????????????? ???? oas.
        statusCode = request.getParameter("javaReturnCode");
      }
      
      logger.trace("BEGIN finishAppInstall(" + appInstallResultIdParam + ", " + statusCode + ", " + operatorId + ")");
      
      String errorMessage;
      try {
        errorMessage = URLDecoder.decode(request.getParameter("errorMessage"), "UTF-8");
        
        // C???????????? ???????????? ???? ?????????????????????????????? ????????????.
        dao.finishAppInstall(
          Integer.parseInt(appInstallResultIdParam)
          , Integer.parseInt(statusCode)
          , errorMessage
          , operatorId);
        
      } catch (Throwable th) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        
        String message = "finishAppInstall error";
        logger.error(message, th);
        th.printStackTrace();
        
        throw new ServletException(th);
      }
      
      logger.trace("END finishAppInstall(" + appInstallResultIdParam + ", " + statusCode + ", " + errorMessage + ", "  + operatorId + ")");
    }
  }
  
  /**
   * ?????????????????????????? ????????????. (?????????????????????? ?? JepRiaToolkitUtil.encode) <br/> 
   * TODO: ?????????????????? ?????????? ???????????????????? ?????????????????????? ???? JepRiaToolkit.
   * 
   * @param decodeString  ???????????????????????? ????????????
   * @return ?????????????????????????????? ????????????
   * @throws UnsupportedEncodingException
   */
  private String decode(String decodeString) 
    throws UnsupportedEncodingException {
    StringBuilder sb = new StringBuilder();
    // 49204c6f7665204a617661 split into two characters 49, 20, 4c...
    for (int i = 0; i < decodeString.length() - 1; i += 2) {
      // grab the hex in pairs
      String output = decodeString.substring(i, (i + 2));
      // convert hex to decimal
      int decimal = Integer.parseInt(output, 16);
      // convert the decimal to character
      sb.append((char) decimal);
    }
    return URLDecoder.decode(sb.toString(), "UTF-8");
  }
}