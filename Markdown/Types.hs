module Markdown.Types where

-- Markdown AST data types
data MDElement
  = Heading Int String -- Heading and its level
  | Paragraph [MDInline] -- Paragraph with inline elements
  | UnorderedList [ListItem] -- Unordered list
  | OrderedList [ListItem] -- Ordered list
  | CodeBlock String String -- Code block with language and content
  deriving (Show, Eq)

-- List item type
data ListItem = ListItem
  { itemContent :: MDElement,
    subItems :: [ListItem]
  }
  deriving (Show, Eq)

-- Inline element data types
data MDInline
  = Bold String
  | Italic String
  | Link String String
  | PlainText String
  deriving (Show, Eq)