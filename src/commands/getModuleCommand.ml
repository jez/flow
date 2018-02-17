(**
 * TODO(jez) LICENSE
 *)

(***********************************************************************)
(* flow get-module command *)
(***********************************************************************)

open CommandUtils

let spec = {
  CommandSpec.
  name = "get-module";
  doc = "Gets the module where a symbol is exported. Might return multiple results.";
  usage = Printf.sprintf
    "Usage: %s get-def [OPTION]... SYMBOL\n\n\
      e.g. %s get-def foo\n"
      CommandUtils.exe_name
      CommandUtils.exe_name;
  args = CommandSpec.ArgSpec.(
    empty
    |> server_and_json_flags
    |> root_flag
    |> anon "symbol" (required string) ~doc:"Symbol to find module for"
  )
}

(* get-module command handler.
   - json toggles JSON output
   - strip_root toggles whether output positions are relativized w.r.t. root
   - path is a user-specified path to use as incoming content source path
   - args is mandatory command args; see parse_args above
 *)
let main option_values json pretty root symbol () = begin
  (* TODO(jez) Copy boilerplate over from getDefCommand *)
  let root = guess_root root in
  if json || pretty || option_values.from = "emacs"
  then print_endline "Who needs flags!"
  else begin
    print_endline "Hello, world!";

    let request = ServerProt.Request.GET_MODULE symbol in
    match connect_and_make_request option_values root request with
    | ServerProt.Response.GET_MODULE (Ok modules) ->
      List.iter print_endline modules
    | ServerProt.Response.GET_MODULE (Error exn_msg) ->
      print_endline exn_msg
    | response -> failwith_bad_response ~request ~response
  end
end

let command = CommandSpec.command spec main
