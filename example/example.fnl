(tset package :path (.. "./?.lua;../?.lua;" package.path))

;; requiring love-api here will return you the mock structure when working
;; from the repl and the real love2d api when executing in a real love2d env
(local love (require :love-api))

(fn love.draw []
  (love.graphics.clear 1.0 0.5 0.5 1.0)
  (love.graphics.setColor 0.7 0.6 0.7 1.0)
  (let [wx (-> (love.graphics.getWidth)
               (/ 2))
        wy (-> (love.graphics.getHeight)
               (/ 2))]
    (love.graphics.circle :fill wx wy 100)))

(fn love.update [dt]
  (when (love.keyboard.isDown "q")
   (love.event.quit)))
