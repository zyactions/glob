#!/usr/bin/env python3
# coding: utf8

import argparse
import sys

# Enable relative import of `wcmatch`
sys.path.append('.')
from wcmatch import glob

parser = argparse.ArgumentParser(description='Returns each file that matches the given glob pattern.')
parser.add_argument('pattern', nargs='+',
                    help='The glob pattern to use. Can be passed multiple times.')
args = parser.parse_args()

# Ignore comments
patterns = list(filter(lambda x: not x.startswith('#'), args.pattern))

matches = glob.iglob(patterns=patterns, limit=100, flags=
    glob.NODOTDIR  |    # Do not match '.' and '..'
    glob.DOTGLOB   |    # Match directories and files that start with '.'
    glob.NEGATE    |    # A preceeding '!' negates the pattern
    glob.NEGATEALL |    # Assume '**' if no inlcusion pattern was passed
    glob.EXTGLOB   |    # Enable extended pattern list matching
    glob.GLOBSTAR  |    # Enable '**' pattern to match zero or more directories
    glob.GLOBTILDE |    # Substitute '~' with the current user path
    glob.FOLLOW    |    # Allow '**' to match and traverse symlink directories
    glob.BRACE          # Enable brace expansion
)

for filename in matches:
    print(filename)
