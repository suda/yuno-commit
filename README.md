# Y U NO commit?????

Package showing warning (Y U NO meme) when there are more uncommitted changes than set trigger. Inspired by [vim plugin](https://github.com/esneider/YUNOcommit.vim).


## If you start to make too many changes, this will pop up.

![Screenshot](http://i.imgur.com/y7VzTY3.png)


## ...it will keep getting bigger if you keep on making more changes.

![Screenshot](http://i.imgur.com/Qva3WNI.png)


## Contribution

Feel free to fork, PR and file issues!

Big thanks to @dtinth whose fork has been merged into this package! Here are his changes:

- Made compatible with Atom 1.0.
- The overlay message will get bigger and bigger as you make more changes.
- Improved performance by calling the `git diff --numstat` command asynchronously, instead of checking the diff of all files in the whole repository using synchronous code.
