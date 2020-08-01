public class Olifant.Html {

    public static string remove_tags (string content) {
        var all_tags = new Regex("<(.|\n)*?>", RegexCompileFlags.CASELESS);
        return all_tags.replace(content, -1, 0, "");
    }

    public static string simplify (string content) {
        var html_params = new Regex("(class|target|rel|data-user|data-tag)=\"(.|\n)*?\"", RegexCompileFlags.CASELESS);
        var tags_to_clean = new Regex("(</?(em)[^<>]*/?>|<p>)");
        var tags_to_make_linebreak = new Regex("</?(br|p|blockquote)[^<>]*/?>");
        var simplified = tags_to_make_linebreak.replace (
            tags_to_clean.replace(
                html_params.replace(content, -1, 0, ""),
                -1, 0, ""
            ),
            -1, 0, "\n"
        );

        while (simplified.has_suffix ("\n"))
            simplified = simplified.slice (0, simplified.last_index_of ("\n"));

        return simplified;
    }

    public static string uri_encode (string content) {
        var to_escape = ";&+";
        return Soup.URI.encode (content, to_escape);
    }

}
