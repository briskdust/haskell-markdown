module Markdown.Parser where

import Data.List (isPrefixOf)
import Markdown.Types

-- Parse Markdown text
parseMarkdown :: String -> [MDElement]
parseMarkdown = parseLines . lines

-- Parse multiple lines
parseLines :: [String] -> [MDElement]
parseLines [] = []
parseLines (line : rest)
  | null line = parseLines rest
  | "```" `isPrefixOf` line =
      let (element, remaining) = parseCodeBlock (line : rest)
       in element : parseLines remaining
  | "#" `isPrefixOf` line = parseHeading line : parseLines rest
  | "-" `isPrefixOf` trimStart line =
      let (element, remaining) = parseUnorderedList (line : rest)
       in element : parseLines remaining
  | isOrderedListItem line =
      let (element, remaining) = parseOrderedList (line : rest)
       in element : parseLines remaining
  | otherwise = parseParagraph line : parseLines rest
  where
    trimStart = dropWhile (== ' ')
    isOrderedListItem s = case reads (takeWhile (/= '.') $ trimStart s) :: [(Integer, String)] of
      [(_, "")] -> True
      _ -> False

-- Parse heading
parseHeading :: String -> MDElement
parseHeading str =
  let level = length $ takeWhile (== '#') str
      content = dropWhile (== ' ') $ drop level str
   in Heading level content

-- Parse paragraph
parseParagraph :: String -> MDElement
parseParagraph text = Paragraph (parseInline text)

-- Parse inline elements
parseInline :: String -> [MDInline]
parseInline [] = []
parseInline ('\\' : c : rest) =
  case parseInline rest of
    (PlainText text) : inlines -> PlainText (c : text) : inlines
    inlines -> PlainText [c] : inlines
parseInline ('*' : '*' : rest) =
  let (content, remaining) = span (/= '*') rest
   in case remaining of
        ('*' : '*' : next) -> Bold content : parseInline next
        _ -> PlainText "**" : parseInline rest
parseInline ('*' : rest) =
  let (content, remaining) = span (/= '*') rest
   in case remaining of
        ('*' : next) -> Italic content : parseInline next
        _ -> PlainText "*" : parseInline rest
parseInline ('[' : rest) =
  let (text, remaining) = span (/= ']') rest
   in case remaining of
        (']' : '(' : rest2) ->
          let (url, remaining2) = span (/= ')') rest2
           in case remaining2 of
                (')' : next) -> Link text url : parseInline next
                _ -> PlainText "[" : parseInline rest
        _ -> PlainText "[" : parseInline rest
parseInline (c : rest) = case parseInline rest of
  (PlainText text) : inlines -> PlainText (c : text) : inlines
  inlines -> PlainText [c] : inlines

-- Parse code block
parseCodeBlock :: [String] -> (MDElement, [String])
parseCodeBlock (start : rest) =
  let language = drop 3 (trim start)
      (code, remaining) = break ("```" `isPrefixOf`) rest
      content = unlines code
   in (CodeBlock language content, drop 1 remaining)
parseCodeBlock [] = (CodeBlock "" "", [])

-- Parse unordered list
parseUnorderedList :: [String] -> (MDElement, [String])
parseUnorderedList lines =
  let (items, rest) = parseListItems "-" 0 lines
   in (UnorderedList items, rest)

-- Parse ordered list
parseOrderedList :: [String] -> (MDElement, [String])
parseOrderedList lines =
  let (items, rest) = parseListItems "1." 0 lines
   in (OrderedList items, rest)

-- Generic list item parser
parseListItems :: String -> Int -> [String] -> ([ListItem], [String])
parseListItems marker indent lines =
  case lines of
    [] -> ([], [])
    (line : rest) ->
      let currentIndent = length $ takeWhile (== ' ') line
          trimmedLine = trim line
       in if currentIndent < indent || not (isListItem marker trimmedLine)
            then ([], lines)
            else
              let content = parseParagraph $ dropListMarker marker trimmedLine
                  (subItems, afterSub) = parseListItems marker (currentIndent + 2) rest
                  (nextItems, remaining) = parseListItems marker indent afterSub
                  item = ListItem content subItems
               in (item : nextItems, remaining)

-- Helper functions
isListItem :: String -> String -> Bool
isListItem "-" s = "-" `isPrefixOf` s
isListItem "1." s = case reads (takeWhile (/= '.') s) :: [(Integer, String)] of
  [(_, "")] -> True
  _ -> False
isListItem _ _ = False

dropListMarker :: String -> String -> String
dropListMarker marker str = case marker of
  "-" -> drop 2 . dropWhile (== ' ') . drop 1 $ str
  "1." -> drop 2 . dropWhile (== ' ') . drop (length $ takeWhile (/= '.') str) . drop 1 $ str
  _ -> str

trim :: String -> String
trim = dropWhile (== ' ') . reverse . dropWhile (== ' ') . reverse