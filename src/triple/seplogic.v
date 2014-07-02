Require Import triple.core.
Import triple.core.tripleconfig.

Require Import septac (* for [sbazooka] *) pfun (* for [splitsAs] *).
Require Import triple.roc.

Import Prenex Implicits.

Lemma triple_pre_exists T (Pf: T -> SPred) c O Q :
  (forall t:T, TRIPLE (Pf t) c O Q) -> TRIPLE (Exists t, Pf t) c O Q.
Proof. move => TR.
move => s [t' H]. by apply (TR t' s H).
Qed.

Lemma triple_pre_existsOp T (Pf: T -> _) c O Q :
  TRIPLE (Exists t, Pf t) c O Q -> (forall t:T, TRIPLE (Pf t) c O Q).
Proof. move => TR t s pre. apply (TR s). by exists t. Qed.

Lemma triple_pre_existsSep T (Pf: T -> _) c O Q S :
  (forall t, TRIPLE (Pf t ** S) c O Q) -> TRIPLE ((Exists t, Pf t) ** S) c O Q.
Proof.
  move => TR. apply triple_roc_pre with (Exists t, Pf t ** S).
  - sbazooka.
  move => s [t H]. apply (TR t s H).
Qed.

Lemma triple_pre_existsSepOp T (Pf: T -> _) c O Q S :
  TRIPLE ((Exists t, Pf t) ** S) c O Q -> (forall t, TRIPLE (Pf t ** S) c O Q).
Proof.
  move=> TR t. eapply triple_roc_pre; [|eassumption]. ssplit; reflexivity.
Qed.

Lemma triple_post_disjL P c O Q1 Q2 :
   TRIPLE P c O Q1 -> TRIPLE P c O (Q1 \\// Q2).
Proof. move => TR s H.
specialize (TR s H).
destruct TR as [f [o [EQ HH]]].
exists f, o. firstorder. by left.
Qed.

Lemma triple_post_disjR P c O Q1 Q2 :
   TRIPLE P c O Q2 -> TRIPLE P c O (Q1 \\// Q2).
Proof. move => TR s H.
specialize (TR s H).
destruct TR as [f [o [EQ [HO HH]]]].
exists f, o. split => //. split => //. by right.
Qed.

Lemma triple_post_existsSep T (t:T) P (Qf: T -> _) c O S :
  TRIPLE P c O (Qf t ** S) -> TRIPLE P c O ((Exists t, Qf t) ** S).
Proof.
  move=> TR. eapply triple_roc_post; [|eassumption]. ssplit; reflexivity.
Qed.

Lemma triple_pre_hideFlag (f:Flag) v P c O Q :
  TRIPLE (f? ** P) c O Q ->
  TRIPLE (f ~= v ** P) c O Q.
Proof. move => H. by apply triple_pre_existsSepOp. Qed.


Lemma triple_pre_instFlag (f:Flag) P c O Q :
  (forall v, TRIPLE (f ~= v ** P) c O Q) ->
  TRIPLE (f? ** P) c O Q.
Proof. move => TR. apply triple_pre_existsSep => v. apply TR. Qed.

(*
Lemma pointsToBYTEdef (p:DWORD) (v: BYTE) (s:PState) : (p:->v) s -> s Memory p = Some (Some v).
Proof. move => [q H].
destruct H as [b [s1 [s2 [H1 [H2 H3]]]]].
rewrite /byteIs in H2. rewrite -H2 in H1.
rewrite /addBYTEToPState in H2. simpl in H2. apply f_equal in H2. firstorder. congruence. simpl in H2. rewrite /MemIs in H.
simpl.
destruct H as [m [H1 H2]].
simpl getReader in H1.
rewrite /readBYTE /= /readBYTE_op in H1.
case e': (m p) => [b |]; rewrite e' in H1; last done.
rewrite H2. congruence.
rewrite /inRange leCursor_refl andTb. replace q with (next p) by congruence.
apply ltNext.
Qed.
*)

Lemma byteIsMapped (p:PTR) (v: BYTE) S s :
  (byteIs p v ** S) (toPState s) -> isMapped p s.
Proof.
move => [s1 [s2 [H1 [H2 H3]]]].
destruct (stateSplitsAsIncludes H1) as [H4 H5].
rewrite /byteIs/addBYTEToPState in H2; simpl in H2.
rewrite <- H2 in H4.
specialize (H4 Memory p). rewrite /= eq_refl/= in H4.
specialize (H4 (Some v) (refl_equal _)).
inversion H4. rewrite /isMapped H0. done.
Qed.