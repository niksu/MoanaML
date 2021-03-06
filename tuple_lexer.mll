{
open Lexing
open Tuple_parser

(* code for the fun taken from  Real World Ocaml book *)
exception SyntaxError of string
let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }

}	

let newline = '\r' | '\n' | "\r\n"    

rule lex = parse
  | [' ' '\t' '\n']      { lex lexbuf }
	| newline         { next_line lexbuf; lex lexbuf }
  | ","             { COMMA }
  | "("             { LEFT_BRACE }
	| "{"             {START}
  |['a'-'z' 'A'-'Z' '0'-'9' '_']*[' ']?['a'-'z' 'A'-'Z' '0'-'9' '_' '@' '.' '-']+ as s { STRING (s) }
  | '?' ['A'-'Z' 'a'-'z' '_']* as v { VAR (v) }   	 
  | ")"             { RIGHT_BRACE }
	| "}"             {END}
	| _                             { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof             { EOF }

