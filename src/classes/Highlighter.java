package classes;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import java.io.*;
import java.nio.charset.StandardCharsets;

public class Highlighter {
    private final Document document;
    private int line = 1;

    public Highlighter() {
        String html = "<html><head><title>Highlighter</title></head>"
                + "<body style=\"background-color:#222222;font-family:monospace;\">"
                + "<div id='tokens'> <p>" + "<span style=" + "\"color:lightgrey\">" + line + " | " + "</span>" + "&nbsp;" + "</p>"
                + "</body></html>";
        document = Jsoup.parse(html);
    }

    public Document getDocument() {
        return document;
    }

    public void addHtmlText(String text, Type type) {
        Element p = document.getElementsByTag("p").first();
        Element span = new Element("span");
        span.attr("style", getStyle(type));
        span.append(getRightTextFormat(text));
        p.append(span.outerHtml());
    }

    private String newLineWithGreyStyle(int line) {
        return "<br><span style=" + "\"color:lightgrey\">" + line + " | " + "</span>";
    }

    private String getRightTextFormat(String text) {
        text = text.replaceAll(" ", "&nbsp;")
                .replaceAll("\t", "&nbsp;&nbsp;&nbsp;&nbsp;")
                .replaceAll("\r", "");
        while (text.contains("\n")) {
            text = text.replaceFirst("\n", newLineWithGreyStyle(++line));
        }
        return text;
    }

    private String getStyle(Type type) {
        String color = "color:";
        String font = "font-weight:";
        switch (type) {
            case BOOLEAN:
            case RESERVED_KEYWORD:
                color += "#FC618D";
                font += "normal";
                break;
            case IDENTIFIER:
                color += "#FFFFFF";
                font += "normal";
                break;
            case HEX:
            case INTEGER_NUMBER:
                color += "#F59762";
                font += "normal";
                break;
            case SCIENTIFIC_NOTATION:
            case REAL_NUMBER:
                color += "#F59762";
                font = "font-style:italic";
                break;
            case STRING:
                color += "#FCE566";
                font += "normal";
                break;
            case ESCAPE_CHAR:
                color += "#EE82EE";
                font = "font-style:italic";
                break;
            case COMMENT:
                color += "#69676C";
                font += "normal";
                break;
            case WHITESPACE:
            case OPERATOR_AND_PUNCTUATION:
                color += "#00FFFF";
                font += "normal";
                break;
            case UNDEFINED:
            default:
                color += "#FF0000";
                font += "normal";
                break;
        }
        return color + ";" + font;
    }

    public void writeToHtml(String html, String path) throws IOException {
        try (Writer writer = new BufferedWriter(new OutputStreamWriter(
                new FileOutputStream(path), StandardCharsets.UTF_8))) {
            writer.write(html);
        }
    }
}
