(* * Copyright (c) 2014 Yan Shvartzshnaider * * Permission to use, copy,   *)
(* modify, and distribute this software for any * purpose with or without  *)
(* fee is hereby granted, provided that the above * copyright notice and   *)
(* this permission notice appear in all copies. * * THE SOFTWARE IS        *)
(* PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES * WITH REGARD  *)
(* TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF * MERCHANTABILITY  *)
(* AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR * ANY SPECIAL,  *)
(* DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES * WHATSOEVER  *)
(* RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN * ACTION OF  *)
(* CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF * OR IN   *)
(* CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.                *)
open Config
  
open Yojson
  
(** tuple object to string **)
let to_string =
  function
  | {
      subj = Constant s;
      pred = Constant p;
      obj = Constant o;
      ctxt = Constant c;
      time_stp = _;
      sign = _ } -> Printf.sprintf "< %s %s %s >" s p o
  | _ -> "Not printing this tuple."
  
let value_to_str = function | Variable x -> x | Constant x -> x
  
(* FIX ME: Need to take care of Context, Signature and Timestamp *)
let to_json =
  function
  | {
      subj = Constant s;
      pred = Constant p;
      obj = Constant o;
      ctxt = Constant c;
      time_stp = _;
      sign = _ } ->
      let t_json : Yojson.Basic.json =
        `Assoc
          [ ("Subject", (`String s)); ("Predicate", (`String p));
            ("Object", (`String o)) ]
      in t_json
  | _ -> assert false
  
(* create tuple from JSON *)
let from_json json_t =
  (* FIX ME: Need to take care of Context, Signature and Timestamp *)
  let open Yojson.Basic.Util
  in
    let json = Yojson.Basic.from_string json_t in
    let s = json |> (member "Subject") in
    let p = json |> (member "Predicate") in
    let o = json |> (member "Object")
    in
      {
        subj = Constant (Basic.Util.to_string s);
        pred = Constant (Basic.Util.to_string p);
        obj = Constant (Basic.Util.to_string o);
        ctxt = Constant "context";
        time_stp = None;
        sign = None;
      }
  
let print_value =
  function
  | Variable x ->
      (print_string "Var (";
       print_string x;
       print_string ") ";
       print_endline "")
  | Constant x ->
      (print_string "Const (";
       print_string x;
       print_string ") ";
       print_endline "")
  
let rec print_tuples tuples =
  match tuples with
  | [] -> print_endline "--"
  | head :: rest -> (print_endline (to_string head); print_tuples rest)
  
let print_tuples_list tuples = List.map (fun t -> print_tuples t) tuples
  
open Lexing
  

let print_position outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  Printf.fprintf outx "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)	
		
(** convert string to list of tuple objects **)
exception SyntaxError of string

let to_tuple_lst s =
	  let lexbuf = Lexing.from_string s in 
try	
	Tuple_parser.parse_lst Tuple_lexer.lex lexbuf
	with
	| SyntaxError msg ->		
    Printf.fprintf stderr "%a: %s\n" print_position lexbuf msg;
   []
  | Tuple_parser.Error ->		
    Printf.fprintf stderr "%a: syntax error\n" print_position lexbuf; []
  	
(** string to tuple *)  
let to_tuple s =
  let tuple = Tuple_parser.parse_tuple Tuple_lexer.lex (Lexing.from_string s)
  in match tuple with | Some t -> t | None -> raise Wrong_tuple
	
(** string to list of query tuples **)  
let str_query_list s =
  let queryBuffer = Lexing.from_string s
  in Query_parser.parse Query_lexer.lex queryBuffer
	
