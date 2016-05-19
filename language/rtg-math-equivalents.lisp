(in-package :varjo)

(add-equivalent-name 'cl:length 'rtg-math.vectors:length)

(v-defun rtg-math.vectors:x (a) "~a.x" (v-bvec2) v-bool)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-bvec3) v-bool)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-bvec4) v-bool)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-dvec2) v-double)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-dvec3) v-double)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-dvec4) v-double)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-ivec2) v-int)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-ivec3) v-int)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-ivec4) v-int)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-uvec2) v-uint)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-uvec3) v-uint)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-uvec4) v-uint)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-vec2) v-float)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-vec3) v-float)
(v-defun rtg-math.vectors:x (a) "~a.x" (v-vec4) v-float)

(v-defun rtg-math.vectors:y (a) "~a.y" (v-bvec2) v-bool)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-bvec3) v-bool)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-bvec4) v-bool)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-dvec2) v-double)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-dvec3) v-double)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-dvec4) v-double)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-ivec2) v-int)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-ivec3) v-int)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-ivec4) v-int)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-uvec2) v-uint)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-uvec3) v-uint)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-uvec4) v-uint)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-vec2) v-float)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-vec3) v-float)
(v-defun rtg-math.vectors:y (a) "~a.y" (v-vec4) v-float)

(v-defun rtg-math.vectors:z (a) "~a.z" (v-vec3)  v-float)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-bvec3) v-bool)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-ivec3) v-int)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-uvec3) v-uint)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-dvec3) v-double)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-vec4)  v-float)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-bvec4) v-bool)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-ivec4) v-int)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-uvec4) v-uint)
(v-defun rtg-math.vectors:z (a) "~a.z" (v-dvec4) v-double)

(v-defun rtg-math.vectors:w (a) "~a.w" (v-vec4) v-float)
(v-defun rtg-math.vectors:w (a) "~a.w" (v-bvec4) v-bool)
(v-defun rtg-math.vectors:w (a) "~a.w" (v-ivec4) v-int)
(v-defun rtg-math.vectors:w (a) "~a.w" (v-uvec4) v-uint)
(v-defun rtg-math.vectors:w (a) "~a.w" (v-dvec4) v-double)
