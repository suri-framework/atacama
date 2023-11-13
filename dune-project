(lang dune 3.10)

(name caravan)

(generate_opam_files true)

(source
 (github leostera/caravan))

(authors "Leandro Ostera <leandro@abstractmachines.dev>")

(maintainers "Leandro Ostera <leandro@abstractmachines.dev>")

(license MIT)

(package
 (name caravan)
 (synopsis "Modern, pure OCaml socket pool for Riot")
 (description "Caravan is a modern, pure OCaml socket pool for Riot inspired by Thousand Island. It aims to be easy to understand and reason about, while also being at least as stable and performant as the alternatives.")
 (depends
   (ocaml (>= "5.0"))
   riot
   (telemetry (>= "0.0.1"))
   dune
   )
 (tags
  (topics socket "socket pool" riot)))
