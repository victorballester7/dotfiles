# Description: A simple function to add, commit, and push changes to a git repository

gitsync() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: git_sync 'commit message'"
    return 1
  fi

  local commit_message="$1"

  # Add all changes, commit, and push
  git add . 
  git commit -m "$commit_message"
  git push

  # Check if the commands were successful
  if [[ $? -eq 0 ]]; then
    echo "Git sync completed successfully!"
  else
    echo "An error occurred during git sync."
  fi
}

