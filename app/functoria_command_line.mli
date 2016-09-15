(*
 * Copyright (c) 2013 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Functions for reading various options from a command line. *)

val read_log_level : string array -> Functoria_misc.Log.level
(** [read_log_level argv] reads -v and --verbose options from [argv] and
    builds a {!Log.level} value according to the number of times the flags
    occur:
     * 0 occurrences: WARN
     * 1 occurrence: INFO
     * 2+ occurrences: DEBUG
*)

val read_colour_option : string array -> Fmt.style_renderer option
(** [read_colour_option argv] reads the --color option from [argv] and builds
    a {!Fmt.style_renderer} value that depends on the argument of the option:
     * --color=auto: None
     * --color=always: Some `Ansi_tty
     * --color=never: Some `None
*)

val read_config_file : string array -> string option
(** [read_config_file argv] reads the -f or --file option from [argv] and
    returns the argument of the option. *)

val read_full_eval : string array -> bool
(** [read_full_eval argv] reads the --eval option from [argv]; the return
    value indicates whether the option is present in [argv]. *)

type 'a config_args = {
  result: 'a;
  no_opam: bool;
  no_depext: bool;
  no_opam_version: bool
}
(** A value of type [config_args] is the result of parsing the arguments to a
    [configure] subcommand.

    The [result] field holds the result of parsing the "additional" arguments
    whose specification is passed as the [configure] argument to
    {!parse_args}. *)

type 'a describe_args = {
  result: 'a;
  dotcmd: string;
  dot: bool;
  output: string option;
}
(** A value of type [describe_args] is the result of parsing the arguments to
    a [describe] subcommand.

    The [result] field holds the result of parsing the "additional" arguments
    whose specification is passed as the [describe] argument to
    {!parse_args}. *)

type 'a action =
    Configure of 'a config_args
  | Describe of 'a describe_args
  | Build of 'a
  | Clean of 'a
  | Help
(** A value of type [action] is the result of parsing command-line arguments using
    [parse_args]. *)

open Cmdliner.Term

val parse_args : name:string -> version:string ->
  configure:'a t ->
  describe:'a t ->
  build:'a t -> 
  clean:'a t ->
  help:_ t ->
  string array ->
  'a action result
(** Parse the functoria command line.  The arguments to [~configure],
    [~describe], etc., describe extra command-line arguments that should be
    accepted by the corresponding subcommands.  The full argument
    specification is as follows:

      name configure [-v|--verbose]
                     [--color=(auto|always|never)]
                     [-f FILE | --file=FILE]
                     [--no-opam]
                     [--no-opam-version-check]
                     [--no-depext]
                     [extra arguments]
      name describe [--eval]
                    [-v|--verbose]
                    [--color=(auto|always|never)]
                    [-f FILE | --file=FILE]
                    [-o FILE | --output=FILE]
                    [--dot-command=COMMAND]
                    [--dot]
                    [extra arguments]
      name build [-v|--verbose]
                 [--color=(auto|always|never)]
                 [-f FILE | --file=FILE]
                 [extra arguments]
      name clean [-v|--verbose]
                 [--color=(auto|always|never)]
                 [-f FILE | --file=FILE]
                 [extra arguments]
      name help [-v|--verbose]
                [--color=(auto|always|never)]
                [--man-format=(groff|pager|plain)]
                [configure|describe|build|clean|help|topics]
                [extra arguments]
      name [-v|--verbose]
           [--color=(auto|always|never)]

    There are no side effects, save for the printing of usage messages and
    other help when either the 'help' subcommand or no subcommand is specified. *)
