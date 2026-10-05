# script to change the names ***.JPG to ***.jpg or ***.MP4 to ***.mp4 of all files in a directory but do it also for all subdirectories

change_files() {
  # change all JPG to jpg
  for i in $(find . -name "*.JPG"); do mv $i ${i%.*}.jpg; done

  # change all MP4 to mp4
  for i in $(find . -name "*.MP4"); do mv $i ${i%.*}.mp4; done
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
    change_files
    echo -e "${GREEN}Done${RESET}"
    cd $base_folder
done
