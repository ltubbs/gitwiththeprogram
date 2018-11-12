# Tests the x command to delete a character

import sys
import tempfile
import os
from subprocess import call
import pyautogui
import filecmp

# dirPath is the TestAutomation directory (parent directory of
# parent directory of executing script)
homeDir = os.getenv('HOME')
dirPath = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))


# Creates and saves a file containing sampleText
def makeFile(sampleText, fileName):
    # Create file in home directory
    pyautogui.typewrite('nvim')
    pyautogui.press('space')
    pyautogui.typewrite(homeDir + "/" + fileName)
    pyautogui.press('enter')
    # Enter sampleText
    pyautogui.press('i')
    pyautogui.typewrite(sampleText)
    # Enter command mode, delete the last character, save and quit
    pyautogui.press('esc')
    pyautogui.press('x')
    pyautogui.typewrite(':wq')
    pyautogui.press('enter')


def compareLines(file1, file2):
    if (filecmp.cmp(file1, file2)):
        print("Passed (lines match)")
    else:
        print("Failed (the lines do not match)")


makeFile("Hello World!", "test4.txt")

# Compare to file with the correct text
print("Test 4: ", end="")
compareLines(dirPath + "/testCases/test4-correct.txt",
    homeDir + "/test4.txt")
