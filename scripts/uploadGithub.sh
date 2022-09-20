if [[ $1 -eq 0 ]]; then
  git init
  git remote add origin $1 
  git add .
  git commit -m 'first commit'
  git branch -M main
  git push -u origin main
else 
  echo "You should pass as a parameter the ssh address that github has proporcioned to you."
fi