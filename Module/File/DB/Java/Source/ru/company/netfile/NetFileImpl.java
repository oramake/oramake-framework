package ru.company.netfile;

import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;

import com.enterprisedt.net.ftp.FTPException;
import com.enterprisedt.net.ftp.FTPOutputStream;
import com.enterprisedt.net.ftp.ssh.SSHFTPOutputStream;



/** class: NetFileImpl
 * Абстрактный базовый класс для реализации файловых операций.
 */
abstract class NetFileImpl
{

  /** func: getPath
   * Возвращает путь до файла.
   */
  abstract public String getPath()
  ;



  /** func: getName
   * Возвращает имя файла.
   */
  abstract public String getName()
  ;



  /** func: checkState
   * Обновляет информацию о файле и возвращет его тип либо null, если файл не
   * существует.
   */
  abstract public FileType checkState()
    throws IOException, FTPException
  ;

  /** func: dir
   * Возвращает массив с информацией о файлах каталога или null, если файл не
   * является каталогом либо не существует.
   */
  abstract public FileInfo[] dir()
    throws IOException, FTPException
  ;

  /** func: getInputStream
   * Возвращает поток для чтения из файла
   */
  abstract public InputStream getInputStream()
    throws IOException, FTPException
  ;

  /** func: getOutputStream
   * Возвращает поток для записи в файл
   */
  abstract public OutputStream getOutputStream( boolean append)
    throws IOException, FTPException
  ;

  /** proc: copy
   * Копирует файл
   */
  abstract public void copy( String toPath, boolean overwrite)
    throws IOException, FTPException
  ;

  /** proc: delete
   * Удаляет файл
   */
  abstract public void delete()
    throws IOException, FTPException
  ;

  /** proc: renameTo
   * Пытается выполнить переименование файла.
   *
   * Параметры:
   * toPath                   - новый путь ( URL) к файлу
   * overwrite                - признак перезаписи файла
   *
   * Возврат:
   * true                     - в случае успеха
   * false                    - в случае неудачи
   */
  abstract public boolean renameTo( String toPath, boolean overwrite)
    throws IOException, FTPException
  ;

  /** proc: makeDirectory
   * Создаёт директорию.
   */
  abstract public void makeDirectory( boolean raiseException)
    throws IOException, FTPException
  ;

} // NetFileImpl
