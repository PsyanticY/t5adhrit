# Git Useful commands ( amend rebase, ...)

## Keeping a fork up to date.

### 1. Clone your fork:

    git clone git@github.com:YOUR-USERNAME/YOUR-FORKED-REPO.git

### 2. Add remote from original repository in your forked repository:

    cd into/cloned/fork-repo
    git remote add upstream git://github.com/ORIGINAL-DEV-USERNAME/REPO-YOU-FORKED-FROM.git
    git fetch upstream

### 3. Updating your fork from original repo to keep up with their changes:

    git pull upstream master

### 4. You've just updated your local repo and need to push your changes:

    git push


## Adding more changes to your last commit.

### 1. Amend your last commit:

    git commit --amend
_An interactive shell will open so you need to change your commit message or keep it_

### 2. Amending a Commit Without Changing Its Message;

    git commit --amend --no-edit
    git push -f origin some_branch

### 3. Just change your commit message:

    git commit --amend -m "Your new commit message"
    git push -f origin some_branch

## Delete a branch

### 1. Executive Summary:

    git push --delete <remote_name> <branch_name>
    git branch -d <branch_name>

### 2. Delete Local Branch:

    git branch -d branch_name
    git branch -D branch_name
_The -d option is an alias for --delete, which only deletes the branch if it has already been fully merged in its upstream branch. You could also use -D, which is an alias for --delete --force, which deletes the branch "irrespective of its merged status._

### 3. Delete Remote Branch:

    git push <remote_name> --delete <branch_name>
_or_

    git push <remote_name> :<branch_name>

## Modify a specific commit/Rewrite history.

    git rebase -i @~9   # Show the last 9 commits in a text editor
_An interactive shell will popuo when you can amend, squash, melt, pick, ... your commits as you see fit._

    git rebase --continue

_Git will replay the subsequent changes on top of your modified commit. You may be asked to fix some merge conflicts._

## Add a changed file to an older (not last) commit in Git

* _Store the changes we added_

    git stash

* _See last commits (10 last in this example)_

    git rebase -i HEAD~10

* _Mark the commit we wanna use with `pick`_

* _Save the rebase file therefore git will drop you out to fix your file/commit_

* _Pop the stashed changes_

    git stash pop

* _add the file with git add . and amend the commit_

    git commit --amend

* _Rewrite the rest of the commits against the new one_

    git rebase --continue
