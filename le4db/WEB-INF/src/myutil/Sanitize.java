package myutil;

public class Sanitize {

    public static String forHtml(String src){
        if (src == null) {return "";};
        src = src.replace("&", "&amp;");
        src = src.replace("<", "&lt;");
        src = src.replace(">", "&gt;");
        src = src.replace("\"", "&quot;");
        src = src.replace("'", "&apos;");
        return src;
    }

}
