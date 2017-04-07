/*
 * Attitude_quadrotor.cpp
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "Attitude_quadrotor".
 *
 * Model version              : 1.197
 * Simulink Coder version : 8.11 (R2016b) 25-Aug-2016
 * C++ source code generated on : Fri Mar 31 17:06:36 2017
 *
 * Target selection: grt.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: ARM Compatible->ARM Cortex
 * Code generation objective: Execution efficiency
 * Validation result: Not run
 */

#include "Attitude_quadrotor.h"
#include "Attitude_quadrotor_private.h"

/*
 * This function updates continuous states using the ODE2 fixed-step
 * solver algorithm
 */
void Attitude_quadrotorModelClass::rt_ertODEUpdateContinuousStates(RTWSolverInfo
  *si )
{
  time_T tnew = rtsiGetSolverStopTime(si);
  time_T h = rtsiGetStepSize(si);
  real_T *x = rtsiGetContStates(si);
  ODE2_IntgData *id = (ODE2_IntgData *)rtsiGetSolverData(si);
  real_T *y = id->y;
  real_T *f0 = id->f[0];
  real_T *f1 = id->f[1];
  real_T temp;
  int_T i;
  int_T nXc = 9;
  rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

  /* Save the state values at time t in y, we'll use x as ynew. */
  (void) memcpy(y, x,
                (uint_T)nXc*sizeof(real_T));

  /* Assumes that rtsiSetT and ModelOutputs are up-to-date */
  /* f0 = f(t,y) */
  rtsiSetdX(si, f0);
  Attitude_quadrotor_derivatives();

  /* f1 = f(t + h, y + h*f0) */
  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (h*f0[i]);
  }

  rtsiSetT(si, tnew);
  rtsiSetdX(si, f1);
  this->step();
  Attitude_quadrotor_derivatives();

  /* tnew = t + h
     ynew = y + (h/2)*(f0 + f1) */
  temp = 0.5*h;
  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + temp*(f0[i] + f1[i]);
  }

  rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

