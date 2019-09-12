create or replace and compile java source named "JavaFileEncoding2" as

import static java.lang.System.out;
import java.util.List;
import java.util.ArrayList;
import java.io.IOException;
import java.io.File;
import java.io.FilenameFilter;
import java.nio.charset.*;

import java.math.BigDecimal;

import com.technology.oramake.file.netfile.*;

public class JavaFileEncoding2 {

public static String getCyrillicFileName() {
   System.out.println("Default Charset=" + Charset.defaultCharset());
     File f = new File("\\\\rusfinance.ru\\files\\Work\\Test\\File");
     File[] list = f.listFiles();
    for(int
       i = 0
       ; i < list.length
        ; i++
    ) {
      if (!list[i].isDirectory()) {
        return list[i].getName();
      }
    }
   return "";
   }


   public static String getCyrillicFileName2()
   throws IOException
   {
     File folder = new File("\\\\rusfinance.ru\\files\\Work\\Test\\File");

       String[] files = folder.list();

        for ( String fileName : files ) {
            out.println(fileName + ":" + new String(fileName.getBytes("Windows-1252"),"Windows-1251"));
        }

      File[] list = folder.listFiles();
      for(int
         i = 0
         ; i < list.length
          ; i++
      ) {
        if (!list[i].isDirectory()) {
          out.println(list[i].getName() + ":" + new String(list[i].getName().getBytes("Windows-1252")));
        }
      }

        out.println("Default Charset=" + Charset.defaultCharset());
        return System.getProperty("file.encoding");

  }


  /** func: exists
 * Проверяет существование файла или каталога
 *
 * Параметры:
 * fromPath                   - путь к файлу или каталогу
**/
public static java.math.BigDecimal
exists(
  java.lang.String fromPath
)
  throws
    java.io.IOException
    , java.sql.SQLException
    , com.enterprisedt.net.ftp.FTPException
{
  NetFile netfile = new NetFile(new String(fromPath.getBytes(), "Windows-1252"));
  int nExists =
    ( netfile.exists() ? 1 : 0 );
  return ( new BigDecimal( (double) nExists ));
}


}
/


create or replace function getCyrillicFileName3 return varchar2 as
language java name 'JavaFileEncoding2.getCyrillicFileName2() return
java.lang.String';
/

create or replace function getCyrillicFileName return varchar2 as
language java name 'JavaFileEncoding2.getCyrillicFileName() return
java.lang.String';
/

create or replace function getCyrillicCheckExists(filePath varchar2) return varchar2 as
language java name 'JavaFileEncoding2.exists(java.lang.String) return
java.math.BigDecimal';
/



select getCyrillicCheckExists('\\rusfinance.ru\files\Work\Test\File\ёж2.txt') from dual;

