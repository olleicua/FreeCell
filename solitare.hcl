(def cards (load (compile "./cards.hcl")))

(var deck (cards.Deck.new))
(deck.shuffle)

(def print-card (# (card format-string)
                   (process.stdout.write
                    (format (or format-string "~~")
                            [(or card "  ")]))))

(def stacks "abcdefgh")
(def cells "ijklmnop")

(set module.exports
     { stacks (map (range 8) (# () (deck.draw 6)))
       cells (deck.draw 4)
       foundations { "♣" null
                     "♢" null
                     "♡" null
                     "♠" null }
       
       select-card
       (# (letter)
          (cond
           ((contains? stacks letter)
            (last (nth this.stacks (stacks.indexOf letter))))
           ((contains? cells letter)
            (nth this.cells (cells.indexOf letter)))
           (true (throw (format "space `~~` does not exist" [ letter ] )))))
       
       remove-card
       (# (letter)
          (cond
           ((contains? stacks letter)
            ((nth this.stacks (stacks.indexOf letter)).pop))
           ((contains? cells letter)
            (set this.cells (cells.indexOf letter) null))
           (true (throw (format "space `~~` does not exist" [ letter ] )))))
       
       card-allowed?
       (# (card space)
          (cond
           ((contains? stacks space)
            (or (zero? (size (nth this.stacks (stacks.indexOf space))))
                ((this.select-card space).precedes? card)))
           ((contains? cells space)
            (nil? (this.select-card space)))
           (true (throw (format "space `~~` does not exist" [ space ] )))))
       
       place-card
       (# (card space)
          (cond
           ((contains? stacks space)
            ((nth this.stacks (stacks.indexOf space)).push card))
           ((contains? cells space)
            (set this.cells (cells.indexOf space) card))
           (true (throw (format "space `~~` does not exist" [ space ] )))))
       
       print
       (# ()
          (times (char 8)
                 (process.stdout.write
                  (cat (String.fromCharCode (+ 97 char)) "   ")))
          (process.stdout.write "\n")
          
          (times (row (Math.max.apply this (pluck this.stacks "length")))
                 (times (col 8)
                        (print-card (nth (nth this.stacks col) row)
                                    "~~  "))
                 (process.stdout.write "\n"))
          (process.stdout.write "\n")
          
          (times (char 8)
                 (process.stdout.write
                  (cat (String.fromCharCode (+ 105 char)) "   ")))
          (process.stdout.write "\n")
          
          (times (col 8)
                 (print-card (nth this.cells col) "~~  "))
          (process.stdout.write "\n\n")
          
          (for (suit [ "♣" "♢" "♡" "♠" ] )
               (print-card (get this.foundations suit) "~~  "))
          (process.stdout.write "\n\n"))
       
       
       
       auto-fill
       (# ()
          (var change-made true)
          (while change-made
            (set change-made false)
            (times (col 8)
                   (let (stack-top (last (nth this.stacks col))
                         cell (nth this.cells col))
                     
                     (when (and stack-top
                                (or (=0 stack-top.rank)
                                    (and (get this.foundations stack-top.suit)
                                         (stack-top.precedes?
                                          (get this.foundations stack-top.suit)))))
                       (set this.foundations stack-top.suit stack-top)
                       ((nth this.stacks col).pop)
                       (set change-made true))
                     
                     (when (and cell
                                (or (=0 cell.rank)
                                    (and (get this.foundations cell.suit)
                                         (cell.precedes?
                                          (get this.foundations cell.suit)))))
                       (set this.foundations cell.suit cell)
                       (set this.cells col null)
                       (set change-made true))))))
       
       move
       (# (m)
          (if (isnt 2 (size m)) (throw "move must consist of two characters")
            (let (from (first m)
                  to (second m))
              
              (var from-card (this.select-card from))
              
              (when (nil? from-card)
                (throw (format "no card located at position `~~`" [ from ] )))
              
              (if (this.card-allowed? from-card to)
                  (begin
                   (this.place-card from-card to)
                   (this.remove-card from))
                (throw (format "invalid move `~~`" [ m ] )))))) } )
