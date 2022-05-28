(tset package :path (.. "./?.lua;../?.lua;" package.path))

;; requiring love-api here will return you the mock structure when working
;; from the repl and the real love2d api when executing in a real love2d env
(local love (require :love-api))

(fn love.draw []
  (love.graphics.setColor 1.0 0.5 0.5 1.0)
  (love.graphics.clear)
  (love.graphics.setColor 0.7 0.6 0.4 1.0))

(fn love.update [dt])
