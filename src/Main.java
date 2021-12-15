import classes.CompilerScanner;
import classes.Highlighter;
import classes.Symbol;

import java.io.FileReader;
import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        final String preAddressOfFiles = "src/files/";
        final String nameOfCodeFile = "code.cool";
        CompilerScanner scanner = new CompilerScanner(new FileReader(preAddressOfFiles + nameOfCodeFile));
        Highlighter highlighter = new Highlighter();
        while (true) {
            Symbol symbol = scanner.nextToken();
            if (scanner.yyatEOF()) {
                break;
            }
            highlighter.addHtmlText(symbol.getToken(), symbol.getType());
        }
        highlighter.writeToHtml(highlighter.getDocument().outerHtml(), preAddressOfFiles + "highlighter.html");
    }
}
