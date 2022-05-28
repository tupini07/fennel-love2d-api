(local fennel (require :fennel))
(local VERSION :1.0.0)

(tset package :path (.. "./?.lua;../?.lua;" package.path))

(fn create-arguments-list [args-desc]
  (if (= args-desc nil) [] (icollect [_ argd (ipairs args-desc)]
                             argd.name)))

(fn table-imerge [tb1 tb2]
  (var res {})
  (each [_ e1 (ipairs tb1)]
    (table.insert res e1))
  (each [_ e2 (ipairs tb2)]
    (table.insert res e2))
  res)

(fn get-api-table []
  (let [lapi (require :love-api.love_api)]
    {:functions (icollect [_ callback (ipairs (table-imerge lapi.callbacks lapi.functions))]
                  {:name callback.name
                   :doc (-> callback.description
                            (.. "\n\nhttps://love2d.org/wiki/love."
                                callback.name))
                   :args (create-arguments-list
                          (-> callback.variants
                             (. 1)
                             (. :arguments)))})
     :modules (collect [_ module (ipairs lapi.modules)]
                (if (not= module.name nil)
                    (values module.name
                            (collect [_ fn-desc (ipairs module.functions)]
                              (values fn-desc.name
                                      {:name fn-desc.name
                                       :doc (-> fn-desc.description
                                                (: :gsub "\"" "'")
                                                (: :gsub "\\" "/")
                                                (.. "\n\nhttps://love2d.org/wiki/love."
                                                    module.name "." fn-desc.name))
                                       :args (create-arguments-list (-> fn-desc
                                                                        (. :variants)
                                                                        (. 1)
                                                                        (. :arguments)))})))))}))

(fn transform-arg-list [args]
  (if (= nil args)
    []
    (icollect [_ arg (ipairs args)]
      (-> arg
          (: :gsub "length" "_length")
          (#$) ;; extract first return value from gsub result
          (fennel.sym)))))

(fn get-function-string-rep [ fn-qualifier fn-table]
  (let [t-args (-> fn-table
                   (. :args)
                   (transform-arg-list)
                   (fennel.view)
                   (: :gsub "," ""))]
    (.. "(fn love." fn-qualifier " " t-args "\n\"" (. fn-table :doc)
        "\"\n {})")))

(fn get-full-api-string []
  (let [love2d-version (. (require :love-api.love_api) :version)]
    (var output (.. "(var love { :__generator-version \"" VERSION "\" :version \""
                    love2d-version "\" })\n"))
    (let [api-table (get-api-table)]
     (each [_ function (ipairs api-table.functions)]
      (set output (.. output (get-function-string-rep function.name function) "\n")))
     (each [module v (pairs api-table.modules)]
       (set output (.. output "(tset love :" module " {})\n"))
       (each [func desc (pairs v)]
         (set output (.. output (get-function-string-rep (.. module "." func) desc) "\n")))))
    ;; finally add 'smart' module return that returns mock functions if we're not in a love2d
    ;; execution env, or returns the global love variable otherwise
    (set output (.. output "(if (not= nil _G.love) _G.love love)"))
    output))

(fn write-api-to-file [fname]
  (with-open [fout (io.open fname :w)]
    (fout:write (get-full-api-string))))

(write-api-to-file :love-api.fnl)
