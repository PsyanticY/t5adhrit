# VIM

* Remove all comments and space:

                      g/\v^(#|$)/d

* Copy and Cut:

                      http://vim.wikia.com/wiki/Cut/copy_and_paste_using_visual_selection

* Comment and uncomment things:

To comment:

                      if the line has no tab/space at the beginning:
                      ctrl + V then jjj then shift + I (cappital i) then //then esc esc
                      if the line has tab/space at the beginning you still can do the above or swap for c:
                      ctrl + V then jjj then c then //then esc esc

To uncomment:

                      if the lines have no tab/space at the beginning:
                      ctrl + V then jjj then ll (lower cap L) then c

                      if the lines have tab/space at the beginning, then you space one over and esc
                      ctrl + V then jjj then ll (lower cap L) then c then space then esc

* Visual mode:

                      v + y to copy
                      v + c to cut
                      v + d to cut
                      v + p to paste
                      V to highlight a block
