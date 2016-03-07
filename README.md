[![Build Status](https://travis-ci.org/liloman/generate-autocompletion.svg?branch=master)](https://travis-ci.org/liloman/generate-autocompletion)

Generate-autocompletion
=======================

Generate automagically bash autocompletion for any command that admits the gnu long option --help.

##Quick Start
```bash
git clone https://github.com/liloman/generate-autocompletion
cd generate-autocompletion
./generate-autocompletion stat
source ~/.local/share/bash-completion/completions/stat
```
![Screencast](https://github.com/liloman/generate-autocompletion/raw/master/images/cast.gif "Screencast")

##Install

Copy/soft link generate-autocompletion.sh into .local/bin and update your .bashrc/.bash_profile/... accordingly.


##Tests

You can run tests using [Bats](https://github.com/sstephenson/bats).

```bash
[[ -f /etc/lsb-release ]] && bats test/ubuntu.bats
[[ -f /etc/fedora-release ]] && bats test/fedora.bats
```
Should output something like:

```
➬bats tests/fedora.bats
✓ command without arguments
✓ command without options/verbs
✓ command without software
✓ command with standalone options only
✓ command with both options 
✓ command with both options 2
✓ command with verbs 1
✓ command with verbs 2
✓ command with verbs 3
✓ command without autocompletion already

10 tests, 0 failures
```

##TODO


- [ ] Implement something like [zsh auto fu](https://github.com/hchbaw/auto-fu.zsh) with [bash simple curses](https://github.com/metal3d/bashsimplecurses)  
- [ ] Recheck results against man pages also to detect false positives
- [ ] Able to parse commands like cpupower with "old output style"

