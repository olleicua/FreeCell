(def game (load (compile "./solitare.hcl")))

(game.auto-fill)
(game.print)

(def prompt "> ")
(process.stdout.write prompt)

(process.stdin.resume)
(process.stdin.setEncoding "utf8")

(process.stdin.on "data"
                  (# (input)
                     (let (move (input.trim))
                       (attempt
                        (try (game.move move)
                             (game.auto-fill)
                             (game.print))
                        (catch e
                          (console.log "Invalid move")))
                       (process.stdout.write prompt))))