/* Model step function */
void Attitude_quadrotorModelClass::step()
{
  real_T Cphi;
  real_T Ctheta;
  real_T rtb_e_p;
  real_T rtb_rates_body[3];
  real_T rtb_e_q;
  real_T rtb_Saturate_a;
  real_T rtb_Sum;
  real_T rtb_e_r;
  real_T rtb_Saturate_p;
  real_T rtb_Sum_e;
  real_T tmp[9];
  int32_T i;
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* set solver stop time */
    if (!((&Attitude_quadrotor_M)->Timing.clockTick0+1)) {
      rtsiSetSolverStopTime(&(&Attitude_quadrotor_M)->solverInfo,
                            (((&Attitude_quadrotor_M)->Timing.clockTickH0 + 1) *
        (&Attitude_quadrotor_M)->Timing.stepSize0 * 4294967296.0));
    } else {
      rtsiSetSolverStopTime(&(&Attitude_quadrotor_M)->solverInfo,
                            (((&Attitude_quadrotor_M)->Timing.clockTick0 + 1) *
        (&Attitude_quadrotor_M)->Timing.stepSize0 + (&Attitude_quadrotor_M)
        ->Timing.clockTickH0 * (&Attitude_quadrotor_M)->Timing.stepSize0 *
        4294967296.0));
    }
  }                                    /* end MajorTimeStep */

  /* Update absolute time of base rate at minor time step */
  if (rtmIsMinorTimeStep((&Attitude_quadrotor_M))) {
    (&Attitude_quadrotor_M)->Timing.t[0] = rtsiGetT(&(&Attitude_quadrotor_M)
      ->solverInfo);
  }

  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* Sum: '<Root>/Sum' incorporates:
     *  Inport: '<Root>/attitude'
     *  Inport: '<Root>/setpoint_attitude'
     */
    rtb_e_p = Attitude_quadrotor_U.setpoint_attitude[0] -
      Attitude_quadrotor_U.attitude[0];

    /* Gain: '<S3>/Proportional Gain' */
    Attitude_quadrotor_B.ProportionalGain = Attitude_quadrotor_P.KP_ROLL *
      rtb_e_p;

    /* Gain: '<S3>/Derivative Gain' */
    Attitude_quadrotor_B.DerivativeGain = Attitude_quadrotor_P.KD_ROLL * rtb_e_p;
  }

  /* Gain: '<S3>/Filter Coefficient' incorporates:
   *  Integrator: '<S3>/Filter'
   *  Sum: '<S3>/SumD'
   */
  Attitude_quadrotor_B.FilterCoefficient = (Attitude_quadrotor_B.DerivativeGain
    - Attitude_quadrotor_X.Filter_CSTATE) * Attitude_quadrotor_P.ANG_N;

  /* Sum: '<S3>/Sum' */
  Cphi = Attitude_quadrotor_B.ProportionalGain +
    Attitude_quadrotor_B.FilterCoefficient;

  /* Saturate: '<S3>/Saturate' */
  if (Cphi > Attitude_quadrotor_P.MAX_P) {
    Attitude_quadrotor_B.Saturate = Attitude_quadrotor_P.MAX_P;
  } else if (Cphi < Attitude_quadrotor_P.MIN_P) {
    Attitude_quadrotor_B.Saturate = Attitude_quadrotor_P.MIN_P;
  } else {
    Attitude_quadrotor_B.Saturate = Cphi;
  }

  /* End of Saturate: '<S3>/Saturate' */
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* Sum: '<Root>/Sum1' incorporates:
     *  Inport: '<Root>/attitude'
     *  Inport: '<Root>/setpoint_attitude'
     */
    rtb_e_p = Attitude_quadrotor_U.setpoint_attitude[1] -
      Attitude_quadrotor_U.attitude[1];

    /* Gain: '<S2>/Proportional Gain' */
    Attitude_quadrotor_B.ProportionalGain_p = Attitude_quadrotor_P.KP_PITCH *
      rtb_e_p;

    /* Gain: '<S2>/Derivative Gain' */
    Attitude_quadrotor_B.DerivativeGain_o = Attitude_quadrotor_P.KD_PITCH *
      rtb_e_p;
  }

  /* Gain: '<S2>/Filter Coefficient' incorporates:
   *  Integrator: '<S2>/Filter'
   *  Sum: '<S2>/SumD'
   */
  Attitude_quadrotor_B.FilterCoefficient_k =
    (Attitude_quadrotor_B.DerivativeGain_o -
     Attitude_quadrotor_X.Filter_CSTATE_o) * Attitude_quadrotor_P.ANG_N;

  /* Sum: '<S2>/Sum' */
  Cphi = Attitude_quadrotor_B.ProportionalGain_p +
    Attitude_quadrotor_B.FilterCoefficient_k;

  /* Saturate: '<S2>/Saturate' */
  if (Cphi > Attitude_quadrotor_P.MAX_Q) {
    Attitude_quadrotor_B.Saturate_k = Attitude_quadrotor_P.MAX_Q;
  } else if (Cphi < Attitude_quadrotor_P.MIN_Q) {
    Attitude_quadrotor_B.Saturate_k = Attitude_quadrotor_P.MIN_Q;
  } else {
    Attitude_quadrotor_B.Saturate_k = Cphi;
  }

  /* End of Saturate: '<S2>/Saturate' */
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* Sum: '<Root>/Sum2' incorporates:
     *  Inport: '<Root>/attitude'
     *  Inport: '<Root>/setpoint_attitude'
     */
    rtb_e_p = Attitude_quadrotor_U.setpoint_attitude[2] -
      Attitude_quadrotor_U.attitude[2];

    /* Gain: '<S4>/Proportional Gain' */
    Attitude_quadrotor_B.ProportionalGain_g = Attitude_quadrotor_P.KP_YAW *
      rtb_e_p;

    /* Gain: '<S4>/Derivative Gain' */
    Attitude_quadrotor_B.DerivativeGain_l = Attitude_quadrotor_P.KD_YAW *
      rtb_e_p;
  }

  /* Gain: '<S4>/Filter Coefficient' incorporates:
   *  Integrator: '<S4>/Filter'
   *  Sum: '<S4>/SumD'
   */
  Attitude_quadrotor_B.FilterCoefficient_i =
    (Attitude_quadrotor_B.DerivativeGain_l -
     Attitude_quadrotor_X.Filter_CSTATE_j) * Attitude_quadrotor_P.ANG_N;

  /* Sum: '<S4>/Sum' */
  Attitude_quadrotor_B.Sum = Attitude_quadrotor_B.ProportionalGain_g +
    Attitude_quadrotor_B.FilterCoefficient_i;
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* MATLAB Function: '<Root>/Earth2Body' incorporates:
     *  Inport: '<Root>/attitude'
     *  SignalConversion: '<S1>/TmpSignal ConversionAt SFunction Inport2'
     */
    /* MATLAB Function 'Earth2Body': '<S1>:1' */
    /* '<S1>:1:3' */
    /* '<S1>:1:4' */
    /* '<S1>:1:6' */
    rtb_e_p = sin(Attitude_quadrotor_U.attitude[0]);

    /* '<S1>:1:7' */
    Cphi = cos(Attitude_quadrotor_U.attitude[0]);

    /* '<S1>:1:8' */
    /* '<S1>:1:9' */
    Ctheta = cos(Attitude_quadrotor_U.attitude[1]);

    /* '<S1>:1:11' */
    /* '<S1>:1:15' */
    tmp[0] = 1.0;
    tmp[3] = 0.0;
    tmp[6] = -sin(Attitude_quadrotor_U.attitude[1]);
    tmp[1] = 0.0;
    tmp[4] = Cphi;
    tmp[7] = rtb_e_p * Ctheta;
    tmp[2] = 0.0;
    tmp[5] = -rtb_e_p;
    tmp[8] = Cphi * Ctheta;
    for (i = 0; i < 3; i++) {
      rtb_rates_body[i] = tmp[i + 6] * Attitude_quadrotor_B.Sum + (tmp[i + 3] *
        Attitude_quadrotor_B.Saturate_k + tmp[i] * Attitude_quadrotor_B.Saturate);
    }

    /* End of MATLAB Function: '<Root>/Earth2Body' */

    /* Sum: '<Root>/Sum4' incorporates:
     *  Inport: '<Root>/rates'
     */
    rtb_e_p = rtb_rates_body[0] - Attitude_quadrotor_U.rates[0];

    /* Gain: '<S5>/Proportional Gain' */
    Attitude_quadrotor_B.ProportionalGain_m = Attitude_quadrotor_P.KP_P *
      rtb_e_p;

    /* Gain: '<S5>/Derivative Gain' */
    Attitude_quadrotor_B.DerivativeGain_b = Attitude_quadrotor_P.KD_P * rtb_e_p;
  }

  /* Gain: '<S5>/Filter Coefficient' incorporates:
   *  Integrator: '<S5>/Filter'
   *  Sum: '<S5>/SumD'
   */
  Attitude_quadrotor_B.FilterCoefficient_kg =
    (Attitude_quadrotor_B.DerivativeGain_b -
     Attitude_quadrotor_X.Filter_CSTATE_p) * Attitude_quadrotor_P.ANG_VEL_N;

  /* Sum: '<S5>/Sum' incorporates:
   *  Integrator: '<S5>/Integrator'
   */
  Cphi = (Attitude_quadrotor_B.ProportionalGain_m +
          Attitude_quadrotor_X.Integrator_CSTATE) +
    Attitude_quadrotor_B.FilterCoefficient_kg;

  /* Saturate: '<S5>/Saturate' */
  if (Cphi > Attitude_quadrotor_P.MAX_L) {
    Ctheta = Attitude_quadrotor_P.MAX_L;
  } else if (Cphi < Attitude_quadrotor_P.MIN_L) {
    Ctheta = Attitude_quadrotor_P.MIN_L;
  } else {
    Ctheta = Cphi;
  }

  /* End of Saturate: '<S5>/Saturate' */
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* Sum: '<Root>/Sum5' incorporates:
     *  Inport: '<Root>/rates'
     */
    rtb_e_q = rtb_rates_body[1] - Attitude_quadrotor_U.rates[1];

    /* Gain: '<S6>/Proportional Gain' */
    Attitude_quadrotor_B.ProportionalGain_e = Attitude_quadrotor_P.KP_Q *
      rtb_e_q;

    /* Gain: '<S6>/Derivative Gain' */
    Attitude_quadrotor_B.DerivativeGain_bv = Attitude_quadrotor_P.KD_Q * rtb_e_q;
  }

  /* Gain: '<S6>/Filter Coefficient' incorporates:
   *  Integrator: '<S6>/Filter'
   *  Sum: '<S6>/SumD'
   */
  Attitude_quadrotor_B.FilterCoefficient_m =
    (Attitude_quadrotor_B.DerivativeGain_bv -
     Attitude_quadrotor_X.Filter_CSTATE_jn) * Attitude_quadrotor_P.ANG_VEL_N;

  /* Sum: '<S6>/Sum' incorporates:
   *  Integrator: '<S6>/Integrator'
   */
  rtb_Sum = (Attitude_quadrotor_B.ProportionalGain_e +
             Attitude_quadrotor_X.Integrator_CSTATE_b) +
    Attitude_quadrotor_B.FilterCoefficient_m;

  /* Saturate: '<S6>/Saturate' */
  if (rtb_Sum > Attitude_quadrotor_P.MAX_M) {
    rtb_Saturate_a = Attitude_quadrotor_P.MAX_M;
  } else if (rtb_Sum < Attitude_quadrotor_P.MIN_M) {
    rtb_Saturate_a = Attitude_quadrotor_P.MIN_M;
  } else {
    rtb_Saturate_a = rtb_Sum;
  }

  /* End of Saturate: '<S6>/Saturate' */
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* Sum: '<Root>/Sum6' incorporates:
     *  Inport: '<Root>/rates'
     */
    rtb_e_r = rtb_rates_body[2] - Attitude_quadrotor_U.rates[2];

    /* Gain: '<S7>/Proportional Gain' */
    Attitude_quadrotor_B.ProportionalGain_m2 = Attitude_quadrotor_P.KP_R *
      rtb_e_r;

    /* Gain: '<S7>/Derivative Gain' */
    Attitude_quadrotor_B.DerivativeGain_g = Attitude_quadrotor_P.KD_R * rtb_e_r;
  }

  /* Gain: '<S7>/Filter Coefficient' incorporates:
   *  Integrator: '<S7>/Filter'
   *  Sum: '<S7>/SumD'
   */
  Attitude_quadrotor_B.FilterCoefficient_f =
    (Attitude_quadrotor_B.DerivativeGain_g -
     Attitude_quadrotor_X.Filter_CSTATE_e) * Attitude_quadrotor_P.ANG_VEL_N;

  /* Sum: '<S7>/Sum' incorporates:
   *  Integrator: '<S7>/Integrator'
   */
  rtb_Sum_e = (Attitude_quadrotor_B.ProportionalGain_m2 +
               Attitude_quadrotor_X.Integrator_CSTATE_c) +
    Attitude_quadrotor_B.FilterCoefficient_f;

  /* Saturate: '<S7>/Saturate' */
  if (rtb_Sum_e > Attitude_quadrotor_P.MAX_N) {
    rtb_Saturate_p = Attitude_quadrotor_P.MAX_N;
  } else if (rtb_Sum_e < Attitude_quadrotor_P.MIN_N) {
    rtb_Saturate_p = Attitude_quadrotor_P.MIN_N;
  } else {
    rtb_Saturate_p = rtb_Sum_e;
  }

  /* End of Saturate: '<S7>/Saturate' */

  /* Outport: '<Root>/moments' */
  Attitude_quadrotor_Y.moments[0] = Ctheta;
  Attitude_quadrotor_Y.moments[1] = rtb_Saturate_a;
  Attitude_quadrotor_Y.moments[2] = rtb_Saturate_p;
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* Gain: '<S5>/Integral Gain' */
    Attitude_quadrotor_B.IntegralGain = Attitude_quadrotor_P.KI_P * rtb_e_p;

    /* Gain: '<S6>/Integral Gain' */
    Attitude_quadrotor_B.IntegralGain_h = Attitude_quadrotor_P.KI_Q * rtb_e_q;
  }

  /* Sum: '<S5>/SumI1' incorporates:
   *  Gain: '<S5>/Kb'
   *  Sum: '<S5>/SumI2'
   */
  Attitude_quadrotor_B.SumI1 = (Ctheta - Cphi) * Attitude_quadrotor_P.KB_P +
    Attitude_quadrotor_B.IntegralGain;

  /* Sum: '<S6>/SumI1' incorporates:
   *  Gain: '<S6>/Kb'
   *  Sum: '<S6>/SumI2'
   */
  Attitude_quadrotor_B.SumI1_l = (rtb_Saturate_a - rtb_Sum) *
    Attitude_quadrotor_P.KB_Q + Attitude_quadrotor_B.IntegralGain_h;
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    /* Gain: '<S7>/Integral Gain' */
    Attitude_quadrotor_B.IntegralGain_c = Attitude_quadrotor_P.KI_R * rtb_e_r;
  }

  /* Sum: '<S7>/SumI1' incorporates:
   *  Gain: '<S7>/Kb'
   *  Sum: '<S7>/SumI2'
   */
  Attitude_quadrotor_B.SumI1_o = (rtb_Saturate_p - rtb_Sum_e) *
    Attitude_quadrotor_P.KB_R + Attitude_quadrotor_B.IntegralGain_c;
  if (rtmIsMajorTimeStep((&Attitude_quadrotor_M))) {
    rt_ertODEUpdateContinuousStates(&(&Attitude_quadrotor_M)->solverInfo);

    /* Update absolute time for base rate */
    /* The "clockTick0" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick0"
     * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
     * overflow during the application lifespan selected.
     * Timer of this task consists of two 32 bit unsigned integers.
     * The two integers represent the low bits Timing.clockTick0 and the high bits
     * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
     */
    if (!(++(&Attitude_quadrotor_M)->Timing.clockTick0)) {
      ++(&Attitude_quadrotor_M)->Timing.clockTickH0;
    }

    (&Attitude_quadrotor_M)->Timing.t[0] = rtsiGetSolverStopTime
      (&(&Attitude_quadrotor_M)->solverInfo);

    {
      /* Update absolute timer for sample time: [0.01s, 0.0s] */
      /* The "clockTick1" counts the number of times the code of this task has
       * been executed. The resolution of this integer timer is 0.01, which is the step size
       * of the task. Size of "clockTick1" ensures timer will not overflow during the
       * application lifespan selected.
       * Timer of this task consists of two 32 bit unsigned integers.
       * The two integers represent the low bits Timing.clockTick1 and the high bits
       * Timing.clockTickH1. When the low bit overflows to 0, the high bits increment.
       */
      (&Attitude_quadrotor_M)->Timing.clockTick1++;
      if (!(&Attitude_quadrotor_M)->Timing.clockTick1) {
        (&Attitude_quadrotor_M)->Timing.clockTickH1++;
      }
    }
  }                                    /* end MajorTimeStep */
}

