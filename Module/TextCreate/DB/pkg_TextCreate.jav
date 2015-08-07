create or replace and compile java source named "pkg_TextCreate" as
import oracle.sql.BLOB;
import java.io.EOFException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import org.apache.tools.zip.ZipEntry;
import org.apache.tools.zip.ZipOutputStream;
public class pkg_TextCreate {
  public static BLOB compress(BLOB blob, String fileName)
    throws Exception {
    Connection con = DriverManager.getConnection("jdbc:default:connection:");
    BLOB result = BLOB.createTemporary(con, true, BLOB.DURATION_SESSION);
    ZipOutputStream out = new ZipOutputStream(result.getBinaryOutputStream());

    // Установка Dos-кодировки для имени файла в архиве для корректного
    // отображения имен файлов с русскими буквами в Windows
    // ( метод отсутствует в стандартных классях java.util.zip, возможно
    // проблема решена в JDK 7)
    out.setEncoding( "CP866");

    InputStream in = null;
    try {
      in = blob.getBinaryStream();
      out.putNextEntry(new ZipEntry(fileName));
      byte[] b = new byte[blob.getChunkSize()];
      int iCount;
      do {
        iCount = in.read(b);
        if (iCount != -1) {
          out.write(b, 0, iCount);
        }
      } while (iCount != -1);
    } catch (EOFException e) {
    } finally {
      if (in != null) {in.close();}
    }
    out.close();
    return result;
  }
}
/
