package ru.company.netfile;



/** class: FileType
 * Класс для перечисления распознаваемых типов файлов
 */
class FileType {

  /** const: FILE
   * Обычный регулярный файл
   **/
  public static final FileType FILE       = new FileType();

  /** const: DIRECTORY
   * Каталог
   **/
  public static final FileType DIRECTORY  = new FileType();

  /** const: UNKNOWN
   * Файл неизвестного типа
   **/
  public static final FileType UNKNOWN    = new FileType();



  /** func: FileType
   * Конструктор для предотвращения некорректного создания объектов
   **/
  private FileType() {
  }

}