/* Derivatives for root system: '<Root>' */
void Attitude_quadrotorModelClass::Attitude_quadrotor_derivatives()
{
  XDot_Attitude_quadrotor_T *_rtXdot;
  _rtXdot = ((XDot_Attitude_quadrotor_T *) (&Attitude_quadrotor_M)->derivs);

  /* Derivatives for Integrator: '<S3>/Filter' */
  _rtXdot->Filter_CSTATE = Attitude_quadrotor_B.FilterCoefficient;

  /* Derivatives for Integrator: '<S2>/Filter' */
  _rtXdot->Filter_CSTATE_o = Attitude_quadrotor_B.FilterCoefficient_k;

  /* Derivatives for Integrator: '<S4>/Filter' */
  _rtXdot->Filter_CSTATE_j = Attitude_quadrotor_B.FilterCoefficient_i;

  /* Derivatives for Integrator: '<S5>/Integrator' */
  _rtXdot->Integrator_CSTATE = Attitude_quadrotor_B.SumI1;

  /* Derivatives for Integrator: '<S5>/Filter' */
  _rtXdot->Filter_CSTATE_p = Attitude_quadrotor_B.FilterCoefficient_kg;

  /* Derivatives for Integrator: '<S6>/Integrator' */
  _rtXdot->Integrator_CSTATE_b = Attitude_quadrotor_B.SumI1_l;

  /* Derivatives for Integrator: '<S6>/Filter' */
  _rtXdot->Filter_CSTATE_jn = Attitude_quadrotor_B.FilterCoefficient_m;

  /* Derivatives for Integrator: '<S7>/Integrator' */
  _rtXdot->Integrator_CSTATE_c = Attitude_quadrotor_B.SumI1_o;

  /* Derivatives for Integrator: '<S7>/Filter' */
  _rtXdot->Filter_CSTATE_e = Attitude_quadrotor_B.FilterCoefficient_f;
}

