#
# Local module

use meth/doc


export use sweep
export use voyager
#
# Keyboard Utilities
# 
export def main [
  --find (-f): string # string to find in command names
] {
  doc module local --find $find
}


