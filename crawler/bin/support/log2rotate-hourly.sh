#!/bin/bash

newdir=/store/log2

[ ! -d $newdir ] && /bin/mkdir $newdir

file1=/var/log/$1.1
file2=$newdir/$1.`date +%Y%m%d-%02H`

#echo $file1
#echo $file2

mv $file1 $file2

find $newdir -mtime +3 -type f -print0 | xargs -0 rm -rf