/* Model initialize function */
void Attitude_quadrotorModelClass::initialize()
{
  /* Registration code */

  /* initialize real-time model */
  (void) memset((void *)(&Attitude_quadrotor_M), 0,
                sizeof(RT_MODEL_Attitude_quadrotor_T));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&(&Attitude_quadrotor_M)->solverInfo,
                          &(&Attitude_quadrotor_M)->Timing.simTimeStep);
    rtsiSetTPtr(&(&Attitude_quadrotor_M)->solverInfo, &rtmGetTPtr
                ((&Attitude_quadrotor_M)));
    rtsiSetStepSizePtr(&(&Attitude_quadrotor_M)->solverInfo,
                       &(&Attitude_quadrotor_M)->Timing.stepSize0);
    rtsiSetdXPtr(&(&Attitude_quadrotor_M)->solverInfo, &(&Attitude_quadrotor_M
                 )->derivs);
    rtsiSetContStatesPtr(&(&Attitude_quadrotor_M)->solverInfo, (real_T **)
                         &(&Attitude_quadrotor_M)->contStates);
    rtsiSetNumContStatesPtr(&(&Attitude_quadrotor_M)->solverInfo,
      &(&Attitude_quadrotor_M)->Sizes.numContStates);
    rtsiSetNumPeriodicContStatesPtr(&(&Attitude_quadrotor_M)->solverInfo,
      &(&Attitude_quadrotor_M)->Sizes.numPeriodicContStates);
    rtsiSetPeriodicContStateIndicesPtr(&(&Attitude_quadrotor_M)->solverInfo,
      &(&Attitude_quadrotor_M)->periodicContStateIndices);
    rtsiSetPeriodicContStateRangesPtr(&(&Attitude_quadrotor_M)->solverInfo,
      &(&Attitude_quadrotor_M)->periodicContStateRanges);
    rtsiSetErrorStatusPtr(&(&Attitude_quadrotor_M)->solverInfo,
                          (&rtmGetErrorStatus((&Attitude_quadrotor_M))));
    rtsiSetRTModelPtr(&(&Attitude_quadrotor_M)->solverInfo,
                      (&Attitude_quadrotor_M));
  }

  rtsiSetSimTimeStep(&(&Attitude_quadrotor_M)->solverInfo, MAJOR_TIME_STEP);
  (&Attitude_quadrotor_M)->intgData.y = (&Attitude_quadrotor_M)->odeY;
  (&Attitude_quadrotor_M)->intgData.f[0] = (&Attitude_quadrotor_M)->odeF[0];
  (&Attitude_quadrotor_M)->intgData.f[1] = (&Attitude_quadrotor_M)->odeF[1];
  (&Attitude_quadrotor_M)->contStates = ((X_Attitude_quadrotor_T *)
    &Attitude_quadrotor_X);
  rtsiSetSolverData(&(&Attitude_quadrotor_M)->solverInfo, (void *)
                    &(&Attitude_quadrotor_M)->intgData);
  rtsiSetSolverName(&(&Attitude_quadrotor_M)->solverInfo,"ode2");
  rtmSetTPtr((&Attitude_quadrotor_M), &(&Attitude_quadrotor_M)->Timing.tArray[0]);
  (&Attitude_quadrotor_M)->Timing.stepSize0 = 0.01;

  /* block I/O */
  (void) memset(((void *) &Attitude_quadrotor_B), 0,
                sizeof(B_Attitude_quadrotor_T));

  /* states (continuous) */
  {
    (void) memset((void *)&Attitude_quadrotor_X, 0,
                  sizeof(X_Attitude_quadrotor_T));
  }

  /* external inputs */
  (void)memset((void *)&Attitude_quadrotor_U, 0, sizeof
               (ExtU_Attitude_quadrotor_T));

  /* external outputs */
  (void) memset(&Attitude_quadrotor_Y.moments[0], 0,
                3U*sizeof(real_T));

  /* InitializeConditions for Integrator: '<S3>/Filter' */
  Attitude_quadrotor_X.Filter_CSTATE = Attitude_quadrotor_P.Filter_IC;

  /* InitializeConditions for Integrator: '<S2>/Filter' */
  Attitude_quadrotor_X.Filter_CSTATE_o = Attitude_quadrotor_P.Filter_IC_j;

  /* InitializeConditions for Integrator: '<S4>/Filter' */
  Attitude_quadrotor_X.Filter_CSTATE_j = Attitude_quadrotor_P.Filter_IC_h;

  /* InitializeConditions for Integrator: '<S5>/Integrator' */
  Attitude_quadrotor_X.Integrator_CSTATE = Attitude_quadrotor_P.Integrator_IC;

  /* InitializeConditions for Integrator: '<S5>/Filter' */
  Attitude_quadrotor_X.Filter_CSTATE_p = Attitude_quadrotor_P.Filter_IC_h5;

  /* InitializeConditions for Integrator: '<S6>/Integrator' */
  Attitude_quadrotor_X.Integrator_CSTATE_b =
    Attitude_quadrotor_P.Integrator_IC_f;

  /* InitializeConditions for Integrator: '<S6>/Filter' */
  Attitude_quadrotor_X.Filter_CSTATE_jn = Attitude_quadrotor_P.Filter_IC_m;

  /* InitializeConditions for Integrator: '<S7>/Integrator' */
  Attitude_quadrotor_X.Integrator_CSTATE_c =
    Attitude_quadrotor_P.Integrator_IC_o;

  /* InitializeConditions for Integrator: '<S7>/Filter' */
  Attitude_quadrotor_X.Filter_CSTATE_e = Attitude_quadrotor_P.Filter_IC_hf;
}

