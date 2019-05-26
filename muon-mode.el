;; Very simple major editing mode for the Muon programming language.
;; https://github.com/pgervais/muon-mode
;;
;; Muon can be found at https://github.com/nickmqb/muon
;;
;; Provides:
;; - simple syntax highlighting (keywords & comments)
;; - basic (tab-only) indentation
;;
;; Usage: put this in your .emacs
;; (require 'muon-mode)
;; (setq auto-mode-alist (cons '("\\.mu\\'" . muon-mode) auto-mode-alist))
;;
;; This file is under the MIT License
;; https://opensource.org/licenses/MIT

(require 'smie)

(defconst muon-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; ' is a string delimiter
    (modify-syntax-entry ?' "\"" table)
    ;; " is a string delimiter too
    (modify-syntax-entry ?\" "\"" table)

    ;; / is punctuation, but // is a comment starter
    (modify-syntax-entry ?/ ". 12" table)
    ;; \n is a comment ender
    (modify-syntax-entry ?\n ">" table)
    ;; # is the start of an attribute
    (modify-syntax-entry ?# "'" table)
    ;; underscore is part of a word. This is to highlight things like
    ;; "string" and "string_" properly._
    (modify-syntax-entry ?_ "w" table)
    ;; Pairs
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\} "){" table)
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\] ")[" table)
    table))

(defgroup muon-faces nil
  "Faces for Muon major mode."
  :prefix "muon-"
  :group 'muon-faces)

(defvar muon-builtin-face 'muon-builtin-face)
(defface muon-builtin-face
  '((t (:foreground "cyan1" :background "black")))
  "Muon keywords."
  :group 'muon-faces)

(defvar muon-attribute-face 'muon-attribute-face)
(defface muon-attribute-face
  '((t (:foreground "SpringGreen2" :background "black")))
  "Muon attributes."
  :group 'muon-faces)

(defvar muon-builtin-list
  '("if" "else" "while" "break" "continue" "for" "match" "struct" "null"
    "cast" "false" "true" "enum" "return" "ref" "abandon" "new"
    "int" "float" "double" "byte" "sbyte" "short" "ushort" "uint" "long" "ulong"
    "ssize" "usize" "string" "cstring")
  )

(defvar muon-attribute-list
  '("#RefType" "#Flags" "#Foreign" "#As" "#VarArgs" "#Mutable" "#ThreadLocal")
  )

(eval-when-compile
  (defun muon-ppre (re)
    (format "\\<\\(%s\\)\\>" (regexp-opt re))))

(eval-when-compile
  (defun muon-attribute-ppre (re)
    (format "\\(%s\\)\\>" (regexp-opt re))))

(defvar muon-font-lock-keywords
  (list
   (cons (eval-when-compile
           (muon-ppre muon-builtin-list))
         muon-builtin-face)
   (cons (eval-when-compile
           (muon-attribute-ppre muon-attribute-list))
         muon-attribute-face)
   )
  "Minimal highlighting expressions for Muon mode"
  )

(defcustom muon-indent-level 2
  "Base indentation step for Muon code."
  :type 'integer)

(defun muon-smie-rules (kind token)
  (pcase (cons kind token)
    (`(:elem . basic) muon-indent-level)
    (`(:elem . arg) 0)
    (`(:list-intro . ,_) t) 
    (`(:after . ,(or `"(" `"{" `"["))
     (if (not (smie-rule-hanging-p)) muon-indent-level))
    (`(:before . ,(or `"(" `"{" `"["))
     (if (smie-rule-hanging-p) (smie-rule-parent)))
    )
  )

(define-derived-mode muon-mode prog-mode "Muon"
  :syntax-table muon-mode-syntax-table
  (set (make-local-variable 'indent-tabs-mode) t)
  (set (make-local-variable 'font-lock-defaults)
              '(muon-font-lock-keywords))
  (font-lock-fontify-buffer)
  (smie-setup nil #'muon-smie-rules)
  
  (set (make-local-variable 'comment-start) "// ")
  ;; No need to quote nested comments markers.
  (set (make-local-variable 'comment-quote-nested) nil)
  )

(provide 'muon-mode)
