(**
This file is part of the Flocq formalization of floating-point
arithmetic in Coq: http://flocq.gforge.inria.fr/

Copyright (C) 2009-2018 Sylvie Boldo
#<br />#
Copyright (C) 2009-2018 Guillaume Melquiond

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
COPYING file for more details.
*)

(** * Floating-point format without underflow *)
Require Import Raux Defs Round_pred Generic_fmt Float_prop.
Require Import FIX Ulp Round_NE.

Section RND_FLX.

Variable beta : radix.

Notation bpow e := (bpow beta e).

Variable prec : Z.

Class Prec_gt_0 :=
  prec_gt_0 : (0 < prec)%Z.

Context { prec_gt_0_ : Prec_gt_0 }.

Inductive FLX_format (x : R) : Prop :=
  FLX_spec (f : float beta) :
    x = F2R f -> (Z.abs (Fnum f) < Zpower beta prec)%Z -> FLX_format x.

Definition FLX_exp (e : Z) := (e - prec)%Z.

(** Properties of the FLX format *)

Global Instance FLX_exp_valid : Valid_exp FLX_exp.
Proof.
intros k.
unfold FLX_exp.
generalize prec_gt_0.
repeat split ; intros ; omega.
Qed.

Theorem FIX_format_FLX :
  forall x e,
  (bpow (e - 1) <= Rabs x <= bpow e)%R ->
  FLX_format x ->
  FIX_format beta (e - prec) x.
Proof.
clear prec_gt_0_.
intros x e Hx [[xm xe] H1 H2].
rewrite H1, (F2R_prec_normalize beta xm xe e prec).
now eexists.
exact H2.
now rewrite <- H1.
Qed.

Theorem FLX_format_generic :
  forall x, generic_format beta FLX_exp x -> FLX_format x.
Proof.
intros x H.
rewrite H.
eexists ; repeat split.
simpl.
apply lt_IZR.
rewrite abs_IZR.
rewrite <- scaled_mantissa_generic with (1 := H).
rewrite <- scaled_mantissa_abs.
apply Rmult_lt_reg_r with (bpow (cexp beta FLX_exp (Rabs x))).
apply bpow_gt_0.
rewrite scaled_mantissa_mult_bpow.
rewrite IZR_Zpower, <- bpow_plus.
2: now apply Zlt_le_weak.
unfold cexp, FLX_exp.
ring_simplify (prec + (mag beta (Rabs x) - prec))%Z.
rewrite mag_abs.
destruct (Req_dec x 0) as [Hx|Hx].
rewrite Hx, Rabs_R0.
apply bpow_gt_0.
destruct (mag beta x) as (ex, Ex).
now apply Ex.
Qed.

Theorem generic_format_FLX :
  forall x, FLX_format x -> generic_format beta FLX_exp x.
Proof.
clear prec_gt_0_.
intros x [[mx ex] H1 H2].
simpl in H2.
rewrite H1.
apply generic_format_F2R.
intros Zmx.
unfold cexp, FLX_exp.
rewrite mag_F2R with (1 := Zmx).
apply Zplus_le_reg_r with (prec - ex)%Z.
ring_simplify.
now apply mag_le_Zpower.
Qed.

Theorem FLX_format_satisfies_any :
  satisfies_any FLX_format.
Proof.
refine (satisfies_any_eq _ _ _ (generic_format_satisfies_any beta FLX_exp)).
intros x.
split.
apply FLX_format_generic.
apply generic_format_FLX.
Qed.

Theorem FLX_format_FIX :
  forall x e,
  (bpow (e - 1) <= Rabs x <= bpow e)%R ->
  FIX_format beta (e - prec) x ->
  FLX_format x.
Proof with auto with typeclass_instances.
intros x e Hx Fx.
apply FLX_format_generic.
apply generic_format_FIX in Fx.
revert Fx.
apply generic_inclusion with (e := e)...
apply Z.le_refl.
Qed.

(** unbounded floating-point format with normal mantissas *)
Inductive FLXN_format (x : R) : Prop :=
  FLXN_spec (f : float beta) :
    x = F2R f ->
    (x <> 0%R -> Zpower beta (prec - 1) <= Z.abs (Fnum f) < Zpower beta prec)%Z ->
    FLXN_format x.

Theorem generic_format_FLXN :
  forall x, FLXN_format x -> generic_format beta FLX_exp x.
Proof.
intros x [[xm ex] H1 H2].
destruct (Req_dec x 0) as [Zx|Zx].
rewrite Zx.
apply generic_format_0.
specialize (H2 Zx).
apply generic_format_FLX.
rewrite H1.
eexists ; repeat split.
apply H2.
Qed.

Theorem FLXN_format_generic :
  forall x, generic_format beta FLX_exp x -> FLXN_format x.
