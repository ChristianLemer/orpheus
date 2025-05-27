#
# Local module

use meth/doc


#
# Voyager Utilities
# 
export def main [
  --find (-f): string # string to find in command names
] {
  doc module local --find $find
}

# Run system profiler
export def profiler [
  
] {
  system_profiler SPUSBDataType | grep -A 10 -B 1 -i Voyager
}
