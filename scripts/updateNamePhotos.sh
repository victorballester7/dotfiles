# Imagin in a directory we have photos and videos of the form
# 20210101_123455.jpg
# IMG_20210101_123456.jpg
# VID_20210101_123457123.mp4
# VID_20210101_123458.mp4
# ...

# This script will translate the prefix from the files to the end of it, and it will maintain a format of the form:
# yyyyMMdd_HHmmss_<prefix>.<extension> or yyyyMMdd_HHmmss.<extension>
# 20210101_123455.jpg
# 20210101_123456_IMG.jpg
# 20210101_123457_VID.mp4
# 20210101_123458_VID.mp4

#add colors to echo's
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
RESET='\033[0m'

rename_files() {
    # acces all files of the form: *.t
    ext=$(ls --file-type | grep -o '\w*$' | sort | uniq)
    for t in $ext; do
      for f in *.$t; do
          # count number of underscores in the file name
          n=$(echo $f | grep -o "_" | wc -l)
          # if there is only one underscore, continue
          if [ $n -eq 1 ]; then
              continue
          elif [ $n -eq 2 ]; then
              # get the prefix of the file IMG, VID, ...
              prefix=$(echo $f | cut -d'_' -f1)
              # if prefix has more than 3 characters, continue
              if [ ${#prefix} -gt 3 ]; then
                  continue
              fi
              # get the new name of the file of the form yyyyMMdd_HHmmss
              new_name=$(echo $f | sed -r 's/.*_([0-9]{8}_[0-9]{6})(.*)/\1/') 
              new_name=$new_name'_'$prefix'.'$t
              mv $f $new_name
          else
              echo -e "${RED}Error: $f${RESET}"
          fi
      done
    done
}

# pass the folder as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <folder>"
    exit 1
fi

cd $1
base_folder=$(pwd)

depth=3
folders=$(find ./ -maxdepth $depth -type d) 

for folder in $folders; do
    echo -e "${YELLOW}Processing $folder${RESET}"
    cd $folder
    rename_files
    echo -e "${GREEN}Done${RESET}"
    cd $base_folder
done


