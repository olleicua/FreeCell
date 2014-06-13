(def game (load (compile "./solitare.hcl")))
(def prompt " > ")
(def help-prompt "  Type `help` for more info.")
(def help-message
     ([ "  Type the letter above the card you would like"
        "  to move followed by the letter above the place"
        "  you would like to move it to."
        "  Type `quit` to exit the game."
        "  Type `help` to display this message."].join "\n"))

(def process-move
     (# (move)
        (attempt
         (try (game.move move)
              (game.auto-fill)
              (game.print)
              (cond
               ((game.won?)
                (begin
                 (console.log "   CONGRATULATIONS YOU WON!")
                 (process.exit)))
               ((empty? (game.legal-moves))
                (begin
                 (console.log "   GAME OVER YOU LOSE!")
                 (process.exit)))
               (true (nop))))
         (catch e
           (console.log (cat "  " e.message "\n" help-prompt))))))

(game.auto-fill)
(game.print)
(process.stdout.write (cat "  Welcome to FreeCell!" "\n" help-prompt "\n" prompt))

(process.stdin.resume)
(process.stdin.setEncoding "utf8")

(process.stdin.on "data"
                  (# (input)
                     (let (move (input.trim))
                       (cond
                        ((= move "help") (process.stdout.write (cat help-message "\n" prompt)))
                        ((and (not (empty? move))
                                (= 0 ((string "quit").indexOf move)))
                         (begin
                            (console.log "   BYE :D")
                            (process.exit)))
                        (true (begin
                               (process-move move)
                               (process.stdout.write prompt)))))))
