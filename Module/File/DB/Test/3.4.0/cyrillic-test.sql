create or replace and compile java source named "JavaFileEncoding2" as

import static java.lang.System.out;

import java.util.List;
import java.util.ArrayList;

import java.io.IOException;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.nio.file.DirectoryStream;
import java.nio.file.DirectoryIteratorException;
import java.nio.file.FileVisitResult;
import java.nio.file.SimpleFileVisitor;

import java.nio.file.attribute.BasicFileAttributes;

class MyFileVisitor extends SimpleFileVisitor {
    public FileVisitResult visitFile(Path path,
            BasicFileAttributes fileAttributes) {
        System.out.println("file name:" + path.getFileName());
        return FileVisitResult.CONTINUE;
    }

    public FileVisitResult preVisitDirectory(Path path,
            BasicFileAttributes fileAttributes) {
        System.out.println("Directory name:" + path);
        return FileVisitResult.CONTINUE;
    }
}


public class JavaFileEncoding2 {



   public static String getCyrillicFileName2()
   throws IOException
   {
     Path path = Paths.get("C:\\TEST\\тест кодировки.txt");
    path = Paths.get("\\\\rusfinance.ru\\files\\Work\\Test\\File");
     Path filePath = path.getFileName();
    out.println("2:" + filePath.toString());
    out.println("2:" + "C:\\TEST\\тест кодировки.txt");
    List<Path> result = new ArrayList<>();
     try (DirectoryStream<Path> stream = Files.newDirectoryStream(path, "*")) {
           for (Path entry: stream) {
              out.println("entry:" + entry);
           }
       } catch (DirectoryIteratorException ex) {
           // I/O error encounted during the iteration, the cause is an IOException
           throw ex.getCause();
       }

    try {
            Files.walkFileTree(path, new MyFileVisitor());
    } catch (IOException e) {
            e.printStackTrace();
    }

    path = Paths.get("\\\\rusfinance.ru\\files\\Work\\Test\\File\\абракадабра");
    // Файл может и не существовать, корректный список получить не удаётся
    out.println("path:" + path);

    return filePath.toString();
  }
}
/


create or replace function getCyrillicFileName3 return varchar2 as
language java name 'JavaFileEncoding2.getCyrillicFileName2() return
java.lang.String';
/


select getCyrillicFileName3() from dual;
