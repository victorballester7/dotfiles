# script to change the names ***.JPG to ***.jpg or ***.MP4 to ***.mp4 of all files in a directory but do it also for all subdirectories


# change all JPG to jpg
for i in $(find . -name "*.JPG"); do mv $i ${i%.*}.jpg; done

# change all MP4 to mp4
for i in $(find . -name "*.MP4"); do mv $i ${i%.*}.mp4; done