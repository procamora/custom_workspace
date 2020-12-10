from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple, Union, Dict, Text, Set
import re


@dataclass
class Shortcuts:
    command: Text

    def __post_init__(self: Shortcuts):
        """
        Coge el string del comando, lelimina la parte opcional si la tiene ({..shift..}), y crea una lista
        con el comando resultante spliteandolo por +, y aplucicando strip y lower al comando
        """
        self.command = re.sub(rf'{re.escape("{_,shift + }")}', '', self.command)
        self.commands: List[Text] = list(map(lambda command: command.strip().lower(), self.command.split('+')))
        self.commands = sorted(self.commands)

    def __str__(self: Shortcuts) -> Text:
        """
        representacion en str en formato legible para poder comparar duplicados de forma sencilla
        """
        return f"{' + '.join(self.commands)}"


def checkIfDuplicates_1(listOfElems):
    ''' Check if given list contains any duplicates '''
    if len(listOfElems) == len(set(listOfElems)):
        return False
    else:
        return True


def valid(l) -> bool:
    if len(l) == 0 or l[0] == '#' or l[0] == ' ' or l[0] == '\t':
        return False
    return True


file: Path = Path('~/.config/sxhkd/sxhkdrc').expanduser()

shortcuts: List[Text] = list()
for i in file.read_text().split('\n'):
    if valid(i):
        s: Shortcuts = Shortcuts(i)
        # print(s)
        shortcuts.append(str(s))

# https://stackoverflow.com/questions/1541797/how-do-i-check-if-there-are-duplicates-in-a-flat-list
s: Set = set()
any(x in s or s.add(x) for x in shortcuts)
# You can use a similar approach to actually retrieve the duplicates.
s: Set = set()
duplicates: Set = set(x for x in shortcuts if x in s or s.add(x))

if len(duplicates) > 0:
    print(f'Duplicates: {duplicates}')
else:
    print('No duplicates')
