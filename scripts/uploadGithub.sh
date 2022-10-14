if [[ -z $1 ]]; then # if we do no pass a parameter to the function
  echo "You should pass as a parameter the ssh address that github has proporcioned to you." 
else 
  git init
  git remote add origin $1 
  git add .
  git commit -m 'first commit'
  git branch -M main
  git push -u origin main
fi