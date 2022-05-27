(tset package :path (.. "./?.lua;../?.lua;" package.path))
(local fennel (require :fennel))

(fn create-arguments-list [args-desc]
  (if (= args-desc nil) [] (icollect [_ argd (ipairs args-desc)]
                             argd.name)))

(fn get-api-table []
  (let [lapi (require :love-api.love_api)]
    (collect [_ module (ipairs lapi.modules)]
      (if (not= module.name nil)
          (values module.name
                  (collect [_ fn-desc (ipairs module.functions)]
                    (values fn-desc.name
                            {:name fn-desc.name
                             :doc (-> fn-desc.description
                                      (: :gsub "\"" "'")
                                      (: :gsub "\\" "/"))
                             :args (create-arguments-list (-> fn-desc
                                                              (. :variants)
                                                              (. 1)
                                                              (. :arguments)))})))))))

(fn transform-arg-list [args]
  (icollect [_ arg (ipairs args)]
    (fennel.sym arg)))

(fn get-function-string-rep [module fn-name fn-table]
  (let [t-args (-> fn-table
                   (. :args)
                   (transform-arg-list)
                   (fennel.view)
                   (: :gsub "," ""))]
    (.. "(fn love." module "." fn-name " " t-args "\n\"" (. fn-table :doc) "\"
{})")))

(fn get-full-api-string []
  (var output "(var love {})\n")
  (each [module v (pairs (get-api-table))]
    (set output (.. output "(tset love :" module " {})\n"))
    (each [func desc (pairs v)]
      (set output (.. output (get-function-string-rep module func desc) "\n"))))
  (set output (.. output :love))
  output)

(fn write-api-to-file [fname]
  (with-open [fout (io.open fname :w)]
    (fout:write (get-full-api-string))))

(write-api-to-file :love-api.fnl)
