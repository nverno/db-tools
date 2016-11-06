(require 'db-tools)
(require 'ert)

(defmacro db--should-indent (from to)
  `(with-temp-buffer
     (let ()
       (sql-mode)
       (insert ,from)
       (should (string= (buffer-substring-no-properties (point-min) (point-max))
                      ,to)))))

(defun db--run-tests ()
  (interactive)
  (if (featurep 'ert)
      (ert-run-tests-interactively "db--test")
    (message "cant run without ert.")))

(provide 'db-tests)
