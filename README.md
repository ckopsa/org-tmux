# org-tmux

An Emacs package to launch tmux sessions from Org mode headings.

## Installation

1. Clone this repository or download the `org-tmux.el` file.
2. Add the following to your Emacs configuration:

```elisp
(add-to-list 'load-path "/path/to/org-tmux/")
(require 'org-tmux)
```

Or, if you're using `use-package`:

```elisp
(use-package org-tmux
  :load-path "/path/to/org-tmux/")
```

## Usage

1. In an Org file, place your cursor on any heading.
2. Press `C-c t` to launch a new terminal window attached to a tmux session named after the heading.

If you want to specify a custom tmux session name, add a `TMUX_SESSION` property to the heading:

```
* My Project
:PROPERTIES:
:TMUX_SESSION: my-custom-session
:END:
```

## History Review

You can review the history of a tmux session associated with an Org heading:

1. Place your cursor on the heading with the tmux session
2. Press `C-c h` to view the session history in a colorized buffer

## Configuration

You can customize the following variables:

- `org-tmux-terminal-command`: Command to launch the terminal application (default: "open")
- `org-tmux-terminal-args`: Arguments passed to the terminal command (default: '("-n" "-a" "Ghostty" "--args"))
- `org-tmux-session-property`: Name of the Org property used to store the session ID (default: "TMUX_SESSION")

Example configuration for a different terminal:

```elisp
(setq org-tmux-terminal-command "gnome-terminal")
(setq org-tmux-terminal-args '("--" "tmux" "new-session" "-A" "-s"))
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
