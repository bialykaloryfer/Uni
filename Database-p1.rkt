#lang racket

(provide (struct-out column-info)
         (struct-out table)
         (struct-out and-f)
         (struct-out or-f)
         (struct-out not-f)
         (struct-out eq-f)
         (struct-out eq2-f)
         (struct-out lt-f)
         table-insert
         table-project
         table-sort
         table-select
         table-rename
         table-cross-join
         table-natural-join)

(define-struct column-info (name type) #:transparent)

(define-struct table (schema rows) #:transparent)

(define cities
  (table
   (list (column-info 'city    'string)
         (column-info 'country 'string)
         (column-info 'area    'number)
         (column-info 'capital 'boolean))
   (list (list "Wrocław" "Poland"  293 #f)
         (list "Warsaw"  "Poland"  517 #t)
         (list "Poznań"  "Poland"  262 #f)
         (list "Berlin"  "Germany" 892 #t)
         (list "Munich"  "Germany" 310 #f)
         (list "Paris"   "France"  105 #t)
         (list "Rennes"  "France"   50 #f))))

(define countries
  (table
   (list (column-info 'country 'string)
         (column-info 'population 'number))
   (list (list "Poland" 38)
         (list "Germany" 83)
         (list "France" 67)
         (list "Spain" 47))))

(define (empty-table columns) (table columns '()))

; Pomocnicze

(define (name_nr x num)
  (if (empty? x) '()
      (cons (cons (column-info-name (first x)) num) (name_nr (cdr x) (+ 1 num)))))

(define (var_fun key dic)
  (hash-ref dic key))


(define (make_scheme_dic tab)
  (make-hash (name_nr (table-schema tab) 0)))


(define (row_el row cols dic)
  (list-ref row (var_fun (car cols) dic)))




(define (table-insert row tab)

  (define (same-types? type-sym var)
     (cond [(equal? type-sym 'string) (string? var)]
           [(equal? type-sym 'number) (number? var)]
           [(equal? type-sym 'boolean) (boolean? var)]
           [(equal? type-sym 'symbol) (symbol? var)]
           [else #f]))

  (define (if_correct_data row tab)
    (cond[(and (null? row) (null? tab)) #t]
         [(and (not(null? row)) (not(null? tab)))
          (and (same-types? (column-info-type (car  tab)) (car row))
               (if_correct_data (cdr row) (cdr tab)))]
         [else #f]))
  
  (define tab-schema (table-schema tab))
  (if (if_correct_data row tab-schema)
      (table (table-schema tab)(cons row (table-rows tab)))
      (error "error: table-insert - wpisano zle dane")))

  

; Projekcja

(define (table-project cols tab)
  (define headers (table-schema tab))
  (define (headers_num cols headers num)
    (cond [(empty? cols) '()]
          [(empty? headers) '()]
          [(member (column-info-name (car headers)) cols)
           (cons num (headers_num (remove (column-info-name (car headers)) cols) (cdr headers) (+ 1 num)))]
          [else (headers_num cols (cdr headers) (+ 1 num))]))

  (define (rec num_list row num)
    (if (empty? num_list) '()
    (cond [(empty? row) '()]
          [(equal? (car num_list) num)
           (cons (car row) (rec (cdr num_list) (cdr row) (+ 1 num)))]
          [else (rec num_list (cdr row) (+ 1 num))])))

  (define tab-rows (table-rows tab))
  (define headers_num_list (headers_num cols headers 1))
  
  (define (result tab-rows headers_num_list)
    (if (empty? tab-rows) '()
    (cons (rec headers_num_list (car tab-rows) 1) (result (cdr tab-rows) headers_num_list))))

  (define (gen_new_schema headers_num_list headers num)
    (cond [(empty? headers) '()]
          [(empty? headers_num_list) '()]
          [(equal? (car headers_num_list) num)
           (cons (car headers) (gen_new_schema (cdr headers_num_list) (cdr headers) (+ 1 num)))]
          [else (gen_new_schema headers_num_list (cdr headers) (+ 1 num))]))
  
  (table (gen_new_schema headers_num_list headers 1) (result tab-rows headers_num_list)))
  

; Sortowanie
(define (table-sort cols tab)
  (define list_to_sort (table-rows tab))
  
  (define (change? dic cols row1 row2)
  (if (empty? cols) #f
      
      (let ([row1_el (row_el row1 cols dic)]
             [row2_el (row_el row2 cols dic)])
      
      (cond
        [(string? row1_el)
         (cond [(string>? row1_el row2_el) #f]
               [(string<? row1_el row2_el) #t]
               [else (change? dic (cdr cols) row1 row2)])]
        
         [(number? row1_el)
         (cond [(> row1_el row2_el) #f]
               [(< row1_el row2_el) #t]
               [else (change? dic (cdr cols) row1 row2)])]
         
         [(boolean? row1_el)
         (cond [(and (equal? row1_el #t) (equal? row2_el #f)) #f]
               [(and (equal? row1_el #f) (equal? row2_el #t)) #t]
               [else (change? dic (cdr cols) row1 row2)])]

         [(symbol? row1_el)                   
         (cond [(string>? (symbol->string row1_el) (symbol->string row2_el)) #f]
               [(string<? (symbol->string row1_el) (symbol->string row2_el)) #t]
               [else (change? dic (cdr cols) row1 row2)])]))))
  
  (table (table-schema tab) (sort list_to_sort (lambda (x y) (change? (make_scheme_dic tab) cols x y)))))


; Selekcja

(define-struct and-f (l r))
(define-struct or-f (l r))
(define-struct not-f (e))
(define-struct eq-f (name val))
(define-struct eq2-f (name name2))
(define-struct lt-f (name val))

(define (table-select form tab)

  (define scheme_dic (make_scheme_dic tab))

  (define (if_form_true? row form scheme_dic)
    (cond [(and-f? form) (and (if_form_true? row (and-f-l form) scheme_dic) (if_form_true? row (and-f-r form)scheme_dic))]
          [(or-f? form)  (or (if_form_true? row (or-f-l form) scheme_dic) (if_form_true? row (or-f-r form)scheme_dic))]
          [(not-f? form) (not (if_form_true? row (not-f-e form) scheme_dic))]
          [(eq-f? form)  (equal? (list-ref row (var_fun (eq-f-name form) scheme_dic)) (eq-f-val form))]
          [(eq2-f? form) (equal? (list-ref row (var_fun (eq2-f-name form) scheme_dic))
                                 (list-ref row (var_fun (eq2-f-name2 form) scheme_dic)))]
          [(lt-f? form)  (< (list-ref row (var_fun (lt-f-name form) scheme_dic)) (lt-f-val form))]))

  (define (rows_iteration tab form scheme_dic)
    (filter  (lambda (x) (if_form_true? x form scheme_dic)) (table-rows tab)))

  (table (table-schema tab) (rows_iteration tab form scheme_dic)))


  
  
; Zmiana nazwy

(define (table-rename col ncol tab)
  (define (new_headers col ncol tab)
    (map (lambda (x) (if(equal? (column-info-name x) col)
                        (column-info ncol (column-info-type x))
                         x))(table-schema tab)))
  (table (new_headers col ncol tab) (table-rows tab))) 



  
; Złączenie kartezjańskie

(define (table-cross-join tab1 tab2)
  (define new-schema (cons (table-schema tab1) (table-schema tab2)))
  (define tab1-rows (table-rows tab1))
  (define tab2-rows (table-rows tab2))
  
  (define (connect_lists l1 l2)
    (if (empty? l1) l2 (cons (car l1) (connect_lists (cdr l1) l2))))
  
  (define (gen_new_rows tab1-rows tab2-rows)
    
    (define (tab2-rows-iter tab1-rows tab2-rows)
      (if (empty? tab2-rows) '()
          (cons (connect_lists (car tab1-rows) (car tab2-rows)) (tab2-rows-iter tab1-rows (cdr tab2-rows)))))

    (define (tab1-rows-iter tab1-rows tab2-rows fun)
      (if (empty? tab1-rows) '()
          (connect_lists (fun tab1-rows tab2-rows) (tab1-rows-iter (cdr tab1-rows) tab2-rows fun) )))

    (tab1-rows-iter tab1-rows tab2-rows tab2-rows-iter))
  
  (table (connect_lists (table-schema tab1) (table-schema tab2))
         (gen_new_rows tab1-rows tab2-rows)))

  
; Złączenie

(define (table-natural-join tab1 tab2)
  
  (define (delate_not_matching_rows shared_col tab)
    (if (empty? shared_col) tab
        (table-select (eq2-f (car shared_col) (adding_new (car shared_col))) (delate_not_matching_rows (cdr shared_col) tab)))) 

  (define (names_changing shared_col tab2)  
    (if (empty? shared_col) tab2
        (table-rename (car shared_col) (adding_new (car shared_col)) (names_changing (cdr shared_col) tab2))))

  (define (adding_new name)
    (string->symbol (string-append (symbol->string name) "_new")))
  
  (define (gen_shared_col tab1 tab2)
    (define tab1_schema (table-schema tab1))
    (define tab2_schema (table-schema tab2))
  
    (define tab1_names (map (lambda (x) (column-info-name x)) tab1_schema))
    (define tab2_names (map (lambda (x) (column-info-name x)) tab2_schema))
    
    (filter (lambda (x) (member x tab2_names)) tab1_names))


  (define shared_col (gen_shared_col tab1 tab2))
  (define tab2_new_names (names_changing shared_col tab2))
  (define t1_t2_cross (table-cross-join tab1 tab2_new_names))
  (define without_not_matching_rows (delate_not_matching_rows shared_col t1_t2_cross))
  (define wanted_schema_names (remove*  (map (lambda (x) (adding_new x)) shared_col) (map (lambda (x) (column-info-name x)) (table-schema without_not_matching_rows))))
  (define result (table-project wanted_schema_names without_not_matching_rows))

  result)

