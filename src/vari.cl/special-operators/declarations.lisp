(in-package :vari.cl)
(in-readtable fn:fn-reader)

;;------------------------------------------------------------
;; Declarations
;;
;; The main logic for this is in value-metadata.lisp


;; {TODO} The declarations in 'locally' are meant to be lexically scoped.
;;        however so far our metadata always flows with the values.
;;        Resolve this later.
;;
(v-defspecial locally (&rest body)
  :args-valid t
  :return
  (vbind (body-san-decl declarations) (extract-declares body)
    (if declarations
        (compile-locally body-san-decl declarations env)
        (compile-form `(progn ,@body) env))))

(defun compile-locally (body declarations env)
  ;; This ↓↓ mutates the env but nothing else
  (compile-declares declarations env)
  ;; This ↓↓ make code objects for the decls and splices them in
  (let* ((decls (loop :for d :in declarations :collect
                   (compile-form '(values) env))))
    (compile-form `(progn ,@decls ,@body) env)))

;;------------------------------------------------------------
;; The

(v-defspecial the (type-name form)
  :args-valid t
  :return
  (let* ((compiled (compile-form form env))
         (obj (if (stemcellp (primary-type compiled))
                  (add-type-to-stemcell-code compiled type-name)
                  (if (v-typep (primary-type compiled)
                               (type-spec->type type-name))
                      compiled ;{TODO} proper error here
                      (error "Incorrect declaration that ~a was of type ~a"
                             compiled type-name)))))
    (values obj env)))
