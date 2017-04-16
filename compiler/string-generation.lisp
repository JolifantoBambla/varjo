(in-package :varjo)
(in-readtable :fn.reader)

(defun gen-number-string (number type)
  (typecase type
    (v-double (format nil "~flf" number))
    (v-float (format nil "~ff" number))
    (v-uint (format nil "~au" number))
    (otherwise (format nil "~a" number))))

(defun gen-variable-string (var-name v-value)
  (format nil "~a" (or (v-glsl-name v-value) ()
                       (string-downcase (string var-name)))))

(defun gen-function-string (func arg-objs &optional out-strings)
  ;; This will include ephemeral types if passed. It is the responsibility
  ;; of the calling code to handle this
  (when (v-glsl-string func)
    (apply #'format nil (v-glsl-string func)
           (append (mapcar λ(current-line _ t) arg-objs)
                   out-strings
                   (mapcar #'v-glsl-name (implicit-args func))))))

(defun gen-function-transform (name args &optional out-args implicit-args)
  (format nil "~a(~{~a~^,~})" name
          (loop :for i :below (+ (length args) (length out-args)
                                 (length implicit-args))
             :collect "~a")))

(defun gen-implicit-arg-tripples (implicit-args)
  (loop :for a :in implicit-args :collect
     `(nil ,(v-glsl-string (v-type-of a)) ,(v-glsl-name a))))

(defun gen-in-out-arg-tripples (implicit-args)
  (loop :for a :in implicit-args :collect
     `("inout" ,(v-glsl-string (v-type-of a)) ,(v-glsl-name a))))

(defun gen-arg-string (arg-tripples &optional out-pairs)
  (let ((arg-string (format nil "~{~{~@[~a ~]~a ~a~}~^,~^ ~}" arg-tripples)))
    (if out-pairs
        (if (> (length arg-string) 0)
            (format nil "~a, ~{~{out ~a ~a~}~^,~^ ~}" arg-string out-pairs)
            (format nil "~{~{out ~a ~a~}~^,~^ ~}" out-pairs))
        arg-string)))

(defun gen-function-signature (name args out-args return-types implicit-args
                               in-out-args)
  (let ((args (append (mapcar λ(cons nil _) args)
                      (gen-implicit-arg-tripples implicit-args)
                      (gen-in-out-arg-tripples in-out-args))))
    (format nil "~a ~a(~a);"
            (v-glsl-string return-types)
            name
            (gen-arg-string args out-args))))

(defun gen-function-body-string (name args out-args type body-obj implicit-args
                                 in-out-args)
  (let ((args (append (mapcar λ(cons nil _) args)
                      (gen-implicit-arg-tripples implicit-args)
                      (gen-in-out-arg-tripples in-out-args))))
    (format nil "~a ~a(~a) {~%~{~a~%~}~{~a~%~}}~%"
            (v-glsl-string type)
            (string name)
            (gen-arg-string args out-args)
            (mapcat #'indent (remove "" (to-block body-obj) :test #'equal))
            (when (current-line body-obj)
              (indent (current-line (end-line body-obj)))))))

(defun gen-assignment-string (place val)
  (format nil "~a = ~a" (current-line place) (current-line val)))

(defun %gen-assignment-string (lhs rhs)
  (format nil "~a = ~a" lhs rhs))

(defun gen-setq-assignment-string (old-value new-value-code-obj)
  (format nil "~a = ~a" (v-glsl-name old-value)
          (current-line new-value-code-obj)))

(defun gen-out-var-assignment-string (glsl-name val)
  (format nil "~a = ~a" glsl-name (current-line val)))

(defun gen-bool-or-string (objs)
  (format nil "~{~a~^ || ~}" (mapcar #'current-line objs)))

(defun gen-bool-and-string (objs)
  (format nil "~{~a~^ && ~}" (mapcar #'current-line objs)))

(defun gen-while-string (test-obj body-obj)
  (format nil "~{~a~%~}while (~a) {~{~%~a~}~%}"
          (to-block test-obj)
          (current-line test-obj)
          (append (remove-empty (mapcat #'indent (to-block body-obj)))
                  (indent (current-line body-obj)))))

(defun gen-swizzle-string (vec-obj components-string)
  (format nil "~a.~a" (current-line vec-obj) (string-downcase components-string)))

(defun remove-empty (list)
  (labels ((empty-p (x)
             (uiop:emptyp
              (if (stringp x)
                  (string-trim '(#\space) x)
                  x))))
    (remove-if #'empty-p list)))

(defun gen-for-loop-string (var-string condition-obj update-obj body-obj)
  (let ((prog-strs (or (remove nil (to-block body-obj)) (list ""))))
    (format nil "for (~a;~a;~a) {~{~%~a~}~{~%~a~}~%}"
            var-string
            (current-line condition-obj)
            (current-line update-obj)
            (remove-empty (mapcat #'indent prog-strs))
            (remove-empty (when (current-line body-obj)
                            (indent (current-line body-obj)))))))

(defun gen-switch-string (test-obj keys clause-body-objs
                          &optional (default-symb 'default))
  (let* ((default-clause nil)
         (format-clauses
          (loop :for key :in keys
             :for obj :in clause-body-objs
             :append
             (if (eq key default-symb)
                 (error "Varjo Bug: switch default not implemented") ;; {TODO}
                 (list key
                       (append (mapcat #'indent (to-block obj))
                               (indent (current-line (end-line obj))))))
             :into result
             :finally (return (append result default-clause)))))
    (format nil "~a~%switch (~a) {~{~%    case ~a:~%~{~a~^~%~}~%    break;~%~}}"
            (or (to-block test-obj) "")
            (current-line test-obj)
            format-clauses)))

(defun qualify (obj &rest qualifiers)
  (%qualify obj qualifiers))

(defun %qualify (obj qualifiers)
  (copy-code obj :current-line (format nil "~(~{~a ~}~)~a"
                                       (string-downcase (string qualifiers))
                                       (current-line obj))
             :multi-vals nil
             :place-tree nil))

(defun prefix-type-to-string (type line-string &optional qualifiers storage-qual)
  (let* ((line (cond ((typep type 'v-type) (format nil "~a ~a"
                                                   (v-glsl-string type)
                                                   line-string))
                     (t (error "dont know how to add the type here")))))
    (if qualifiers
        (format nil "~{~a~^ ~}~@[~( ~a~)~] ~a"
                (loop :for q :in qualifiers :collect (string-downcase (string q)))
                storage-qual
                line)
        (format nil "~@[~(~a ~)~]~a" storage-qual line))))

(defun prefix-type-declaration (code-obj &optional qualifiers storage-qual)
  (prefix-type-to-string (code-type code-obj) (current-line code-obj) qualifiers
                         storage-qual))

(defun gen-out-var-string (glsl-name type qualifiers &optional layout)
  (when (typep type 'v-none)
    (error 'none-type-in-out-vars :glsl-name glsl-name))
  (format nil "~@[layout(location = ~a) ~]out ~a;" layout
          (prefix-type-to-string type glsl-name qualifiers)))

(defun gen-in-var-string (glsl-name type qualifiers &optional layout)
  (format nil "~@[layout(location = ~a) ~]in ~a;" layout
          (prefix-type-to-string type glsl-name qualifiers)))

(defun gen-uniform-decl-string (glsl-name type qualifiers)
  (declare (ignore qualifiers))
  (format nil "uniform ~a;" (prefix-type-to-string type glsl-name)))

(defun gen-geom-primtive-string (primitive)
  (format nil "layout (~a) in;" (glsl-string primitive)))

(defun gen-shader-string (post-proc-obj)
  (with-slots (env) post-proc-obj
    (format nil "#version ~a~%~{~%~{~a~%~}~}"
            (get-version-from-context env)
            (loop :for part :in
               (list (used-types post-proc-obj)
                     (in-declarations post-proc-obj)
                     (gen-in-block post-proc-obj)
                     (out-declarations post-proc-obj)
                     (gen-out-block post-proc-obj)
                     (remove-empty
                      (append
                       (mapcar #'%glsl-decl (uniforms post-proc-obj))
                       (mapcar #'%glsl-decl (stemcells post-proc-obj))))
                     (signatures env)
                     (let* ((funcs (all-functions post-proc-obj))
                            (code (remove nil (mapcar #'glsl-code funcs))))
                       (reverse code)))
               :if part :collect part))))

(defmethod out-block-name-for ((stage stage))
  (let ((name (extract-stage-type stage)))
    (assert (not (eq name :fragment)) ()
            "Fragment shaders cannot have 'out' interface blocks")
    (symb :from_ name)))

(defmethod in-block-name-for ((stage stage))
  (assert (not (eq (extract-stage-type stage) :vertex)) ()
          "Vertex shaders cannot have 'in' interface blocks")
  (let ((prev (previous-stage stage)))
    (if prev
        (symb :from_ (extract-stage-type prev))
        :in_block)))

(defun block-name-string (block-name)
  (format nil "_~a_" block-name))

(defmethod out-block-name-for ((pp post-compile-process))
  (out-block-name-for (stage pp)))

(defmethod in-block-name-for ((pp post-compile-process))
  (in-block-name-for (stage pp)))

(defun requires-out-interface-block (post-proc-obj)
  (not (eq (extract-stage-type post-proc-obj) :fragment)))

(defun requires-in-interface-block (post-proc-obj)
  (not (eq (extract-stage-type post-proc-obj) :vertex)))

(defun gen-out-block (post-proc-obj)
  (let* ((out-vars (out-vars post-proc-obj))
         (out-vars (if (eq (extract-stage-type post-proc-obj) :vertex)
                       (rest out-vars)
                       out-vars)))
    (if (requires-out-interface-block post-proc-obj)
        (when out-vars
          (list (write-interface-block
                 :out (out-block-name-for post-proc-obj)
                 out-vars)))
        (mapcar #'%glsl-decl out-vars))))

(defparameter *in-block-instance-name*
  "in")

(defun gen-in-block (post-proc-obj)
  (if (requires-in-interface-block post-proc-obj)
      (when (in-args post-proc-obj)
        (let* ((is-geom (stage-is post-proc-obj :geometry))
               (len (when is-geom
                      (first (v-dimensions
                              (v-type-of (first (in-args post-proc-obj))))))))
          (list (write-interface-block
                 :in (in-block-name-for post-proc-obj)
                 (in-args post-proc-obj)
                 :instance-name (when is-geom *in-block-instance-name*)
                 :length len))))
      (mapcar #'%glsl-decl (in-args post-proc-obj))))

;;----------------------------------------------------------------------

;; storage_qualifier block_name
;; {
;;   <define members here>
;; } instance_name;

(defun write-interface-block (storage-qualifier block-name out-vars
                              &key layout instance-name length)
  (assert (not (and length (null instance-name))))
  (format nil "~@[layout(~a) ~]~a ~a~%{~%~{    ~a~%~}}~a;"
          layout
          (string-downcase (symbol-name storage-qualifier))
          (block-name-string block-name)
          (mapcar #'%glsl-decl out-vars)
          (if instance-name
              (format nil " ~a~@[[~a]~]" instance-name length)
              "")))

(defun write-ubo-block (storage-qualifier block-name slots
                              &optional (layout "std140"))
  (format nil "~@[layout(~a) ~]~a ~a~%{~%~{~a~%~}} ~a;"
          layout
          (string-downcase (symbol-name storage-qualifier))
          (format nil "_UBO_~a" block-name)
          (mapcar #'gen-interface-block-slot-string slots)
          block-name))

(defun gen-interface-block-slot-string (slot)
  (destructuring-bind (slot-name slot-type &key accessor) slot
    (let ((name (or accessor slot-name))
          (type-obj slot-type))
      (format nil "    ~{~a ~}~a"
              ;;(loop :for q :in qualifiers :collect (string-downcase (string q)))
              nil
              (format nil "~a ~a;"
                      (v-glsl-string type-obj)
                      (safe-glsl-name-string name))))))

;;----------------------------------------------------------------------

(defmethod indent ((input string) &optional (count 4))
  (let ((spaces (make-array count :element-type 'character
                             :initial-element #\space)))
    (mapcar #'(lambda (x) (format nil "~a~a" spaces x))
            (split-sequence:split-sequence #\newline input))))

(defun indent-for-block (line/s)
  (format nil "~@[~%~{~a~^~%~}~]"
          (remove-empty (mapcat #'indent (listify line/s)))))

;;----------------------------------------------------------------------

(defun cast-string (type code-obj)
  (when (current-line code-obj)
    (format nil "~a(~a)"
            (v-glsl-string type)
            (current-line code-obj))))

;;----------------------------------------------------------------------

(defun gen-array-literal-string (elements element-type env)
  (labels ((cast (x)
             (if (v-type-eq (code-type x) element-type)
                 x
                 (cast-code x element-type env))))
    (let ((elements (mapcar #'cast elements)))
      (format nil "~a[~a](~{~a~^, ~})"
              (v-glsl-string element-type) (length elements)
              (mapcar #'current-line elements)))))
