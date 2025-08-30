(require 'subr-x)

(defvar gml-mode-syntax-table
  (let ((table (make-syntax-table)))
	(modify-syntax-entry ?/ ". 124b" table)
	(modify-syntax-entry ?* ". 23" table)
	(modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?# "." table)
    (modify-syntax-entry ?' "\"" table)
    (modify-syntax-entry ?< "." table)
    (modify-syntax-entry ?> "." table)
    (modify-syntax-entry ?& "." table)
    (modify-syntax-entry ?% "." table)
    table))

(defun gml-types ()
  '("pointer_null" "null" "undefined" "NaN" "infinity" "pointer_invalid"
    "bool" "true" "false"
    "real" "int64" "0x" "$HEX"
    "string"
    "array" "struct"
    "method" "ptr" "ref"
    "enum"))

(defun gml-keywords ()
  '("macro" "begin" "end"
    "if" "then" "else"
    "while" "do" "for"
    "break" "continue" "with"
    "until" "repeat" "exit"
    "and" "or" "xor"
    "not" "return" "mod"
    "div" "switch" "case"
    "default" "var" "globalvar"
    "enum" "#macro" "self"
    "other" "all" "global"
    "local" "undefined" "typecast"))

(defun gml-font-lock-keywords ()
  (list
   `("^#region\\s-+\\(.*\\)" 1 font-lock-comment-face prepend)
   `("^#endregion\\s-+\\(.*\\)" 1 font-lock-comment-face prepend)
   `("# *[#a-zA-Z0-9_]+" . font-lock-preprocessor-face)
   `("#.*include \\(\\(<\\|\"\\).*\\(>\\|\"\\)\\)" . (1 font-lock-string-face))
   `(,(regexp-opt (gml-keywords) 'symbols) . font-lock-keyword-face)
   `(,(regexp-opt (gml-types) 'symbols) . font-lock-type-face)))

(defun gml--previous-non-empty-line ()
  (save-excursion
    (forward-line -1)
    (while (and (not (bobp))
                (string-empty-p
                 (string-trim-right
                  (thing-at-point 'line t))))
      (forward-line -1))
    (thing-at-point 'line t)))

(defun gml--indentation-of-previous-non-empty-line ()
  (save-excursion
    (forward-line -1)
    (while (or
            (or
             (string-prefix-p "#region" (thing-at-point 'line t))
             (string-prefix-p "#endregion" (thing-at-point 'line t)))
            (and (not (bobp))
                (string-empty-p
                 (string-trim-right
                  (thing-at-point 'line t)))))
      (forward-line -1))
    (current-indentation)))

(defun gml--desired-indentation ()
  (let* ((cur-line (string-trim-right
         (replace-regexp-in-string "\\(//.*\\|/\\*.*\\*/\\)" "" (thing-at-point 'line t))))
         (prev-line (string-trim-right
         (replace-regexp-in-string "\\(//.*\\|/\\*.*\\*/\\)" "" (gml--previous-non-empty-line))))
         (indent-len 4)
         (prev-indent (gml--indentation-of-previous-non-empty-line)))
    (cond
     ((string-match-p "^\\s-*switch\\s-*(.+)" prev-line)
      (+ prev-indent indent-len))
     ((and (string-suffix-p "{" prev-line)
           (string-prefix-p "}" (string-trim-left cur-line)))
      prev-indent)
     ((and (string-match-p "^\\s-*case\\s-+.*:" prev-line)
           (not (or (string-match-p "\\breturn\\b" prev-line)
                    (or(string-suffix-p "break" prev-line)(string-suffix-p "break;" prev-line)))))
      (+ prev-indent indent-len))
     ((and (not (or(string-match-p "^\\s-*case\\s-+.*:" prev-line)(string-match-p "^\\s-*default:" prev-line)))
           (or (string-suffix-p "break" prev-line)(string-suffix-p "break;" prev-line)))
      (max (- (- prev-indent indent-len)(if (string-prefix-p "}" (string-trim-left cur-line)) indent-len 0)) 0))
     ((and (string-match-p "^\\s-*default:" prev-line)
           (not (or (string-match-p "\\breturn\\b" prev-line)
                 (or (string-suffix-p "break" prev-line)(string-suffix-p "break;" prev-line)))))
      (+ prev-indent indent-len))
     ((string-prefix-p "#define" (string-trim-left cur-line))
      0)
     ((string-prefix-p "#region" (string-trim-left cur-line))
      0)
     ((string-prefix-p "#endregion" (string-trim-left cur-line))
      0)
     ((string-suffix-p "{" prev-line)
      (+ prev-indent indent-len))
     ((string-prefix-p "#define" (string-trim-left prev-line))
      (+ prev-indent indent-len))
     ((string-prefix-p "}" (string-trim-left cur-line))
      (max (- prev-indent indent-len) 0))
     ((string-suffix-p ":" prev-line)
      (if (string-suffix-p ":" cur-line)
          prev-indent
        (+ prev-indent indent-len)))
     ((string-suffix-p ":" cur-line)
      (max (- prev-indent indent-len) 0))
     (t prev-indent))))

(defun gml-indent-line ()
  (interactive)
  (when (not (bobp))
    (let* ((desired-indentation
            (gml--desired-indentation))
           (n (max (- (current-column) (current-indentation)) 0)))
      (indent-line-to desired-indentation)
      (forward-char n))))

;;;###autoload
(define-derived-mode gml-mode prog-mode "GML Script"
  "Major mode for editing GML files"
  :syntax-table gml-mode-syntax-table
  (setq-local font-lock-defaults '(gml-font-lock-keywords))
  (setq-local indent-line-function 'gml-indent-line)
  (setq-local comment-start "// "))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.gml\\'" . gml-mode))
(provide 'gml-mode)
