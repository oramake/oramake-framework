package com.technology.oracle.moduleinfo.main.server.dao;
 
import com.technology.jep.jepria.shared.exceptions.ApplicationException;

/**
 * Интерфейс для поддержки версионности приложений.
 */
public interface ModuleInfo {

  /**
   * Добавляет результат начала установки приложения.
   * 
   * @param moduleSvnRoot          путь к корневому каталогу
   * @param moduleInitialSvnPath      первоначальный путь к корневому каталогу
   * @param moduleVersion          версия модуля
   * @param deploymentPath        путь для развертывания приложения
   * @param installVersion        устанавливаемая версия приложения
   * @param svnPath            путь в SVN
   * @param svnVersionInfo        версия в SVN
   * @param operatorId          идентификатор пользователя
   * @return идентификатор записи об установке 
   * @throws ApplicationException
   */
  Integer startAppInstall(
      String moduleSvnRoot
      , String moduleInitialSvnPath
      , String moduleVersion
      , String deploymentPath
      , String installVersion
      , String svnPath
      , String svnVersionInfo
      , Integer operatorId) throws ApplicationException;
  
  /**
   * Добавляет результат завершения установки приложения.
   * 
   * @param appInstallResultId - Идентификатор записи об установке
   * @param statusCode - Код результата выполнения установки
   * @param errorMessage - Текст сообщения об ошибках 
   * @param operatorId - Идентификатор пользователя
   * @throws ApplicationException
   */
  void finishAppInstall(
      Integer appInstallResultId
      , Integer statusCode
      , String errorMessage
      , Integer operatorId) throws ApplicationException;
}
