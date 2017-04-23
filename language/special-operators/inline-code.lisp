(in-package :varjo)
(in-readtable fn:fn-reader)

;;------------------------------------------------------------
;; Inline GLSL

(v-defmacro glsl-expr (glsl-string type-spec &rest args)
  (if args
      (let ((gs (loop :for i :below (length args) :collect
                   (gensym (format nil "GEXPR~a" i)))))
        `(let ,(mapcar #'list gs args)
           (%glsl-expr ,glsl-string ,type-spec ,@gs)))
      `(%glsl-expr ,glsl-string ,type-spec)))

(v-defspecial %glsl-expr (glsl-string type-spec &rest args)
  :args-valid t
  :return
  (values
   (compile-glsl-expression-string glsl-string type-spec env args)
   env))

(defun compile-glsl-expression-string (current-line type env args)
  ;; because of the macro we are guarenteed that 'args' wont
  ;; have a to-body section.
  (let* ((objs (mapcar λ(compile-form _ env) args))
         (arg-lines (mapcar #'current-line objs))
         (type-obj (if (typep type 'v-type)
                       type
                       (type-spec->type type (flow-id!))))
         (flow-id (flow-ids type-obj))
         (glsl (apply #'format (append (list nil current-line)
                                       arg-lines))))
    (assert flow-id)
    (make-compiled :type type-obj
                   :current-line glsl
                   :used-types (list type-obj)
                   :node-tree (ast-node! 'glsl-string nil type-obj nil nil)
                   :pure nil)))

(defun glsl-let (name-symbol name-string type value-form env)
  (let ((type-spec (if (typep type 'v-type)
                       (type->type-spec type)
                       type)))
    (compile-let name-symbol type-spec value-form env name-string)))


;;------------------------------------------------------------
;; Inline Lisp (Injecting lisp expressions as uniforms)

(v-defspecial lisp-code-as-uniform (uniform-name type-spec lisp-form)
  :args-valid t
  :return
  (values
   (inject-implicit-uniform uniform-name type-spec env lisp-form)
   env))

;;------------------------------------------------------------
