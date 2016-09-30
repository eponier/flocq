Require Import Float.Veltkamp.
Require Import Float.RND.
Require Export Float.Fast2Sum.
Require Import Float.TwoSum.
Require Import Float.FmaErr.

Require Import Fcore.
Require Import Fprop_plus_error.
Require Import Fprop_mult_error.
Require Import Ftranslate_flocq2Pff.

Open Scope R_scope.

Section FTS.
Variable emin prec : Z.
Hypothesis precisionNotZero : (1 < prec)%Z.
Context { prec_gt_0_ : Prec_gt_0 prec }.
Hypothesis emin_neg: (emin <= 0)%Z.

Notation format := (generic_format radix2 (FLT_exp emin prec)).
Notation round_flt :=(round radix2 (FLT_exp emin prec) ZnearestE).
Notation bpow e := (bpow radix2 e).

(** inputs *)
Variable x y:R.
Hypothesis Fx: format x.
Hypothesis Fy: format y.

(** algorithm *)
Let a := round_flt (x+y).
Let b := round_flt (round_flt (a-x)-y).

(** Theorem *)
Theorem FastTwoSum: Rabs y <= Rabs x -> a-b=x+y.
Proof with auto with typeclass_instances.
intros H.
(* *)
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero x)
  as (fx,(Hfx,Hfx')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero y)
  as (fy,(Hfy,Hfy')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
(* *)
pose (Iplus := fun (f g:Float.float) => 
  Fnormalize radix2 (make_bound radix2 prec emin) (Zabs_nat prec)
   (Float.Float 
     (Ztrunc (scaled_mantissa radix2 (FLT_exp (emin) prec) (round_flt (FtoR radix2 f+FtoR radix2 g))))
     (canonic_exp radix2 (FLT_exp (emin) prec) (round_flt (FtoR radix2 f+FtoR radix2 g))))).
pose (Iminus := fun (f g:Float.float) => 
  Fnormalize radix2 (make_bound radix2 prec emin) (Zabs_nat prec)
   (Float.Float 
      (Ztrunc (scaled_mantissa radix2 (FLT_exp (emin) prec) (round_flt (FtoR radix2 f-FtoR radix2 g))))
      (canonic_exp radix2 (FLT_exp (emin) prec) (round_flt (FtoR radix2 f-FtoR radix2 g))))).
assert (H1: forall x y, FtoR 2 (Iplus x y) = round_flt (FtoR 2 x + FtoR 2 y)).
clear -prec_gt_0_; intros x y.
assert (format (round_flt (FtoR 2 x + FtoR 2 y))).
apply generic_format_round...
unfold Iplus; rewrite FnormalizeCorrect.
2: apply radix_gt_1.
rewrite H; change 2%Z with (radix_val radix2).
apply FtoR_F2R; try easy.
assert (H2: forall x y, FtoR 2 (Iminus x y) = round_flt (FtoR 2 x - FtoR 2 y)).
clear -prec_gt_0_; intros x y.
assert (format (round_flt (FtoR 2 x - FtoR 2 y))).
apply generic_format_round...
unfold Iminus; rewrite FnormalizeCorrect.
2: apply radix_gt_1.
rewrite H; change 2%Z with (radix_val radix2).
apply FtoR_F2R; try easy.
(* *)
assert (K: FtoR 2 (Iminus fy (Iminus (Iplus fx fy) fx)) =
       FtoR 2 fx + FtoR 2 fy - FtoR 2 (Iplus fx fy)).
apply Dekker with (make_bound radix2 prec emin) (Zabs_nat prec); try assumption.
apply Nat2Z.inj_lt.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
(* . *)
intros p q Fp Fq.
destruct round_NE_is_pff_round with radix2 (make_bound radix2 prec emin) prec (FtoR 2 p +FtoR 2 q)
   as (f, (L1,(L2,L3))); try assumption.
apply make_bound_p; omega.
generalize ClosestCompatible; unfold CompatibleP.
intros T; apply T with (FtoR 2 p + FtoR 2 q) f; clear T; try easy.
apply L2.
change 2%Z with (radix_val radix2).
rewrite L3, H1.
rewrite make_bound_Emin; try easy.
f_equal; f_equal; ring.
unfold Iplus.
apply FnormalizeBounded.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
(* . *)
intros p q.
apply FcanonicUnique with radix2 (make_bound radix2 prec emin) (Zabs_nat prec).
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
apply FcanonicFopp.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
rewrite Fopp_correct.
rewrite 2!H1.
rewrite <- round_NE_opp.
rewrite 2!Fopp_correct.
f_equal; ring.
(* . *)
intros p q.
apply FcanonicUnique with radix2 (make_bound radix2 prec emin) (Zabs_nat prec).
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
rewrite H1,H2.
rewrite Fopp_correct.
f_equal; ring.
(* . *)
unfold Fast2Sum.FtoRradix.
change 2%Z with (radix_val radix2).
rewrite Hfx, Hfy; assumption.
(* *)
generalize K; rewrite 2!H2, H1.
change 2%Z with (radix_val radix2).
rewrite Hfx, Hfy; fold a; unfold b; intros K'.
apply Rplus_eq_reg_r with (-a).
apply trans_eq with (round_flt (y - round_flt (a - x))).
2: rewrite K'; ring.
ring_simplify.
rewrite <- round_NE_opp.
f_equal; ring.
Qed.

End FTS.

Section TS.

Variable emin prec : Z.
Hypothesis precisionNotZero : (1 < prec)%Z.
Context { prec_gt_0_ : Prec_gt_0 prec }.
Hypothesis emin_neg: (emin <= 0)%Z.

Notation format := (generic_format radix2 (FLT_exp emin prec)).
Notation round_flt :=(round radix2 (FLT_exp emin prec) ZnearestE).
Notation bpow e := (bpow radix2 e).

(** inputs *)
Variable x y:R.
Hypothesis Fx: format x.
Hypothesis Fy: format y.

(** algorithm *)
Let a  := round_flt (x+y).
Let x' := round_flt (a-x).
Let dx := round_flt (x- round_flt (a-x')).
Let dy := round_flt (y - x').
Let b  := round_flt (dx + dy).

(** Theorem *)
Theorem TwoSum: a+b=x+y.
Proof with auto with typeclass_instances.
(* *)
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero x)
  as (fx,(Hfx,Hfx')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero y)
  as (fy,(Hfy,Hfy')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
(* *)
pose (Iplus := fun (f g:Float.float) => 
  Fnormalize radix2 (make_bound radix2 prec emin) (Zabs_nat prec)
   (Float.Float 
     (Ztrunc (scaled_mantissa radix2 (FLT_exp (emin) prec) (round_flt (FtoR radix2 f+FtoR radix2 g))))
     (canonic_exp radix2 (FLT_exp (emin) prec) (round_flt (FtoR radix2 f+FtoR radix2 g))))).
pose (Iminus := fun (f g:Float.float) => 
  Fnormalize radix2 (make_bound radix2 prec emin) (Zabs_nat prec)
   (Float.Float 
      (Ztrunc (scaled_mantissa radix2 (FLT_exp (emin) prec) (round_flt (FtoR radix2 f-FtoR radix2 g))))
      (canonic_exp radix2 (FLT_exp (emin) prec) (round_flt (FtoR radix2 f-FtoR radix2 g))))).
assert (H1: forall x y, FtoR 2 (Iplus x y) = round_flt (FtoR 2 x + FtoR 2 y)).
clear -prec_gt_0_; intros x y.
assert (format (round_flt (FtoR 2 x + FtoR 2 y))).
apply generic_format_round...
unfold Iplus; rewrite FnormalizeCorrect.
2: apply radix_gt_1.
rewrite H; change 2%Z with (radix_val radix2).
apply FtoR_F2R; try easy.
assert (H2: forall x y, FtoR 2 (Iminus x y) = round_flt (FtoR 2 x - FtoR 2 y)).
clear -prec_gt_0_; intros x y.
assert (format (round_flt (FtoR 2 x - FtoR 2 y))).
apply generic_format_round...
unfold Iminus; rewrite FnormalizeCorrect.
2: apply radix_gt_1.
rewrite H; change 2%Z with (radix_val radix2).
apply FtoR_F2R; try easy.
(* *)
assert (K: FtoR 2 (Iplus (Iminus fx (Iminus (Iplus fx fy) (Iminus (Iplus fx fy) fx)))
            (Iminus fy (Iminus (Iplus fx fy) fx))) =
       FtoR 2 fx + FtoR 2 fy - FtoR 2 (Iplus fx fy)).
apply Knuth with (make_bound radix2 prec emin) (Zabs_nat prec); try assumption.
apply Nat2Z.inj_lt.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
(* . *)
intros p q Fp Fq.
destruct round_NE_is_pff_round with radix2 (make_bound radix2 prec emin) prec (FtoR 2 p +FtoR 2 q)
   as (f, (L1,(L2,L3))); try assumption.
apply make_bound_p; omega.
generalize ClosestCompatible; unfold CompatibleP.
intros T; apply T with (FtoR 2 p + FtoR 2 q) f; clear T; try easy.
apply L2.
change 2%Z with (radix_val radix2).
rewrite L3, H1.
rewrite make_bound_Emin; try easy.
f_equal; f_equal; ring.
unfold Iplus.
apply FnormalizeBounded.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
(* . *)
unfold TwoSum.FtoRradix.
intros p q r s Fp Fq Fr Fs M1 M2.
now rewrite 2!H1, M1, M2.
(* . *)
intros p q.
apply FcanonicUnique with radix2 (make_bound radix2 prec emin) (Zabs_nat prec).
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
rewrite 2!H1.
f_equal; ring.
(* . *)
intros p q.
apply FcanonicUnique with radix2 (make_bound radix2 prec emin) (Zabs_nat prec).
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
apply FcanonicFopp.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
rewrite Fopp_correct.
rewrite 2!H1.
rewrite <- round_NE_opp.
rewrite 2!Fopp_correct.
f_equal; ring.
(* . *)
intros p q.
apply FcanonicUnique with radix2 (make_bound radix2 prec emin) (Zabs_nat prec).
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
apply FnormalizeCanonic.
apply radix_gt_1.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
replace emin with (-dExp (make_bound radix2 prec emin))%Z at 2 4.
apply format_is_pff_format'; try omega.
apply make_bound_p; omega.
rewrite make_bound_Emin; try easy.
rewrite Zopp_involutive.
apply generic_format_round...
rewrite make_bound_Emin; omega.
rewrite H1,H2.
rewrite Fopp_correct.
f_equal; ring.
(* *)
generalize K; rewrite 2!H1, 5!H2, H1.
change 2%Z with (radix_val radix2).
rewrite Hfx, Hfy.
fold a; fold x'; fold dx; fold dy; fold b.
intros K'; rewrite K'; ring.
Qed.


End TS.




Section Veltkamp.

Variable beta : radix.
Variable emin prec : Z.
Variable s:Z.
Hypothesis precisionGe3 : (3 <= prec)%Z.
Context { prec_gt_0_ : Prec_gt_0 prec }.
Hypothesis emin_neg: (emin <= 0)%Z.

Notation format := (generic_format beta (FLT_exp emin prec)).
Notation round_flt :=(round beta (FLT_exp emin prec) ZnearestE).
Notation round_flt_s :=(round beta (FLT_exp emin (prec-s)) ZnearestE).
Notation ulp_flt :=(ulp beta (FLT_exp emin prec)).
Notation bpow e := (bpow beta e).

(** inputs *)
Hypothesis SLe: (2 <= s)%Z.
Hypothesis SGe: (s <= prec-2)%Z.
Variable x:R.
Hypothesis Fx: format x.

(** algorithm *)
Let p := round_flt (x*(bpow s+1)).
Let q:= round_flt (x-p).
Let hx:=round_flt (q+p).
Let tx:=round_flt (x-hx).


(** Theorems *)

Lemma C_format: format (bpow s +1).
Proof with auto with typeclass_instances.
apply generic_format_FLT.
unfold FLT_format.
exists (Fcore_defs.Float beta (Zpower beta s+1)%Z 0%Z).
split; try split; simpl; try easy.
unfold F2R; simpl.
rewrite Z2R_plus, Z2R_Zpower; try omega.
simpl; ring.
rewrite Zabs_eq.
apply Zle_lt_trans with (beta^s+beta^0)%Z.
simpl; omega.
apply Zle_lt_trans with (beta^s+beta^s)%Z.
apply Zplus_le_compat_l.
apply Zpower_le; omega.
apply Zle_lt_trans with (2*beta^s)%Z.
omega.
apply Zle_lt_trans with (beta^1*beta^s)%Z.
apply Zmult_le_compat_r.
rewrite Z.pow_1_r. 
apply Zle_bool_imp_le; apply beta.
apply Zpower_ge_0.
rewrite <- Zpower_plus; try omega.
apply Zpower_lt; omega.
apply Zle_trans with (beta^s)%Z; try omega.
apply Zpower_ge_0.
Qed.


Theorem Veltkamp_Even: hx = round_flt_s x.
Proof with auto with typeclass_instances.
assert (precisionNotZero : (1 < prec)%Z) by omega.
destruct (format_is_pff_format beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero x)
  as (fx,(Hfx,Hfx')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (round_NE_is_pff_round beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero 
  (x*(bpow s+1)))
  as (fp,(Hfp, (Hfp',Hfp''))).
rewrite make_bound_Emin in Hfp''; try assumption.
replace (--emin)%Z with emin in Hfp'' by omega.
destruct (round_NE_is_pff_round beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero 
  (x-p))
  as (fq,(Hfq, (Hfq',Hfq''))).
rewrite make_bound_Emin in Hfq''; try assumption.
replace (--emin)%Z with emin in Hfq'' by omega.
destruct (round_NE_is_pff_round beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero 
  (q+p))
  as (fhx,(Hfhx, (Hfhx',Hfhx''))).
rewrite make_bound_Emin in Hfhx''; try assumption.
replace (--emin)%Z with emin in Hfhx'' by omega.
(* *)
destruct VeltkampEven with beta (make_bound beta prec emin) (Zabs_nat s) 
   (Zabs_nat prec) fx fp fq fhx as (hx', (H1,H2)); try assumption.
apply radix_gt_1.
apply make_bound_p; omega.
replace 2%nat with (Zabs_nat 2) by easy.
apply Zabs_nat_le; omega.
apply Nat2Z.inj_le.
rewrite inj_abs; try omega.
rewrite inj_minus, Zmax_r; rewrite inj_abs; simpl; omega.
rewrite Hfx; rewrite inj_abs; try omega.
rewrite bpow_powerRZ in Hfp'; rewrite Z2R_IZR in Hfp'; exact Hfp'.
rewrite Hfx, Hfp''; assumption.
rewrite Hfp'', Hfq''; assumption.
(* *)
unfold hx; rewrite <- Hfhx'', <- H1.
apply trans_eq with (FtoR beta (RND_EvenClosest 
 (make_bound beta (prec-s) emin) beta (Zabs_nat (prec-s)) x)).
generalize (EvenClosestUniqueP (make_bound beta (prec-s) emin) beta 
   (Zabs_nat (prec-s))); unfold UniqueP; intros T.
apply T with x; clear T.
apply radix_gt_1.
apply Nat2Z.inj_lt.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
rewrite <- Hfx.
replace (Zabs_nat (prec-s)) with (Zabs_nat prec - Zabs_nat s)%nat.
replace (make_bound beta (prec - s) emin) with
  (Bound  (Pos.of_succ_nat
                 (Peano.pred
                    (Z.abs_nat
                       (Zpower_nat beta (Z.abs_nat prec - Z.abs_nat s)))))
           (dExp (make_bound beta prec emin))).
exact H2.
generalize (make_bound_Emin beta (prec-s) _ emin_neg).
generalize (make_bound_p beta (prec-s) emin).
destruct (make_bound beta (prec-s) emin) as (l1,l2).
simpl; intros H3 H4; f_equal.
apply Pos2Z.inj.
rewrite H3; try omega.
replace (Z.abs_nat (prec - s)) with (Z.abs_nat prec - Z.abs_nat s)%nat.
rewrite <- (p'GivesBound beta (make_bound beta prec emin) (Zabs_nat s) (Zabs_nat prec)) at 2.
simpl; easy.
apply radix_gt_1.
apply Nat2Z.inj.
rewrite inj_abs; try omega.
rewrite inj_minus, Zmax_r; rewrite 2!inj_abs; omega.
apply N2Z.inj.
rewrite H4.
rewrite Zabs2N.id_abs.
now apply Z.abs_neq.
apply Nat2Z.inj.
rewrite inj_abs; try omega.
rewrite inj_minus, Zmax_r; rewrite 2!inj_abs; omega.
apply RND_EvenClosest_correct.
apply radix_gt_1.
apply Nat2Z.inj_lt.
rewrite inj_abs; simpl; omega.
apply make_bound_p; omega.
rewrite pff_round_NE_is_round; try omega.
f_equal; f_equal.
rewrite make_bound_Emin; omega.
apply make_bound_p; omega.
Qed.


Theorem Veltkamp_Tail:
 x = hx+tx /\  generic_format beta (FLT_exp emin s) tx.
Proof with auto with typeclass_instances.
assert (precisionNotZero : (1 < prec)%Z) by omega.
destruct (format_is_pff_format beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero x)
  as (fx,(Hfx,Hfx')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (round_NE_is_pff_round beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero 
  (x*(bpow s+1)))
  as (fp,(Hfp, (Hfp',Hfp''))).
rewrite make_bound_Emin in Hfp''; try assumption.
replace (--emin)%Z with emin in Hfp'' by omega.
destruct (round_NE_is_pff_round beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero 
  (x-p))
  as (fq,(Hfq, (Hfq',Hfq''))).
rewrite make_bound_Emin in Hfq''; try assumption.
replace (--emin)%Z with emin in Hfq'' by omega.
destruct (round_NE_is_pff_round beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero 
  (q+p))
  as (fhx,(Hfhx, (Hfhx',Hfhx''))).
rewrite make_bound_Emin in Hfhx''; try assumption.
replace (--emin)%Z with emin in Hfhx'' by omega.
destruct (round_NE_is_pff_round beta (make_bound beta prec emin)
   prec (make_bound_p beta prec emin precisionNotZero) precisionNotZero 
  (x-hx))
  as (ftx,(Hftx, (Hftx',Hftx''))).
rewrite make_bound_Emin in Hftx''; try assumption.
replace (--emin)%Z with emin in Hftx'' by omega.
(* *)
destruct Veltkamp_tail with beta (make_bound beta prec emin) (Zabs_nat s) 
   (Zabs_nat prec) fx fp fq fhx ftx as (tx', (H1,(H2,(H3,H4)))); try assumption.
apply radix_gt_1.
apply make_bound_p; omega.
replace 2%nat with (Zabs_nat 2) by easy.
apply Zabs_nat_le; omega.
apply Nat2Z.inj_le.
rewrite inj_abs; try omega.
rewrite inj_minus, Zmax_r; rewrite inj_abs; simpl; omega.
rewrite Hfx; rewrite inj_abs; try omega.
rewrite bpow_powerRZ in Hfp'; rewrite Z2R_IZR in Hfp'; apply Hfp'.
rewrite Hfx, Hfp''; apply Hfq'.
rewrite Hfp'', Hfq''; apply Hfhx'.
rewrite Hfhx'', Hfx; apply Hftx'.
(* *)
split.
rewrite <- Hfx, <-H2, Hfhx'', H1, Hftx''; easy.
unfold tx; rewrite <- Hftx'', <- H1.
replace emin with (-dExp (Bound
       (Pos.of_succ_nat
                 (Peano.pred (Z.abs_nat (Zpower_nat beta (Z.abs_nat s)))))
       (dExp (make_bound beta prec emin))))%Z.
apply pff_format_is_format; try assumption; try omega.
simpl.
rewrite Zpos_P_of_succ_nat, inj_pred.
rewrite <- Zsucc_pred.
apply inj_abs.
apply Zpower_NR0.
apply Zlt_le_weak; apply radix_gt_0.
apply notEqLt, lt_Zlt_inv.
rewrite inj_abs.
apply Zpower_nat_less.
apply radix_gt_1.
apply Zpower_NR0.
apply Zlt_le_weak; apply radix_gt_0.
simpl.
rewrite Zabs2N.id_abs.
rewrite Z.abs_neq; omega.
Qed.

End Veltkamp.

Section Dekker.


(* todo *)

End Dekker.

Section ErrFMA.

Variable emin prec : Z.
Hypothesis precisionGe3 : (3 <= prec)%Z.
Context { prec_gt_0_ : Prec_gt_0 prec }.
Hypothesis emin_neg: (emin <= 0)%Z.

Notation format := (generic_format radix2 (FLT_exp emin prec)).
Notation round_flt :=(round radix2 (FLT_exp emin prec) ZnearestE).
Notation ulp_flt :=(ulp radix2 (FLT_exp emin prec)).

(** inputs *)
Variable a x y:R.
Hypothesis Fa: format a.
Hypothesis Fx: format x.
Hypothesis Fy: format y.

(** algorithm *)
Let r1 := round_flt (a*x+y).
Let u1 := round_flt (a*x).
Let u2 := a*x-u1.
Let alpha1 := round_flt (y+u2).
Let alpha2 := (y+u2)-alpha1.
Let beta1 := round_flt (u1+alpha1).
Let beta2 := (u1+alpha1) - beta1.
Let gamma := round_flt (round_flt (beta1-r1)+beta2).
Let r2 := round_flt (gamma+alpha2).
Let r3 := (gamma+alpha2) -r2.

(** Non-underflow hypotheses *)
Hypothesis Und1: a * x = 0 \/ bpow radix2 (emin + 2 * prec - 1) <= Rabs (a * x).
Hypothesis Und2: alpha1 = 0 \/ bpow radix2 (emin + prec) <= Rabs alpha1.
Hypothesis Und3: u1 = 0 \/ bpow radix2 (emin + prec) <= Rabs u1.
Hypothesis Und4: beta1 = 0 \/ bpow radix2 (emin + prec+1) <= Rabs beta1.
Hypothesis Und5: r1 = 0 \/ bpow radix2 (emin + prec-1) <= Rabs r1.

(**************** TODO ************************************)
(* supprimer hypothèses inutiles 
   au moins Und3, mais peut-être les autres aussi.... sauf Und1 *)


(** Theorems *)
Lemma ErrFMA_bounded: format r1 /\ format r2 /\ format r3.
Proof with auto with typeclass_instances.
split.
apply generic_format_round...
split.
apply generic_format_round...
replace (r3) with (-(r2-(gamma+alpha2))) by (unfold r3; ring).
apply generic_format_opp.
apply plus_error...
apply generic_format_round...
replace (alpha2) with (-(alpha1-(y+u2))) by (unfold alpha2; ring).
apply generic_format_opp.
apply plus_error...
replace (u2) with (-(u1-(a*x))) by (unfold u2; ring).
apply generic_format_opp.
apply mult_error_FLT...
Qed.


Lemma ErrFMA_correct:
   a*x+y = r1+r2+r3.
Proof with auto with typeclass_instances.
assert (precisionNotZero : (1 < prec)%Z) by omega.
replace (r1+r2+r3) with (r1+gamma+alpha2).
2: unfold r3; ring.
assert (J1: format u2).
replace (u2) with (-(u1-(a*x))) by (unfold u2; ring).
apply generic_format_opp.
apply mult_error_FLT...
assert (J2: format alpha2).
replace (alpha2) with (-(alpha1-(y+u2))) by (unfold alpha2; ring).
apply generic_format_opp.
apply plus_error...
assert (J3: format beta2).
replace (beta2) with (-(beta1-(u1+alpha1))) by (unfold beta2; ring).
apply generic_format_opp.
apply plus_error...
apply generic_format_round...
apply generic_format_round...
(* values *)
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero a)
  as (fa,(Hfa,Hfa')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero x)
  as (fx,(Hfx,Hfx')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero y)
  as (fy,(Hfy,Hfy')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero u2)
  as (fu2,(Hfu2,Hfu2')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero alpha2)
  as (fal2,(Hfal2,Hfal2')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
destruct (format_is_pff_format radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero beta2)
  as (fbe2,(Hfbe2,Hfbe2')).
rewrite make_bound_Emin; try assumption.
replace (--emin)%Z with emin by omega; assumption.
rewrite <- Hfa, <- Hfx, <- Hfy, <- Hfal2.
(* roundings *)
destruct (round_NE_is_pff_round radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero (a*x+y))
  as (fr1,(Hfr1, (Hfr1',Hfr1''))).
rewrite make_bound_Emin in Hfr1''; try assumption.
replace (--emin)%Z with emin in Hfr1'' by omega.
destruct (round_NE_is_pff_round radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero (a*x))
  as (fu1,(Hfu1, (Hfu1',Hfu1''))).
rewrite make_bound_Emin in Hfu1''; try assumption.
replace (--emin)%Z with emin in Hfu1'' by omega.
destruct (round_NE_is_pff_round radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero (y+u2))
  as (fal1,(Hfal1, (Hfal1',Hfal1''))).
rewrite make_bound_Emin in Hfal1''; try assumption.
replace (--emin)%Z with emin in Hfal1'' by omega.
destruct (round_NE_is_pff_round radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero (u1+alpha1))
  as (fbe1,(Hfbe1, (Hfbe1',Hfbe1''))).
rewrite make_bound_Emin in Hfbe1''; try assumption.
replace (--emin)%Z with emin in Hfbe1'' by omega.
destruct (round_NE_is_pff_round radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero (beta1-r1))
  as (ff,(Hff, (Hff',Hff''))).
rewrite make_bound_Emin in Hff''; try assumption.
replace (--emin)%Z with emin in Hff'' by omega.
destruct (round_NE_is_pff_round radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero (FtoR 2 ff+beta2))
  as (fga,(Hfga, (Hfga',Hfga''))).
rewrite make_bound_Emin in Hfga''; try assumption.
replace (--emin)%Z with emin in Hfga'' by omega.
destruct (round_NE_is_pff_round radix2 (make_bound radix2 prec emin)
   prec (make_bound_p radix2 prec emin precisionNotZero) precisionNotZero (gamma+alpha2))
  as (fr2,(Hfr2, (Hfr2',Hfr2''))).
rewrite make_bound_Emin in Hfr2''; try assumption.
replace (--emin)%Z with emin in Hfr2'' by omega.
unfold r1; rewrite <- Hfr1''.
change 2%Z with (radix_val radix2) in Hfga''.
unfold gamma; rewrite <- Hff'', <- Hfga''.
(* *)
apply FmaErr_Even with (make_bound radix2 prec emin) (Z.abs_nat prec) fu1 fu2 fal1 fbe1 fbe2 ff;
  try assumption.
apply radix_gt_1.
apply make_bound_p; omega.
replace 3%nat with (Z.abs_nat 3).
apply Zabs_nat_le; omega.
now unfold Z.abs_nat, Pos.to_nat.
now exists 1%Z.
(* . underflow *)
rewrite Hfal1''; fold alpha1.
case Und2; intros V;[now right|left].
apply FloatFexp_gt with radix2 (make_bound radix2 prec emin) prec.
apply make_bound_p; omega.
omega.
apply FcanonicBound with (1:=Hfal1).
rewrite Hfal1''; fold alpha1.
now rewrite make_bound_Emin, Zopp_involutive.
rewrite Hfu1''; fold u1.
case Und3; intros V;[now right|left].
apply FloatFexp_gt with radix2 (make_bound radix2 prec emin) prec.
apply make_bound_p; omega.
omega.
apply FcanonicBound with (1:=Hfu1).
rewrite Hfu1''; fold u1.
now rewrite make_bound_Emin, Zopp_involutive.
rewrite Hfbe1''; fold beta1.
case Und4; intros V;[now right|left].
apply FloatFexp_gt with radix2 (make_bound radix2 prec emin) prec.
apply make_bound_p; omega.
omega.
apply FcanonicBound with (1:=Hfbe1).
rewrite Hfbe1''; fold beta1.
rewrite make_bound_Emin, Zopp_involutive; try assumption.
apply Rle_trans with (2:=V); right.
f_equal; ring.
rewrite Hfr1''; fold r1.
case Und5; intros V;[now right|left].
apply CanonicGeNormal with prec; try assumption.
apply make_bound_p; omega.
rewrite Hfr1''; fold r1.
rewrite make_bound_Emin, Zopp_involutive; try assumption.

admit. (* underflow Fexp a + Fexp x >= emin *)

(* . end of underflow *)
rewrite Hfa, Hfx; apply Hfu1'.
now rewrite Hfu2, Hfa, Hfx, Hfu1''.
rewrite Hfy, Hfu2; apply Hfal1'.
now rewrite Hfal2, Hfy, Hfu2, Hfal1''.
now rewrite Hfbe2, Hfu1'', Hfal1'', Hfbe1''.
rewrite Hfbe1'', Hfr1''; apply Hff'.
rewrite Hfbe2; apply Hfga'.
rewrite Hfa, Hfx, Hfy; apply Hfr1'.
rewrite Hfu1'', Hfal1''; apply Hfbe1'.
Admitted.

End ErrFMA.