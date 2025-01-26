module Markdown.HTML (toHTML, makeHTML) where

import Markdown.Types

-- Convert AST to HTML
toHTML :: [MDElement] -> String
toHTML = concatMap elementToHTML

-- Convert single element to HTML
elementToHTML :: MDElement -> String
elementToHTML (Heading level text) =
  "<h" ++ show level ++ ">" ++ escapeHTML text ++ "</h" ++ show level ++ ">\n"
elementToHTML (Paragraph inlines) =
  "<p>" ++ concatMap inlineToHTML inlines ++ "</p>\n"
elementToHTML (UnorderedList items) =
  "<ul>\n" ++ concatMap renderListItem items ++ "</ul>\n"
elementToHTML (OrderedList items) =
  "<ol>\n" ++ concatMap renderListItem items ++ "</ol>\n"
elementToHTML (CodeBlock lang code) =
  "<pre><code" ++ langAttr ++ ">" ++ escapeHTML code ++ "</code></pre>\n"
  where
    langAttr = if null lang then "" else " class=\"language-" ++ lang ++ "\""

-- Convert inline elements to HTML
inlineToHTML :: MDInline -> String
inlineToHTML (Bold text) = "<strong>" ++ escapeHTML text ++ "</strong>"
inlineToHTML (Italic text) = "<em>" ++ escapeHTML text ++ "</em>"
inlineToHTML (Link text url) = "<a href=\"" ++ escapeHTML url ++ "\">" ++ escapeHTML text ++ "</a>"
inlineToHTML (PlainText text) = escapeHTML text

-- Render list items
renderListItem :: ListItem -> String
renderListItem (ListItem content []) =
  "<li>" ++ toHTML [content] ++ "</li>\n"
renderListItem (ListItem content subs) =
  "<li>"
    ++ toHTML [content]
    ++ (if null subs then "" else "<ul>\n" ++ concatMap renderListItem subs ++ "</ul>\n")
    ++ "</li>\n"

-- HTML escape
escapeHTML :: String -> String
escapeHTML = concatMap escape
  where
    escape '<' = "&lt;"
    escape '>' = "&gt;"
    escape '&' = "&amp;"
    escape '"' = "&quot;"
    escape c = [c]

-- Generate complete HTML document
makeHTML :: String -> String
makeHTML content =
  unlines
    [ "<!DOCTYPE html>",
      "<html>",
      "<head>",
      "<meta charset=\"UTF-8\">",
      "<title>Markdown Conversion Result</title>",
      "</head>",
      "<body>",
      content,
      "</body>",
      "</html>"
    ]