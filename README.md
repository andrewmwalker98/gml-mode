# gml-mode
Game Maker Language mode for emacs (I am aware of how dumb this is :D)

This mode was created out of my need to learn emacs while working on a Nuclear Throne mod.
It allows for `basic` auto indentation and syntax highlighting for GML. It is my own personal
tool and is thus subject to change at any time. Additionally I have not extensively tested
this so use at your own risk.

## Installing locally

Put [gml-mode.el](./gml-mode.el) in a directory `/path/to/gml/`. Add this to your `.emacs`:

```el
;; Adding `/path/to/gml/` to load-path so `require` can find it
(add-to-list 'load-path "/path/to/gml/")
;; Importing gml-mode
(require 'gml-mode)
;; Automatically enabling gml-mode on files with extension .gml
(add-to-list 'auto-mode-alist '("\\.gml\\'" . gml-mode))
```
