(* TODO(jez) LICENSE *)

(* let getmodule_set_hooks pos = *)
(*   let state = { getmodule_type = None; getmodule_require_patterns = [] } in *)
(*   Type_inference_hooks_js.set_export_hook (getmodule_export (state, pos)); *)
(*   state *)

(* let getmodule_unset_hooks () = *)
(*   Type_inference_hooks_js.reset_hooks () *)

let get_module ~options symbol = begin
  (**
   *
   * TODO(jez)
   *
   * Status is: it doesn't work, but it could probably get close to working.
   * The reason why I stopped was because we'd generally approached the limit
   * of what we could do while being minimally invasive, and the solution was
   * still not all that good.
   *
   * Solution that would probably work:
   * - look up the list of all files from env.ServerEnv.files
   * - get all the Context.t's for each file i.e.:
   *   map (find_sig o File_key.SourceFile) files
   * - Fold over all the contexts, keep track of filenames where you found
   *   an export matching symbol
   *
   * This feels really hacky (having to loop over all the files to get all the
   * contexts), and I'm only partially sure it would work.
   *
   * A faster solution (which would use more memory) would be to build up a
   * mapping from "exported symbol" -> File_key.t list
   * This way, answering a get-module query would be just a Map lookup.
   * Though, this would use significantly more memory.
   *
   * Some notes about deveopment:
   *
   * - alias fflow=~/prog/pl/flow/bin/flow
   * - mkdir ~/foo && cd ~/foo
   * - fflow init
   * - (write some small testing files)
   * - Start the server manually, so we can see logs
   *
   *     fflow start --temp-dir /tmp/flow --log-file /private/tmp/flow/master.log /Users/jez/foo
   *
   *)
  (* let cx = Context_cache.find_sig ~options (File_key.SourceFile foo) in *)
  let cx = Context_cache.find_sig ~options File_key.Builtins in
  let exports = Context.export_maps cx in
  (* val fold: (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b *)
  let result = Type.Exports.Map.fold (fun (*mid*) _ tmap acc ->
    let syms = SMap.fold (fun sym (*typ*) _ syms ->
      (* [sym, id]::syms *)
      sym::syms
    ) tmap [] in
    syms @ acc
  ) exports [] in
  (* [symbol] *)
  Ok (symbol::result)
end
