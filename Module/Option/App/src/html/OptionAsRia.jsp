<!DOCTYPE html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.technology.jep.jepria.client.JepRiaClientConstant" %>
<%@ page import="static com.technology.jep.jepria.server.util.JepServerUtil.getLocale"%>
<%@ page import="java.util.ResourceBundle" %>

<% ResourceBundle jepRiaText = ResourceBundle.getBundle("com.technology.jep.jepria.shared.text.JepRiaText", getLocale(request)); %>
<html style="width: 100%; height: 100%;">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    
    <!--                                           -->
    <!-- Any title is fine                         -->
    <!--                                           -->
    <title>OptionAsRia Module</title>
    
    <!--                                           -->
    <!-- This script loads your compiled module.   -->
    <!-- If you add any GWT meta tags, they must   -->
    <!-- be added before this line.                 -->
    <!--                                           -->
    <script type="text/javascript" language="javascript" src="OptionAsRia/OptionAsRia.nocache.js"></script>
  </head>

  <!--                                           -->
  <!-- The body can have arbitrary html, or       -->
  <!-- you can leave the body empty if you want   -->
  <!-- to create a completely dynamic UI.         -->
  <!--                                           -->
  <body style="margin: 0px; padding: 0px; width: 100%; height: 100%;">

    <!-- OPTIONAL: include this if you want history support -->
    <iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position: absolute; width: 0; height: 0; border: 0;"></iframe>
    
    <!-- RECOMMENDED if your web app will not function without JavaScript enabled -->
    <noscript>
      <div class="jepRia-noJavaScriptEnabledMessage"><%= jepRiaText.getString("noJavaScriptEnabledMessage") %></div>
    </noscript>
    <div id="testBuildMessage" class="<%= JepRiaClientConstant.TEST_BUILD_MESSAGE_CLASS %>"> 
        <div class="jepRia-testBuildMessageNotification error"> 
            <div class="jepRia-testBuildMessageClose" onclick="document.getElementById('testBuildMessage').style.display = 'none';">
                X
            </div> 
            <div class="jepRia-testBuildMessageHeader">
                Attention please!
            </div> 
            <div class="jepRia-testBuildMessageInfo">
                This is test build!
            </div> 
        </div> 
    </div>
    <div id="loadingProgress" class="jepRia-loadingProgress">
      <div class="jepRia-loadingIndicator">
        <img src="images/loading.gif" width="32" height="32" alt="Loading..."/>
        <div>
          <p>
            <span id="loadingHeader">OptionAsRia</span>
          </p>
          <span id="loadingMessage" class="jepRia-loadingMessage"><%= jepRiaText.getString("loadingMessage") %></span>
        </div>
      </div>
    </div>
  
    <table style="border: 0px; table-layout: fixed; border-collapse: collapse; margin: 0px; padding: 0px; width: 100%; height: 100%;">
      <tr>
        <td style="width: 100%; height: 100%;">
 
          <div id="<%= JepRiaClientConstant.APPLICATION_SLOT %>" style="width: 100%; height: 100%; position: relative;"></div>

        </td>
      </tr>
    </table>
    
    <!-- According to HTML5 Specification we can place link and style tags in any place inside <BODY> -->
    <!-- For that purpose we should use attribute 'property' -->
    <!-- It allows us to guarantee that all our styles will be applied in correct order without replacing GWT styles-->
    <link type="text/css" rel="stylesheet" property='stylesheet' href="css/JepRia.css" />
    <link type="text/css" rel="stylesheet" property='stylesheet' href="css/OptionAsRia.css" />
  </body>
</html>
