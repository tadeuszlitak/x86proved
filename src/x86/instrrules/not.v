(** * NOT instruction *)
Require Import x86.instrrules.core.
Import x86.instrrules.core.instrruleconfig.

Lemma NOT_rule d (src:RegMem d) v:
  |-- specAtRegMemDst src (fun V => basic (V v) (UOP d OP_NOT src) (V (invB v))).
Proof. do_instrrule_triple. Qed.

Ltac basicNOT :=
  rewrite /makeUOP;
  let R := lazymatch goal with
             | |- |-- basic ?p (@UOP ?d OP_NOT ?a) ?q => constr:(@NOT_rule d a)
           end in
  instrrules_basicapply R.


(** Special case for not *)
Lemma NOT_R_rule (r:Reg) (v:DWORD):
  |-- basic (r~=v) (NOT r) (r~=invB v).
Proof. basicNOT. Qed.

Corollary NOT_M_rule (r:Reg) (offset:nat) (v pbase:DWORD):
  |-- basic (r~=pbase ** pbase +# offset :-> v) (NOT [r + offset])
            (r~=pbase ** pbase +# offset :-> invB v).
Proof. basicNOT. Qed.
