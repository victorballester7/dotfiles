#!/bin/bash
main_dir=$(pwd) # initial path working directory
for i in $(find -maxdepth 10 -type f -name "*.tex"); do # find all .tex files inside a directory (with up to 10 subdirectories)
  if [[ $i == *"/Images/"* && $1 != "Images" ]]; then # Compile the images if the parameter "Images" is passed as an argument
    continue
  fi
  cd "$(dirname $i)" # cd to the folder of the file
  latexmk $(basename $i) -pdf &> /dev/null # compilation of the file without print outputs lines
  if [[ $? -eq 0 ]]; then
    echo "$i compiled!"
  else 
    echo "$i has an error."
  fi
  cd "$main_dir" # cd to the inital path working directory
done  