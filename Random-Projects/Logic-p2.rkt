#lang racket
(require data/heap)
(provide sim? wire?
         (contract-out
          [make-sim        (-> sim?)]
          [sim-wait!       (-> sim? positive? void?)]
          [sim-time        (-> sim? real?)]
          [sim-add-action! (-> sim? positive? (-> any/c) void?)]

          [make-wire       (-> sim? wire?)]
          [wire-on-change! (-> wire? (-> any/c) void?)]
          [wire-value      (-> wire? boolean?)]
          [wire-set!       (-> wire? boolean? void?)]

          [bus-value (-> (listof wire?) natural?)]
          [bus-set!  (-> (listof wire?) natural? void?)]

          [gate-not  (-> wire? wire? void?)]
          [gate-and  (-> wire? wire? wire? void?)]
          [gate-nand (-> wire? wire? wire? void?)]
          [gate-or   (-> wire? wire? wire? void?)]
          [gate-nor  (-> wire? wire? wire? void?)]
          [gate-xor  (-> wire? wire? wire? void?)]

          [wire-not  (-> wire? wire?)]
          [wire-and  (-> wire? wire? wire?)]
          [wire-nand (-> wire? wire? wire?)]
          [wire-or   (-> wire? wire? wire?)]
          [wire-nor  (-> wire? wire? wire?)]
          [wire-xor  (-> wire? wire? wire?)]

          [flip-flop (-> wire? wire? wire? void?)]))

;; --------- structures

