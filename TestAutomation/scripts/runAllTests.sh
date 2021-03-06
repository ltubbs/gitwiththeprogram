#!/bin/bash

#
# MASTER BASH SCRIPT - runAllScripts
#
# This bash script runs the testInterpreter python file on every command
# specified in the testCasesExecutables folder, providing it a temp file
# which corresponds with that file
# it then compares the files to their expected output stored in the testCases folder
# Then outputs whether or not the files were the same to it's respective reportfile
# Report files increment (1, 2, 3) so they don't overwrite
# temp folder is wiped after each execution, so don't put anything in there
#
# All paths are absolute, so the script should work from anywhere so long as
# The directory structure is set up properly
# In the future, this script could handle generating the final report... etc
# Of course, it could also call a python script to do the heavy lifting
#
# How we integrate the bash and the python is up do us, since both are capable
# of doing the job, but I think this script has turned out quite nicely
#

DEBUG ='0'

# Organizational variables, makes things prettier and easier to modify
ROOTFOLDER=$(dirname $(dirname $(realpath $0)))
SCRIPTSFOLDER="$ROOTFOLDER/scripts"
TEMPFOLDER="$ROOTFOLDER/temp"
TESTSFOLDER="$ROOTFOLDER/testCasesExecutables"
COMPAREFOLDER="$ROOTFOLDER/testCases"
REPORTSFOLDER="$ROOTFOLDER/reports"
echo "Found root folder : $ROOTFOLDER"
echo "Using temp folder: $TEMPFOLDER"
echo "Using tests folder: $TESTSFOLDER"
echo "Using compare folder: $COMPAREFOLDER"
echo "Using reports folder: $REPORTSFOLDER"
echo "Creating working temp directory"
mkdir -p $TEMPFOLDER

# Uses a counter-based system. Reports that are generated dont overwrite the previous
COUNTER='1'
REPORTSFILE="$REPORTSFOLDER/testResults$COUNTER.html"
while [ -f $REPORTSFILE ]
do
   COUNTER=$((COUNTER+1))
   REPORTSFILE="$REPORTSFOLDER/testResults$COUNTER.html"
done

#echo -n "Running all tests in folder: $(pwd)"
#echo "Outputting report to:$REPORTSFILE"

#iterate through entries
echo "adding base html head to report file"
cat $SCRIPTSFOLDER/baseReportHead.txt > $REPORTSFILE

TOTALPASSED=0
TOTALFAILED=0
for entry in $TESTSFOLDER/*;
do
  echo
  echo "Running test with commands stored in file: $(basename $entry)"

  TEMPFILE="$TEMPFOLDER/tempfile$(basename $entry)"
  COMPAREFILE="$COMPAREFOLDER/correct-$(basename $entry)"

  echo "outputting to tempfile located at $TEMPFILE"

  # what is passed in is now BOTH full paths. eg. instead of test1 it will be
  # /home/me/gitWithTheProgram/TestAutomation/testCasesExecutables/test1.txt
  # instead of just test1.txt. this is very useful because this location is
  # directory independent. No need to change directories
  # but, if you just want the test1.txt, you can use basename, as I did above
  # eg. $(basename $entry)

 if $DEBUG
  then
     echo "passing files $entry and $TEMPFILE to the python script"
 fi


 python $SCRIPTSFOLDER/pocTestInterpreter.py $entry $TEMPFILE

  #compares files, routes actual diff output to be deleted
 if $DEBUG
  then
     echo "comparing \"$(cat $TEMPFILE)\" and \"$(cat $COMPAREFILE)\""
 fi

 echo "<tr>" >> $REPORTSFILE
 echo "<td>$(basename $entry)</td>" >> $REPORTSFILE
 echo "<td>$(head -n 1 $entry)</td>" >> $REPORTSFILE
 echo -n "<td id=\"d01\">" >> $REPORTSFILE

 OUTDIFF=diff -B -b $TEMPFILE $COMPAREFILE
 echo $OUTDIFF
 if [ -z "$OUTDIFF" ];
 #diff -B -b $TEMPFILE $COMPAREFILE >/dev/null 2>&1
 then

     echo "$entry passed"
     echo -n "passed" >> $REPORTSFILE
     TOTALPASSED=$((TOTALPASSED+1))
 else
     echo "$entry failed"
     echo -n "failed" >> $REPORTSFILE
     TOTALFAILED=$((TOTALFAILED+1))
 fi
  echo "</td>" >> $REPORTSFILE
  echo "</tr>" >> $REPORTSFILE
done

echo "$TOTALPASSED passed $TOTALFAILED failed"
echo "<tr id=\"r01\">" >> $REPORTSFILE
echo "<td colspan=\"2\">Overall Results</td>" >> $REPORTSFILE
echo "<td id=\"d01\">$TOTALPASSED passed $TOTALFAILED failed</td>" >> $REPORTSFILE
echo "adding tail html to reports file"
cat $SCRIPTSFOLDER/baseReportTail.txt >> $REPORTSFILE

echo "cleaning temp..."
rm "$TEMPFOLDER/"*
echo "displaying report.."
xdg-open $REPORTSFILE
