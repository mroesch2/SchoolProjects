(* CSC 2710 starter code for breadth-first bottom-up parser implemented in OCaml
   Author: Martha Kosa
   Date: 11.19.2019 *)

(* Modifications by Melissa Roesch(and YYY and ZZZ if you have a partner or partners) *)

(****************************)
(* list utility functions *)

(* converts from String to list of chars *)
(* from https://caml.inria.fr/mantis/view.php?id=5367 *)
let explode s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
    exp (String.length s - 1) [];;

(* TODO: Call explode with your name as input.  If you are working in a team, call
   explode once for each team member. *) 
let input_name = explode "Melissa";;

(* converts from list of chars to String *)
(* single char conversion from https://stackoverflow.com/questions/20441263/convert-char-to-string-in-ocaml/20463186 *)
(* Pattern matching*)
let rec to_one_string char_list =
  match char_list with
    | [] -> ""  (*has to be string*)
    | h::t -> (String.make 1 h)^(to_one_string t);; (* ^ does string concatenation *)

(* TODO: Call to_one_string with the result(s) of your call(s) to explode. *)(*DONE*)
(*let use var names. if not call to explode in paranthesis*)
let str_result = to_one_string input_name;;

(* tail-recursive list reversal *)
let reverse xs =
  let rec reverse_tail xs rxs =
    match xs with
      | [] -> rxs
      | h::t -> reverse_tail t (h::rxs)
  in reverse_tail xs [];;

(* TODO: Call reverse with the result(s) of your call(s) to explode. *)(*DONE*)
reverse input_name;;



(* TODO: Complete (and uncomment) the below recursive function to determine whether
   a list is a prefix of another list. *)(*DONE*)
let rec prefix xs ys = 
   match (xs, ys) with
   | ([], _) -> true
   | (_, []) -> false
   | (x::xss, y::yss) ->          
   if x = y then prefix xss yss else false;;

(* TODO: Write 8 test cases to test your prefix function thoroughly. *)(*DONE*)
prefix [][];;
prefix [] [1;2;3;4;5];;
prefix [1] [1;2;3;4;5];;
prefix [1;2] [1;2;3;4;5];;
prefix [1;4] [1;2;3;4;5];;
prefix [1;2;3] [1;2;3;4;5];;
prefix [1;2;3;4;5] [];;
prefix [1;2;3;4;5] [1;2;3;4];;


(* TODO: Complete (and uncomment) the below function to determine whether
   a list is a suffix of another list. *) (*DONE*)
let suffix xs ys = prefix (reverse xs) (reverse ys);;

(* TODO: Write 8 test cases to test your suffix function thorougly. *)(*DONE*)
suffix [][];;
suffix [] [1;2;3;4;5];;
suffix [1] [1;2;3;4;5];;
suffix [1;2] [1;2;3;4;5];;
suffix [1;4] [1;2;3;4;5];;
suffix [1;2;3] [1;2;3;4;5];;
suffix [1;2;3;4;5] [];;
suffix [1;2;3;4;5] [1;2;3;4];;

(* TODO: Write a comment to explain what map does. *)(*DONE*)
(* Map will take a function and a list and produces a new list based on the function of each character in the list*)
let rec map f xs =
  match xs with
    | [] -> []
    | h::t -> (f h)::(map f t);;

(* TODO: Write a comment to explain what filter does. *)(*DONE*)
(* Filter takes in characters and outputs only the character specified if it exists*)
let rec filter f xs =
  match xs with
    | [] -> []
    | h::t ->
        if (f h) then h::(filter f t) else (filter f t);;

let get_all_nonempty_prefixes xs =
  let rec get_all_nonempty_prefixes_tr xs last acc =
    match xs with
      | [] -> acc
      | h::t -> let next = last@[h] in
            get_all_nonempty_prefixes_tr t next ([next]@acc)
  in reverse (get_all_nonempty_prefixes_tr xs [] []);;

(* TODO: Write 2 nontrivial test cases to test get_all_non_empty_prefixes thoroughly. *)(*DONE*)

let get_all_nonempty_suffixes xs = map reverse (get_all_nonempty_prefixes (reverse xs));;

get_all_nonempty_prefixes [1;2;3;4;5];;
get_all_nonempty_prefixes ["hello"; "world"];;

(* TODO: Write 2 nontrivial test cases to test get_all_non_empty_suffixes thoroughly. *)(*DONE*)
get_all_nonempty_suffixes [1;2;3;4;5];;
get_all_nonempty_suffixes ["hello"; "world"];;

let list_length xs =
  let rec list_length_tr xs acc =
    match xs with
      	  | [] -> acc
      | _::t -> list_length_tr t acc+1
  in list_length_tr xs 0;;

(* TODO: Write 2 test cases to test list_length thoroughly. *)(*DONE*)
list_length [1;2;3;4;5;6;7;8;9;10];;
list_length [2;4;6;8];;

let take n xs =
  let rec take_tr n xs acc =
    if n <= 0 then
      acc
    else
      	  match xs with
        | h::t -> take_tr (n-1) t (acc@[h])
  in take_tr n xs [];;

(* TODO: Write 4 test cases to test take thoroughly, including
   one that crashes.  Comment out that test case. *)(*DONE*)
take 2 [1;2;3];;
(*take 5 [1;2;3];;*)  (*Test case that crashes*)
take 4 [2;4;6;8;10];;
take 1 [1;2;3;4;5;6;7;8;9;0];;

let rec drop n xs =
  if n <= 0 then
    xs
  else
    match xs with
      | _::t -> drop (n-1) t;;
	  
(* TODO: Write 4 test cases to test drop thoroughly, including
   one that crashes.  Comment out that test case. *)(*DONE*)
drop 2 [1;2;3];;
(*drop 5 [1;2;3];;*)    (*Test case that crashes*)
drop 4 [2;4;6;8;10];;
drop 5 [1;2;3;4;5;6;7;8;9;0];;

(* TODO: Write comments describing how sublist can crash. *)(*DONE*)
(*If j < i+1, take will be less than 0*)
let sublist i j xs = take (j - i + 1) (drop (i - 1) xs);;

let all_two_ways xs =
  let rec all_two_ways_numbered xs nxs i acc =
    if i = nxs+1 then
      acc
    else
      all_two_ways_numbered xs nxs (i+1) (acc@[(take i xs), (drop i xs)])
  in all_two_ways_numbered xs (list_length xs) 0 [];;


(* TODO: Write 2 test cases to test all_two_ways thoroughly. *)(*DONE*)
all_two_ways [2;4;6;8;10];;
all_two_ways [1;2;3];;

let tuple_3 x (y, z) = (x, y, z);;

let two_way_to_three_ways (xs, ys) =
  let two_way_ys = all_two_ways ys in
    map (tuple_3 xs) two_way_ys;;
	
(* TODO: Write two test cases to test two_way_to_three_ways thoroughly. *)(*DONE*)
two_way_to_three_ways ([1;2], [2;3]);;
two_way_to_three_ways ([1;3;5;9], [2;3;4;5;6]);;

(* TODO: Write a comment to explain what my_fold_left does. *)(*DONE*)
(* Takes in a function, int, and a list. f tells what operation is done on id with the list*)
(* my_fold_left (+) 1 [1;2;3] = (((1 + 1) + 2) + 3) *)
let rec my_fold_left f id xs =
  match xs with
    | [] -> id
    | h::t -> my_fold_left f (f id h) t;;

let flatten xs = my_fold_left (@) [] xs;;

let all_three_ways xs = flatten (map two_way_to_three_ways (all_two_ways xs));;

(* TODO: Write a test case to test all_three_ways thoroughly. *)(*DONE*)
all_three_ways [1;2;3;4;5];;

let position x the_list =
  let rec accpos i y the_list =
    match the_list with
      | [] -> -1
      | z::t -> if y = z then i else (accpos (i+1) y t)
  in (accpos 0 x the_list);;

let contains the_list x = (position x the_list) >= 0;;

(* TODO: Write a test case to test contains thoroughly. *)(*DONE*)
contains [2;4;6;8;10] 7;;

(*Whatever is in the second list must all be in first list to be true. Items in first list don't need to be in second list*)
let all_contained_in the_list xs = my_fold_left (&&) true (map (contains the_list) xs);;

(* TODO: Write three test cases to test all_contained_in_the_list thoroughly. *)(*DONE*)
all_contained_in [1;2;3;4;5] [1;2;3];;
all_contained_in [1;2;3;4;5] [1;2;3;7];;
all_contained_in [1;2;3;4;5] [1;2;3];;

(*Takes in a list of type a -> type c list * type b list * type a list and a bool *)
let has_terminal_suffix terminals (u, w, v) =
  all_contained_in terminals v;;

let abcd_terminals = ['a';'b';'c';'d'];;

let aabcdd_form = explode "aabcdd";;      (* ['a';'a'; 'b';'c'; 'd'; 'd';]*)

(* TODO: Complete the below function and uncomment it and the test case below it. You need to break
   the sentential form into three pieces. The call to has_terminal_suffix is correct. It is an
        example of a partially applied function, or curried function. *)(*DONE*)
        
  
let get_candidates sentential_form terminals = filter (has_terminal_suffix terminals) (all_three_ways sentential_form);;

   get_candidates aabcdd_form abcd_terminals;;

(* TODO: Complete (and uncomment) the below function. *)(*DONE*)
let rec explode_all_RHS productions =
   match productions with
   | [] -> []
   | head::tail ->
   match head with
   | (lhs, rhs) ->
   (lhs, (explode rhs))::(explode_all_RHS(tail));;

let amplus1bmcndnplus1_rules = [('S', "TU"); ('T', "aTb"); ('T', "a");
                                ('U', "cUd"); ('U', "d")];;

let batoi_rules = [('S',"Sa"); ('S', "b")];;

let aplusbpluscplus_rules = [('S', "Sc"); ('S', "Tc"); ('T', "Tb");
                             ('T', "Ub"); ('U', "Ua"); ('U', "a")];;

(* TODO: Uncomment the below commented code. *)(*DONE*)
explode_all_RHS amplus1bmcndnplus1_rules;;

   explode_all_RHS batoi_rules;;

   explode_all_RHS aplusbpluscplus_rules;; 

(* TODO: Complete and uncomment the below recursive function. *)  
let rec are_lists_equal list1 list2 =
   match (list1, list2) with
   | ([], []) -> true
   | (h1::t1, h2::t2) ->            (* Add element to head of both lists*)
   (h1 == h2) && (are_lists_equal t1 t2)
   | _ -> false;; 

(*TODO: Complete (and uncomment) the below recursive function 
  which produces a list of lefthand sides of all rules having 
        w as a righthand side for the sentential form uwv. *)
        
let rec find_all_LHS rules (u, w, v) =
   match rules with
   | [] -> []                           
   | (lhs, rhs)::tail ->
   if (are_lists_equal w rhs) then      (*if w matches rhs, then reduce*)
   lhs::(find_all_LHS tail (u, w, v))
   else
    find_all_LHS tail (u, w, v);;     (*if not, call right hand side*)

let not_empty list = not (list = []);;

(* TODO: Uncomment the below commented code.*)(*DONE*)

   let all_LHS rules candidates = map (find_all_LHS (explode_all_RHS rules)) candidates;;

   all_LHS amplus1bmcndnplus1_rules (get_candidates aabcdd_form abcd_terminals);;

(* This function produces sentential form uAv from uwv, assuming A -> w is a rule. *)
let reduce big_A (u, w, v) = (u, big_A, v);;

let rec zip f xs ys =
  match (xs, ys) with
    | ([], []) -> []
    | (a::ta, b::tb) -> (f a b)::(zip f ta tb)
    | (_, _) -> [];;

my_fold_left (+) 0 (zip ( * ) [1;2;3] [4;5;6]);;
(* TODO: What vector operation is performed in the above call to my_fold_left?*)(*DONE*)
   (*the dot product is being done*)

(* This function produces a single list from the three list components of the tuple parameter. *)
let detuple_3 (x, y, z) = x@y@z;;

let is_valid_LHS (u, big_A, v) = not_empty big_A;;

(* TODO: Uncomment the below commented code. *) (*DONE*)
let reduce_all terminals rules sentential_form =
   let candidates = get_candidates sentential_form terminals in
   map detuple_3 (filter is_valid_LHS (zip reduce (all_LHS rules candidates) candidates));;

(*TODO: In the above reduce_all function, how many functions are explicitly called when reduce_all
   is called?
   		 There are five functions. get_candidates, map, filter, zip and reduce. *) (*DONE*)
		 
(* TODO: Uncomment the below commented code. *)(*DONE*)
let aabcdd_reduced_forms = reduce_all abcd_terminals amplus1bmcndnplus1_rules aabcdd_form;;

(* TODO: Complete (and uncomment) the below recursive algorithm which implements the breadth-first
   bottom-up parsing algorithm done in class. The explored parameter is a list containing
        all sentential forms checked so far. *)
        
let rec bottom_up_parse p terminals rules start_symbol explored queue =
   match queue with
   | [] -> (p^" is invalid", explored, queue)
   | sentential_form::tail ->
   if (are_lists_equal [start_symbol] sentential_form) then
   (p^" is valid", explored@[[start_symbol]], tail)
   else
   let next_level = (reduce_all terminals rules sentential_form) in
   bottom_up_parse p terminals rules start_symbol (explored@[sentential_form]) (tail@next_level);;

(* TODO: Uncomment the below code for testing when you have finished bottom_up_parse. *)
let parse p terminals rules start_symbol = bottom_up_parse p terminals rules start_symbol [] [explode p];;

   let parse_yes_no_only p terminals rules start_symbol =
   let (result,_,_) = parse p terminals rules start_symbol in
   result;;

   let num_forms_explored p terminals rules start_symbol =
   let (_,explored,_) = parse p terminals rules start_symbol in
   list_length explored;;

   parse "aabcdd" abcd_terminals amplus1bmcndnplus1_rules 'S';;

   parse_yes_no_only "aabcdd" abcd_terminals amplus1bmcndnplus1_rules 'S';;

   num_forms_explored "aabcdd" abcd_terminals amplus1bmcndnplus1_rules 'S';;

   parse "aaabccddd" abcd_terminals amplus1bmcndnplus1_rules 'S';;

   parse_yes_no_only "aaabccddd" abcd_terminals amplus1bmcndnplus1_rules 'S';;

   num_forms_explored "aaabccddd" abcd_terminals amplus1bmcndnplus1_rules 'S';;

   let rec dup_tr s n acc = if n <= 0 then acc else dup_tr s (n-1) (s^acc);;

   let dup s n = dup_tr s n "";;

   let ba100 = "b"^(dup "a" 100);;

   let ab_terminals = ['a'; 'b'];;

 

   parse ba100 ab_terminals batoi_rules 'S';;

   parse_yes_no_only ba100 ab_terminals batoi_rules 'S';;

   num_forms_explored ba100 ab_terminals batoi_rules 'S';;

   let ba100b = ba100^"b";;

   parse ba100b ab_terminals batoi_rules 'S';;

   parse_yes_no_only ba100b ab_terminals batoi_rules 'S';;

   num_forms_explored ba100b ab_terminals batoi_rules 'S';;

   let abc_terminals = ['a'; 'b'; 'c'];;

   let aabbc = "aabbc";;

   parse aabbc abc_terminals aplusbpluscplus_rules 'S';;

   parse_yes_no_only aabbc abc_terminals aplusbpluscplus_rules 'S';;

   num_forms_explored aabbc abc_terminals aplusbpluscplus_rules 'S';;

   let aabbcb = "aabbcb";;

   parse aabbcb abc_terminals aplusbpluscplus_rules 'S';;

   parse_yes_no_only aabbcb abc_terminals aplusbpluscplus_rules 'S';;

   num_forms_explored aabbcb abc_terminals aplusbpluscplus_rules 'S';;



(* TODO: the last one. Yay!!!!!
   Develop a left-recursive grammar that generates {f}+, where f represents
   your first name.  It will have two rules.  Test it for f^2 by calling parse,
   parse_yes_no_only, and num_forms_explored.  Do this for each team member. *)

let name_terminals = ['m'; 'e'; 'l'; 'i'; 's'; 's'; 'a'];;

let melissa = "melissamelissa";;


let name_rules = [('S', "Smelissa"); ('S', "melissa")];;



parse melissa name_terminals name_rules 'S';;

parse_yes_no_only melissa name_terminals name_rules 'S';;
                          
num_forms_explored melissa name_terminals name_rules 'S';;

















