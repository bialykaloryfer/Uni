#lang plait

(define-type-alias Value Number)

;; == Abstract syntax

(define-type d-type
  (funE [name : Symbol] [par : (Listof Symbol)] [e : e-type]))

(define-type e-type
  (numE [n : Number])
  (varE [x : Symbol])
  (opE [e1 : e-type] [o : Op] [e2 : e-type])
  (ifzE [e1 : e-type] [e2 : e-type] [e3 : e-type])
  (letE [x : Symbol] [e1 : e-type] [e2 : e-type])
  (appE [f : Symbol] [e : (Listof e-type)]))

(define-type p-type
  (dfE [x : (Listof d-type)] [e : e-type]))

(define-type Op
  (add) (sub) (mult) (my-leq))

;; == Parser - Procedures

(define (sixth list)
  (list-ref list 5))

(define (fifth list)
  (list-ref list 4))

(define (used-name? name list-of-used)
  (member name list-of-used))

(define (any-common-element? new-names used-names)
  (cond [(empty? new-names) #f]
        [(used-name? (first new-names) used-names) #t]
        [else (any-common-element? (rest new-names) (cons (first new-names) used-names))]))


;; == Parsers

(define (p-type-parse [s : S-Exp])
  (cond
    [(s-exp-match? `{define {ANY ...} for ANY} s)
     (let ([list-of-names (s-exp->list (second (s-exp->list s)))])
       (if (any-common-element? list-of-names '())
           (error 'define "name repetition")
           (dfE
            (map d-type-parse list-of-names)
            (e-type-parse (fourth (s-exp->list s))))))]
    [else (error 'p-type-parse "syntax error")]))

(define (e-type-parse [s : S-Exp])
  (cond
    [(s-exp-match? `NUMBER s)
     (numE
      (s-exp->number s))]
    [(s-exp-match? `SYMBOL s)
     (varE
      (s-exp->symbol s))]
    [(s-exp-match? `{ANY SYMBOL ANY} s)
     (opE
      (e-type-parse (first (s-exp->list s)))
      (op-type-parse (second (s-exp->list s)))
      (e-type-parse (third (s-exp->list s))))]
    [(s-exp-match? `{ifz ANY then ANY else ANY} s)
     (ifzE
      (e-type-parse (second (s-exp->list s)))
      (e-type-parse (fourth (s-exp->list s)))
      (e-type-parse (sixth (s-exp->list s))))]
    [(s-exp-match? `{let SYMBOL be ANY in ANY} s)
     (letE
      (s-exp->symbol (second (s-exp->list s)))
      (e-type-parse (fourth (s-exp->list s)))
      (e-type-parse (sixth (s-exp->list s))))]
    [(s-exp-match? `{SYMBOL {ANY ...}} s)
     (appE
      (s-exp->symbol (first (s-exp->list s)))
       (map e-type-parse (s-exp->list (second (s-exp->list s)))))]
    [else (error 'e-type-parse "syntax error")]))

(define (d-type-parse [s : S-Exp])
  (cond
     [(s-exp-match? `[fun SYMBOL {ANY ...} = ANY] s)
      (let ([list-of-names (s-exp->list (third (s-exp->list s)))])
        (if (any-common-element? list-of-names '())
            (error 'fun "name repetition")
            (funE
             (s-exp->symbol (second (s-exp->list s)))
             (map s-exp->symbol list-of-names)
             (e-type-parse (fifth (s-exp->list s))))))]
    [else (error 'd-type-parse "syntax error")]))


(define (op-type-parse [op : S-Exp])
  [cond 
    [(s-exp-match? `+ op) (add)]
    [(s-exp-match? `- op) (sub)]
    [(s-exp-match? `* op) (mult)]
    [(s-exp-match? `<= op) (my-leq)]
    [else (error 'op "operator is not defined")]])

;; == Env

(define-type-alias Env (Listof Binding))

(define mt-env empty)

(define-type Def
  (numD [v : Value])
  (funD [var : (Listof Symbol)] [e : e-type]))

(define-type Binding
  (bind [name : Symbol]
        [data : Def]))

(define (extend-env [env : Env] [x : Symbol] [t : Def]) : Env
  (cons (bind x t) env))

(define (f-list-extend-env [env : Env] [fun : (Listof d-type)])
  (if (empty? fun)
      env
      (f-list-extend-env
       (extend-env env (funE-name (first fun))
                   (funD (funE-par (first fun))
                         (funE-e (first fun))))
       (rest fun))))

(define (var-list-extend-env [env : Env] [val-list : (Listof e-type)] [var-list : (Listof Symbol)]) : Env
  (if (empty? val-list)
      env
     (var-list-extend-env
                     (extend-env env (first var-list) (numD (e-type-eval (first val-list) env)))
                     (rest val-list)
                     (rest var-list ))))
            
(define (lookup-env [n : Symbol] [env : Env]) : Def
  (type-case (Listof Binding) env
    [empty (error 'lookup "unbound variable")]
    [(cons b rst-env) (cond
                        [(eq? n (bind-name b))
                         (bind-data b)]
                        [else (lookup-env n rst-env)])]))

;; == Evaluator - Procedures

(define (fun-my-leq el-1 el-2)
  (if (<= el-1 el-2)
      0
      1))

(define (op->proc [op : Op])
  (type-case Op op
    [(add) +]
    [(sub) -]
    [(mult) *]
    [(my-leq) fun-my-leq]))

;; == Evaluator

 (define (e-type-eval [ s : e-type] [env : Env]) : Value
    (type-case e-type s
      [(numE n) n]
      [(varE x) (numD-v (lookup-env x env))]
      [(opE e1 o e2) ((op->proc o) (e-type-eval e1 env)  (e-type-eval e2 env))]
      [(ifzE e1 e2 e3) 
       (if (equal? (e-type-eval e1 env) 0)
           (e-type-eval e2 env)
           (e-type-eval e3 env))]
      [(letE x e1 e2)
       (e-type-eval e2 (extend-env env x (numD (e-type-eval e1 env))))]
      [(appE f e)
       (e-type-eval
        (funD-e (lookup-env f env))
             (var-list-extend-env
              env
              e
              (funD-var (lookup-env f env))))]
      ))

(define (eval [s : p-type] [env : Env]) : Value
  (e-type-eval (dfE-e s) (f-list-extend-env env (dfE-x s))))

(define (run [s : S-Exp]) : Value
  (eval (p-type-parse s) mt-env))

     
    
    
