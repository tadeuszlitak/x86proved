(*===========================================================================
  Some simple examples used in the ITP 2013 submission
  ===========================================================================*)
Require Import Ssreflect.ssreflect Ssreflect.ssrbool Ssreflect.ssrfun Ssreflect.ssrnat Ssreflect.eqtype Ssreflect.seq Ssreflect.fintype Ssreflect.tuple.
Require Import x86proved.x86.procstate x86proved.x86.procstatemonad x86proved.bitsrep x86proved.bitsops x86proved.bitsprops x86proved.bitsopsprops.
Require Import x86proved.spred x86proved.spec x86proved.safe x86proved.x86.basic x86proved.x86.program x86proved.x86.macros.
Require Import x86proved.x86.instr x86proved.x86.instrsyntax x86proved.x86.instrcodec x86proved.x86.instrrules x86proved.reader x86proved.cursor.

Set Implicit Arguments.
Unset Strict Implicit.
Import Prenex Implicits.

Local Open Scope instr_scope.

(*=max *)
(* Determine max(r1,r2), leaving result in r1 *)
Definition max (r1 r2: GPReg32) : program :=
  LOCAL Bigger;
    CMP r1, r2;; JG Bigger;; MOV r1, r2;;
  Bigger:; .
(*=End *)

(*=letproc *)
Definition callproc f :=
  LOCAL iret;
   MOV RDI, iret;; JMP f;;
  iret:;.

Definition defproc (p: program) :=
  p;; JMP RDI.

Notation "'letproc' f ':=' p 'in' q" :=
  (LOCAL skip; LOCAL f;
    JMP skip;;
   f:;;    defproc p;;
   skip:;; q)
  (at level 65, f ident, right associativity).

(* Multiply EAX by nine, trashing EBX *)
Example ex :=
  letproc tripleEAX :=
    MOV EBX, EAX;; SHL EAX, 2;; ADD EAX, EBX
  in
    callproc tripleEAX;; callproc tripleEAX.
(*=End *)

(* Example taken verbatim from TALx86: A Realistic Typed Assembly Language *)
Example talx86_4_1 :=
LOCAL test; LOCAL body;
  MOV EAX, ECX;;
  INC EAX;;
  MOV EBX, (0:DWORD);;
  JMP test;;
body:;;           (* EAX: DWORD, EBX: DWORD *)
  ADD EBX, EAX;;
test:;;           (* EAX: DWORD, EBX: DWORD *)
  DEC EAX;;
  CMP EAX, (0:DWORD);;
  JG body.


(* Inline data *)
Example exdata :=
  LOCAL data; LOCAL skip;
    MOV RDI, data;;
    ADD RAX, QWORD PTR [RDI];;
    JMP skip;;
  data:;;
    dq #123;;
  skip:;.

(* Alignment *)
(*=exalign *)
Example exalign :=
LOCAL str; LOCAL num;
str:;;  ds "Characters";;
num:;;  align 2;; (* Align on 2^2 boundary i.e. DWORD *)
        dd #x"87654321". (* DWORD value *)
(*=End *)
