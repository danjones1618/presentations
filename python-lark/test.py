  import re

  def can_parse(text: str) -> bool:
    pattern = re.Pattern(r"A*B[BC]+B*")
    return pattern.match(text)