/* Model terminate function */
void Attitude_quadrotorModelClass::terminate()
{
  /* (no terminate code required) */
}

/* Constructor */
Attitude_quadrotorModelClass::Attitude_quadrotorModelClass()
{
  static const P_Attitude_quadrotor_T Attitude_quadrotor_P_temp = {
    100.0,                             /* Variable: ANG_N
                                        * Referenced by:
                                        *   '<S2>/Filter Coefficient'
                                        *   '<S3>/Filter Coefficient'
                                        *   '<S4>/Filter Coefficient'
                                        */
    100.0,                             /* Variable: ANG_VEL_N
                                        * Referenced by:
                                        *   '<S5>/Filter Coefficient'
                                        *   '<S6>/Filter Coefficient'
                                        *   '<S7>/Filter Coefficient'
                                        */
    0.40514779629427244,               /* Variable: KB_P
                                        * Referenced by: '<S5>/Kb'
                                        */
    0.0,                               /* Variable: KB_Q
                                        * Referenced by: '<S6>/Kb'
                                        */
    0.38746423667787738,               /* Variable: KB_R
                                        * Referenced by: '<S7>/Kb'
                                        */
    0.0499,                            /* Variable: KD_P
                                        * Referenced by: '<S5>/Derivative Gain'
                                        */
    0.0,                               /* Variable: KD_PITCH
                                        * Referenced by: '<S2>/Derivative Gain'
                                        */
    0.0,                               /* Variable: KD_Q
                                        * Referenced by: '<S6>/Derivative Gain'
                                        */
    0.00584,                           /* Variable: KD_R
                                        * Referenced by: '<S7>/Derivative Gain'
                                        */
    0.00512,                           /* Variable: KD_ROLL
                                        * Referenced by: '<S3>/Derivative Gain'
                                        */
    0.00512,                           /* Variable: KD_YAW
                                        * Referenced by: '<S4>/Derivative Gain'
                                        */
    0.304,                             /* Variable: KI_P
                                        * Referenced by: '<S5>/Integral Gain'
                                        */
    0.5469,                            /* Variable: KI_Q
                                        * Referenced by: '<S6>/Integral Gain'
                                        */
    0.0389,                            /* Variable: KI_R
                                        * Referenced by: '<S7>/Integral Gain'
                                        */
    0.298,                             /* Variable: KP_P
                                        * Referenced by: '<S5>/Proportional Gain'
                                        */
    2.0201,                            /* Variable: KP_PITCH
                                        * Referenced by: '<S2>/Proportional Gain'
                                        */
    0.2266,                            /* Variable: KP_Q
                                        * Referenced by: '<S6>/Proportional Gain'
                                        */
    0.135,                             /* Variable: KP_R
                                        * Referenced by: '<S7>/Proportional Gain'
                                        */
    2.0,                               /* Variable: KP_ROLL
                                        * Referenced by: '<S3>/Proportional Gain'
                                        */
    1.0,                               /* Variable: KP_YAW
                                        * Referenced by: '<S4>/Proportional Gain'
                                        */
    1.5,                               /* Variable: MAX_L
                                        * Referenced by: '<S5>/Saturate'
                                        */
    1.5,                               /* Variable: MAX_M
                                        * Referenced by: '<S6>/Saturate'
                                        */
    1.0,                               /* Variable: MAX_N
                                        * Referenced by: '<S7>/Saturate'
                                        */
    1.0,                               /* Variable: MAX_P
                                        * Referenced by: '<S3>/Saturate'
                                        */
    1.0,                               /* Variable: MAX_Q
                                        * Referenced by: '<S2>/Saturate'
                                        */
    -1.5,                              /* Variable: MIN_L
                                        * Referenced by: '<S5>/Saturate'
                                        */
    -1.5,                              /* Variable: MIN_M
                                        * Referenced by: '<S6>/Saturate'
                                        */
    -1.0,                              /* Variable: MIN_N
                                        * Referenced by: '<S7>/Saturate'
                                        */
    -1.0,                              /* Variable: MIN_P
                                        * Referenced by: '<S3>/Saturate'
                                        */
    -1.0,                              /* Variable: MIN_Q
                                        * Referenced by: '<S2>/Saturate'
                                        */
    0.0,                               /* Expression: InitialConditionForFilter
                                        * Referenced by: '<S3>/Filter'
                                        */
    0.0,                               /* Expression: InitialConditionForFilter
                                        * Referenced by: '<S2>/Filter'
                                        */
    0.0,                               /* Expression: InitialConditionForFilter
                                        * Referenced by: '<S4>/Filter'
                                        */
    0.0,                               /* Expression: InitialConditionForIntegrator
                                        * Referenced by: '<S5>/Integrator'
                                        */
    0.0,                               /* Expression: InitialConditionForFilter
                                        * Referenced by: '<S5>/Filter'
                                        */
    0.0,                               /* Expression: InitialConditionForIntegrator
                                        * Referenced by: '<S6>/Integrator'
                                        */
    0.0,                               /* Expression: InitialConditionForFilter
                                        * Referenced by: '<S6>/Filter'
                                        */
    0.0,                               /* Expression: InitialConditionForIntegrator
                                        * Referenced by: '<S7>/Integrator'
                                        */
    0.0                                /* Expression: InitialConditionForFilter
                                        * Referenced by: '<S7>/Filter'
                                        */
  };                                   /* Modifiable parameters */

  /* Initialize tunable parameters */
  Attitude_quadrotor_P = Attitude_quadrotor_P_temp;
}

/* Destructor */
Attitude_quadrotorModelClass::~Attitude_quadrotorModelClass()
{
  /* Currently there is no destructor body generated.*/
}

/* Real-Time Model get method */
RT_MODEL_Attitude_quadrotor_T * Attitude_quadrotorModelClass::getRTM()
{
  return (&Attitude_quadrotor_M);
}
