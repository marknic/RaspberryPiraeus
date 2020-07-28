#!/bin/bash

newId="marknic"
newPw="pass@word1"
ugid=999

#2gadmin:2gadmin123:1003:1003::/home/2gadmin:/bin/bash
input="/etc/passwd"

while IFS= read -r line
do

    my_array=($(echo $line | tr ":" "\n"))

    if [ ${my_array[2]} -lt 65000 ] && [ ${my_array[2]} -gt 999 ]
    then
        if [ ${my_array[3]} -lt 65000 ] && [ ${my_array[3]} -gt 999 ]
        then

           if [ ${my_array[3]} -gt $ugid ]
           then
               ugid=${my_array[3]}
           fi

        fi
    fi

done < "$input"

userData="$newId:$newPw:$ugid:$ugid::/home/$newId:/bin/bash"

echo "$userData"