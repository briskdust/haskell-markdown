# Markdown Parser

A simple and efficient Markdown to HTML converter written in Haskell.

## Features

- Converts Markdown files to HTML
- Supports common Markdown syntax:
  - Headers (h1-h6)
  - Bold and italic text
  - Links
  - Ordered and unordered lists (with nesting)
  - Code blocks with language highlighting
- Clean and type-safe implementation
- Error handling for file operations

## Installation

### Prerequisites

- GHC (Glasgow Haskell Compiler) >= 9.4.7
- Cabal >= 2.4

### Building from source

```bash
Clone the repository
git clone https://github.com/yourusername/markdown-parser.git
cd markdown-parser
Build the project
cabal build
Optional: Install the executable
cabal install
```

## Usage

```bash
Using cabal run
cabal run markdown-parser -- input.md output.html
Or if installed
markdown-parser input.md output.html
```

### Example

Input (`test.md`):

```markdown
Hello World
This is a bold and italic text with a link.
List Example
Item 1
Subitem 1.1
Subitem 1.2
Item 2
Code Example
    ```python
    print("Hello, World!")
    ```

```

This will generate an HTML file with proper formatting and syntax highlighting.

## Project Structure

- `Main.hs`: Entry point and file handling
- `Markdown/`
  - `Types.hs`: AST definitions
  - `Parser.hs`: Markdown parsing logic
  - `HTML.hs`: HTML generation

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the CommonMark specification
- Built with Haskell's type safety and elegance in mind
