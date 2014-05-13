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
                       (if (and (not (empty? move))
                                (= 0 ((string "quit").indexOf move)))
                           (begin
                            (console.log "BYE :D")
                            (process.exit))
                         (begin
                          (attempt
                           (try (game.move move)
                                (game.auto-fill)
                                (game.print)
                                (cond
                                 ((game.won?)
                                  (begin
                                   (console.log "CONGRATULATIONS YOU WON!")
                                   (process.exit)))
                                 ((empty? (game.legal-moves))
                                  (begin
                                   (console.log "GAME OVER YOU LOSE!")
                                   (process.exit)))
                                 (true (nop))))
                           (catch e
                             (console.log e.message)))
                          (process.stdout.write prompt))))))
