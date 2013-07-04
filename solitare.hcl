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
		  (if (isnt 2 (size m)) (throw "Invalid move")
			(let (from (first m)
				  to (second m))
			  
			  (var from-card
				   (cond
					((contains? stacks from)
					 (last (nth this.stacks (stacks.indexOf from))))
					((contains? cells from)
					 (nth this.cells (cells.indexOf from)))
					(true (throw "Invalid move"))))
			  
			  (when (nil? from-card) (throw "Invalid move"))
			  
			  (cond
			   ((contains? stacks to)
				(if (or (zero? (size (nth this.stacks (stacks.indexOf to))))
						((last (nth this.stacks (stacks.indexOf to))).precedes?
						 from-card))
					(begin
					 ((nth this.stacks (stacks.indexOf to)).push from-card)
					 (cond
					  ((contains? stacks from)
					   ((nth this.stacks (stacks.indexOf from)).pop))
					  ((contains? cells from)
					   (set this.cells (cells.indexOf from) null))))
				  (throw "Invalid move")))
			   ((contains? cells to)
				(if (nil? (nth this.cells (cells.indexOf to)))
					(begin
					 (set this.cells (cells.indexOf to) from-card)
					 (cond
					  ((contains? stacks from)
					   ((nth this.stacks (stacks.indexOf from)).pop))
					  ((contains? cells from)
					   (set this.cells (cells.indexOf from) null))))
				  (throw "Invalid move")))
			   (true (throw "Invalid move")))))) } )
	   