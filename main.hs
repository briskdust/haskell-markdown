module Main where

import Control.Exception (IOException, catch)
import Markdown.HTML (makeHTML, toHTML)
import Markdown.Parser (parseMarkdown)
import Markdown.Types
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (readFile, writeFile)

-- Main function: handle file conversion
main :: IO ()
main = do
  args <- getArgs
  case args of
    [input, output] -> convertFile input output
    _ -> putStrLn "Usage: ./program input.md output.html"

-- File conversion function
convertFile :: FilePath -> FilePath -> IO ()
convertFile input output = do
  content <-
    readFile input `catch` \e -> do
      putStrLn $ "Error: Cannot read file " ++ input
      putStrLn $ "Reason: " ++ show (e :: IOException)
      exitFailure
  let ast = parseMarkdown content
      html = makeHTML (toHTML ast)
  writeFile output html `catch` \e -> do
    putStrLn $ "Error: Cannot write file " ++ output
    putStrLn $ "Reason: " ++ show (e :: IOException)
    exitFailure
