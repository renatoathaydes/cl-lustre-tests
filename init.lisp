(handler-case (require "asdf")
  (error (condition)
    (let ((bundled-asdf
            (merge-pathnames
             #+(or win32 windows mswindows) #p"AppData/Local/ocicl/asdf.lisp"
             #-(or win32 windows mswindows) #p".local/share/ocicl/asdf.lisp"
             (user-homedir-pathname))))
      (if (probe-file bundled-asdf)
          (load bundled-asdf)
          (error condition)))))

#-ocicl
(let ((runtime
        (merge-pathnames
         (if (uiop:os-windows-p)
             #p"AppData/Local/ocicl/ocicl-runtime.lisp"
             #p".local/share/ocicl/ocicl-runtime.lisp")
         (user-homedir-pathname))))
  (when (probe-file runtime)
    (load runtime)))

(asdf:initialize-source-registry
  (list :source-registry
        (list :directory (uiop:getcwd))
        :inherit-configuration))
