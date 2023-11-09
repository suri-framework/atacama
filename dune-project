(lang dune 3.10)

(name caravan)

(generate_opam_files true)

(source
 (github leostera/caravan))

(authors "Leandro Ostera <leandro@abstractmachines.dev>")

(maintainers "Leandro Ostera <leandro@abstractmachines.dev>")

(license MIT)

(documentation https://github.com/leostera/caravan)

(package
 (name caravan)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
   (ocaml (>= "5.0"))
   (riot (>= "0.0.1"))
   (telemetry (>= "0.0.1"))
   dune
   )
 (tags
  (topics "to describe" your project)))
