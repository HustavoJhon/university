from rich.console import Console
from rich.text import Text


def title():
  console = Console()
  text = Text("Hello, World!")
  text.stylize("bold magenta", 0, 6)
  console.print(text)

title()
