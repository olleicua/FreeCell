(def represent-rank (# (n)
                       (or (get { 0 "A"
                                  9 "T"
                                  10 "J"
                                  11 "Q"
                                  12 "K" } n)
                           (+1 n))))

;; Card
(def Card { new (# (rank suit)
                      (let (card (new this))
                        (set card.rank rank)
                        (set card.suit suit)
                        card))
            
            precedes? (# (other)
                         (and (= other.suit this.suit)
                              (= (+1 other.rank) this.rank)))
            
            follows? (# (other)
                         (and (= other.suit this.suit)
                              (= (--1 other.rank) this.rank)))
            
            toString (# ()
                        (format "~~~~"
                                [ (represent-rank this.rank) this.suit ] )) } )

;; Deck
(def Deck { new (# ()
                   (let (deck (new this))
                     (set deck.list
                          (flatten
                           (map (range 13)
                                (# (rank)
                                   (map [ "♣" "♢" "♡" "♠" ]
                                        (# (suit) (Card.new rank suit)))))))
                     deck))
            
            shuffle (# () 
                       (let (i (size this.list)
                             j undefined
                             x undefined)
                         (while (>0 i)
                           (set j (random-integer  i))
                           (-- i)
                           (set x (get this.list i))
                           (set this.list i (get this.list j))
                           (set this.list j x))))
            
            draw (# (n)
                    (let (_this this)
                      (if (nil? n) (this.list.pop)
                        (map (range n) (# () (_this.list.pop))))))
            
            toString (# () ((map this.list string).join " , ")) } )

(set module.exports { Deck Deck Card Card } )