(struct sim ([time #:mutable] [queue #:mutable]))
(struct wire ([signal #:mutable] [sim #:mutable] [actions #:mutable]))

;; --------- additional procedures

(define (call-procedures procedures-list)
  (if (empty? procedures-list)
      (void)
      (begin
        ((car procedures-list))
        (call-procedures (cdr procedures-list)))))

(define (cons<=? cons_1 cons_2)
  (<= (car cons_1) (car cons_2)))

;; --------- sim

(define (make-sim)
  (sim 0 (make-heap cons<=?)))


(define (sim-add-action! sim-el delay-arg action)
  (heap-add! (sim-queue sim-el) (cons (+ (sim-time sim-el) delay-arg) action)))


(define (sim-wait! sim-arg time-arg)

  (define end-time (+ time-arg (sim-time sim-arg)))


  (define (rec-sim-wait sim-arg time-arg)
    (let [(active-queue (sim-queue sim-arg))]

      (if (equal? (heap-count active-queue) 0)
          (set-sim-time! sim-arg end-time)
          
          (if (<= (car (heap-min active-queue)) end-time)
            (begin
              (let ([heap-top-el (heap-min active-queue)])
              (set-sim-time! sim-arg (car (heap-min active-queue)))
              ((cdr heap-top-el))
              (heap-remove-min! active-queue)
              (rec-sim-wait sim-arg time-arg)))

            (set-sim-time! sim-arg end-time)))))

  (rec-sim-wait sim-arg end-time))
   
; --------- wires

(define (make-wire sim-arg)
  (wire #f sim-arg '()))

(define (wire-on-change! wire-arg action)
  (let ([wire-arg-actions (wire-actions wire-arg)]) 
    (begin
    (set-wire-actions! wire-arg (cons action wire-arg-actions))
    (action))))
  
(define (wire-value wire-arg)
  (wire-signal wire-arg))

(define (wire-set! wire-arg signal-arg)
  (if (equal? (wire-value wire-arg) signal-arg)
      (void)
      (begin
        (set-wire-signal! wire-arg signal-arg)
        (call-procedures (wire-actions wire-arg)))))
    


;; --------- bus

(define (bus-set! wires value)
  (match wires
    ['() (void)]
    [(cons w wires)
     (begin
       (wire-set! w (= (modulo value 2) 1))
       (bus-set! wires (quotient value 2)))]))

(define (bus-value ws)
  (foldr (lambda (w value) (+ (if (wire-value w) 1 0) (* 2 value)))
         0
         ws))


;; --------- gates


(define (gate-not output input-1)
  (define gate-delay 1)
  
  (define (not-action)
      (sim-add-action! (wire-sim output)
                       gate-delay
                       (lambda () (wire-set! output (not (wire-value input-1))))
                       ))

  (wire-on-change! input-1 not-action))

;; == 

(define (gate-and output input-1 input-2)
  (define gate-delay 1)
  
  (define (and-action)
      (sim-add-action! (wire-sim output)
                       gate-delay
                       (lambda () (wire-set! output (and (wire-value input-1) (wire-value input-2))))
                       ))

  (wire-on-change! input-1 and-action)
  (wire-on-change! input-2 and-action))

;; ==

(define (gate-nand output input-1 input-2)
  (define gate-delay 1)

  (define (nand-action)
      (sim-add-action! (wire-sim output)
                       gate-delay
                       (lambda () (wire-set! output (nand (wire-value input-1) (wire-value input-2))))
                       ))
 

  (wire-on-change! input-1 nand-action)
  (wire-on-change! input-2 nand-action))

;; ==

(define (gate-or output input-1 input-2)
  (define gate-delay 1)
  
  (define (or-action)
      (sim-add-action! (wire-sim output)
                       gate-delay
                       (lambda () (wire-set! output (or (wire-value input-1) (wire-value input-2))))
                       ))
 
  (wire-on-change! input-1 or-action)
  (wire-on-change! input-2 or-action))

;; ==

(define (gate-nor output input-1 input-2)
  (define gate-delay 1)
  
  (define (nor-action)
      (sim-add-action! (wire-sim output)
                       gate-delay
                       (lambda () (wire-set! output (nor (wire-value input-1) (wire-value input-2))))
                       ))

  (wire-on-change! input-1 nor-action)
  (wire-on-change! input-2 nor-action))

;; ==

(define (gate-xor output input-1 input-2)
  (define gate-delay 2)
  
  (define (xor-action)
      (sim-add-action! (wire-sim output)
                       gate-delay
                       (lambda () (wire-set! output (xor (wire-value input-1) (wire-value input-2))))
                       ))

  (wire-on-change! input-1 xor-action)
  (wire-on-change! input-2 xor-action))

;; --------- wires/gates

(define (wire-not wire-arg)
  (define output (make-wire (wire-sim wire-arg)))
  (gate-not output wire-arg)
  output)

(define (wire-and wire-arg-1 wire-arg-2)
  (define output (make-wire (wire-sim wire-arg-1)))
  (gate-and output wire-arg-1 wire-arg-2)
  output)

(define (wire-nand wire-arg-1 wire-arg-2)
  (define output (make-wire (wire-sim wire-arg-1)))
  (gate-nand output wire-arg-1 wire-arg-2)
  output)

(define (wire-or wire-arg-1 wire-arg-2)
  (define output (make-wire (wire-sim wire-arg-1)))
  (gate-or output wire-arg-1 wire-arg-2)
  output)

(define (wire-nor wire-arg-1 wire-arg-2)
  (define output (make-wire (wire-sim wire-arg-1)))
  (gate-nor output wire-arg-1 wire-arg-2)
  output)

(define (wire-xor wire-arg-1 wire-arg-2)
  (define output (make-wire (wire-sim wire-arg-1)))
  (gate-xor output wire-arg-1 wire-arg-2)
  output)

;; --------- flip-flop

(define (flip-flop out clk data)
  (define sim (wire-sim data))
  (define w1  (make-wire sim))
  (define w2  (make-wire sim))
  (define w3  (wire-nand (wire-and w1 clk) w2))
  (gate-nand w1 clk (wire-nand w2 w1))
  (gate-nand w2 w3 data)
  (gate-nand out w1 (wire-nand out w3)))