Proof.
intros x Hx.
rewrite Hx.
simpl.
eexists. easy.
rewrite <- Hx.
intros Zx.
simpl.
split.
(* *)
apply le_IZR.
rewrite IZR_Zpower.
2: now apply Zlt_0_le_0_pred.
rewrite abs_IZR, <- scaled_mantissa_generic with (1 := Hx).
apply Rmult_le_reg_r with (bpow (cexp beta FLX_exp x)).
apply bpow_gt_0.
rewrite <- bpow_plus.
rewrite <- scaled_mantissa_abs.
rewrite <- cexp_abs.
rewrite scaled_mantissa_mult_bpow.
unfold cexp, FLX_exp.
rewrite mag_abs.
ring_simplify (prec - 1 + (mag beta x - prec))%Z.
destruct (mag beta x) as (ex,Ex).
now apply Ex.
(* *)
apply lt_IZR.
rewrite IZR_Zpower.
2: now apply Zlt_le_weak.
rewrite abs_IZR, <- scaled_mantissa_generic with (1 := Hx).
apply Rmult_lt_reg_r with (bpow (cexp beta FLX_exp x)).
apply bpow_gt_0.
rewrite <- bpow_plus.
rewrite <- scaled_mantissa_abs.
rewrite <- cexp_abs.
rewrite scaled_mantissa_mult_bpow.
unfold cexp, FLX_exp.
rewrite mag_abs.
ring_simplify (prec + (mag beta x - prec))%Z.
destruct (mag beta x) as (ex,Ex).
now apply Ex.
Qed.

Theorem FLXN_format_satisfies_any :
  satisfies_any FLXN_format.
Proof.
refine (satisfies_any_eq _ _ _ (generic_format_satisfies_any beta FLX_exp)).
split ; intros H.
now apply FLXN_format_generic.
now apply generic_format_FLXN.
Qed.

Lemma negligible_exp_FLX :
   negligible_exp FLX_exp = None.
Proof.
case (negligible_exp_spec FLX_exp).
intros _; reflexivity.
intros n H2; contradict H2.
unfold FLX_exp; unfold Prec_gt_0 in prec_gt_0_; omega.
Qed.

Theorem ulp_FLX_0: (ulp beta FLX_exp 0 = 0)%R.
Proof.
unfold ulp; rewrite Req_bool_true; trivial.
rewrite negligible_exp_FLX; easy.
Qed.

Theorem eq_0_round_0_FLX :
   forall rnd {Vr: Valid_rnd rnd} x,
     round beta FLX_exp rnd x = 0%R -> x = 0%R.
Proof.
intros rnd Hr x.
apply eq_0_round_0_negligible_exp; try assumption.
apply FLX_exp_valid.
apply negligible_exp_FLX.
Qed.

Theorem gt_0_round_gt_0_FLX :
   forall rnd {Vr: Valid_rnd rnd} x,
     (0 < x)%R -> (0 < round beta FLX_exp rnd x)%R.
Proof with auto with typeclass_instances.
intros rnd Hr x Hx.
assert (K: (0 <= round beta FLX_exp rnd x)%R).
rewrite <- (round_0 beta FLX_exp rnd).
apply round_le... now apply Rlt_le.
destruct K; try easy.
absurd (x = 0)%R.
now apply Rgt_not_eq.
apply eq_0_round_0_FLX with rnd...
Qed.


Theorem ulp_FLX_le :
  forall x, (ulp beta FLX_exp x <= Rabs x * bpow (1-prec))%R.
Proof.
intros x; case (Req_dec x 0); intros Hx.
rewrite Hx, ulp_FLX_0, Rabs_R0.
right; ring.
rewrite ulp_neq_0; try exact Hx.
unfold cexp, FLX_exp.
replace (mag beta x - prec)%Z with ((mag beta x - 1) + (1-prec))%Z by ring.
rewrite bpow_plus.
apply Rmult_le_compat_r.
apply bpow_ge_0.
now apply bpow_mag_le.
Qed.

Theorem ulp_FLX_ge :
  forall x, (Rabs x * bpow (-prec) <= ulp beta FLX_exp x)%R.
Proof.
intros x; case (Req_dec x 0); intros Hx.
rewrite Hx, ulp_FLX_0, Rabs_R0.
right; ring.
rewrite ulp_neq_0; try exact Hx.
unfold cexp, FLX_exp.
unfold Zminus; rewrite bpow_plus.
apply Rmult_le_compat_r.
apply bpow_ge_0.
left; now apply bpow_mag_gt.
Qed.

(** FLX is a nice format: it has a monotone exponent... *)
Global Instance FLX_exp_monotone : Monotone_exp FLX_exp.
Proof.
intros ex ey Hxy.
now apply Zplus_le_compat_r.
Qed.

(** and it allows a rounding to nearest, ties to even. *)
Hypothesis NE_prop : Z.even beta = false \/ (1 < prec)%Z.

Global Instance exists_NE_FLX : Exists_NE beta FLX_exp.
Proof.
destruct NE_prop as [H|H].
now left.
right.
unfold FLX_exp.
split ; omega.
Qed.

End RND_FLX.
