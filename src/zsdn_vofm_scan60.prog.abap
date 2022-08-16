*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_VOFM_SCAN .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_VOFM_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_vofm_exit .
  DATA: ltrdir TYPE trdir,
        ldevc  TYPE tadir-devclass,
        resulth TYPE bamx_source_analysis.
*--------------------------------------------------------------------*
  PERFORM sapgui_progress_indicator USING 'VOFM Routines Scan...'.

  PERFORM vofm_details.

  LOOP AT xd0200 INTO ld0200.
    IF ld0200-rep IS INITIAL.
      CONTINUE.
    ENDIF.

    resulth-program = ld0200-rep.
    CLEAR ltrdir.
    SELECT SINGLE * FROM  trdir INTO ltrdir
           WHERE  name        = resulth-program.
    CHECK sy-subrc = 0.

    CLEAR ldevc.
    SELECT SINGLE devclass FROM tadir INTO ldevc
                  WHERE pgmid  = 'R3TR'
                  AND   object = 'PROG'
                  AND   obj_name =  resulth-program.

    MOVE-CORRESPONDING ltrdir TO gs_list.

    gs_list-used_in   = resulth-program.
    gs_list-pack_name = ldevc.
    gs_list-object_type = c_vofm.

    MOVE-CORRESPONDING ltrdir TO gs_list.
    gs_list-text = ld0200-bezei.

    gs_list-name = ld0200-form.
    REPLACE 'FORM' WITH '' INTO  gs_list-name.
    REPLACE '.' WITH '' INTO  gs_list-name.
    CONDENSE  gs_list-name.

    APPEND gs_list TO gt_list.
  ENDLOOP.

* if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_vofm.
    gs_list-name = 'NO VOFM ROUTINES FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " SEARCH_VOFM_EXIT
*&---------------------------------------------------------------------*
*&      Form  VOFM_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vofm_details .

  DATA: save_tabix TYPE sy-tabix,
        ltfrmt TYPE tfrmt,
        ltfrm  type tfrm.

  SELECT * FROM tfrm into ltfrm WHERE   aktiv = charx.
    IF sy-subrc = 0.
*     ld0200 = tfrm.
      MOVE-CORRESPONDING ltfrm TO ld0200.                 "#EC ENHOK
      SELECT * FROM tfrmt UP TO 1 ROWS into ltfrmt
                           WHERE grpze = ltfrm-grpze
                             AND grpno = ltfrm-grpno.
      ENDSELECT.
      IF sy-subrc = 0.
        ld0200-bezei = ltfrmt-bezei.
      ENDIF.
      APPEND ld0200 TO xd0200. CLEAR ld0200.
    ENDIF.
  ENDSELECT.

  CHECK NOT xd0200[] IS INITIAL.

  LOOP AT xd0200 INTO ld0200.
    save_tabix = sy-tabix.
    CLEAR usr_grpno.
    PERFORM xd0200_user_grpno_first USING ld0200-grpze
                                     user_grpno_first.

    CHECK ld0200-grpno >= user_grpno_first.
    usr_grpno = user_grpno_first.
    act_grpno = ld0200-grpno.
    act_grpze = ld0200-grpze.
    PERFORM xd0200_include_namen_setzen USING act_grpno
                                              act_grpze
                                              act_report_name.

    include_report-lines = '    INCLUDE ?1.  "?2'.
    REPLACE '?1' WITH include_report_name INTO include_report-lines.
    REPLACE '?2' WITH ld0200-bezei        INTO include_report-lines.
    REFRESH ae_report.
    READ REPORT include_report_name INTO ae_report.
    IF sy-subrc = 0.
      ld0200-rep = include_report_name.
      ld0200-form = include_form_name.
    ELSE.
* Do nothing
      CHECK 1 = 1.
    ENDIF.
    MODIFY xd0200 FROM ld0200 INDEX save_tabix.
  ENDLOOP.

ENDFORM.                    " VOFM_DETAILS
*---------------------------------------------------------------------*
*       FORM XD0200_USER_GRPNO_FIRST                                  *
*---------------------------------------------------------------------*
FORM xd0200_user_grpno_first USING value(xu_grpze) xu_grpno_first. "#EC *

  CASE xu_grpze.
    WHEN pstk.   xu_grpno_first = user_grpno_first2.
    WHEN tdat.   xu_grpno_first = user_grpno_first2.
    WHEN fofu.   xu_grpno_first = user_grpno_first3.
    WHEN OTHERS. xu_grpno_first = user_grpno_first1.
  ENDCASE.

ENDFORM.                    "XD0200_USER_GRPNO_FIRST
*---------------------------------------------------------------------*
*       FORM XD0200_INCLUDE_NAMEN_SETZEN                              *
*---------------------------------------------------------------------*
*       baut die INCLUDE-Namen fuer ACT_GRPZE und ACT_GRPNO auf.      *
*       Das Rahmenprogramm fuer den Editor-Check wird gesetzt.        *
*---------------------------------------------------------------------*
FORM xd0200_include_namen_setzen USING value(xi_grpno) value(xi_grpze) xi_report_name. "#EC *

* buffering the exports to memory
*  statics: grpze_in_memory like tfrm-grpze.

  DATA: sel_rahmen(8) TYPE c,                               "#EC NEEDED
        rahmen_id(14) TYPE c.


  CASE xi_grpze.

*   Kopierbedingungen
    WHEN abed.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV45C?1'.
      ELSE.
        include_report_name = 'RV45B?1'.
      ENDIF.
      include_form_name   = 'FORM BEDINGUNG_PRUEFEN_?2 '.
      sel_rahmen          = 'SAPLV45C'.
    WHEN lbed.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV50B?1'.
      ELSE.
        include_report_name = 'RV50B?1'.
      ENDIF.
      include_form_name   = 'FORM BEDINGUNG_PRUEFEN_?2 '.
      sel_rahmen          = 'SAPFV50C'.
    WHEN fbed.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV60A?1'.
      ELSE.
        include_report_name = 'RV60B?1'.
      ENDIF.
      include_form_name   = 'FORM BEDINGUNG_PRUEFEN_?2.'.
      sel_rahmen          = 'SAPLV60A'.
    WHEN casb.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV43A?1'.
      ELSE.
        include_report_name = 'RV43A?1'.
      ENDIF.
      include_form_name   = 'FORM BEDINGUNG_PRUEFEN_?2.'.
      sel_rahmen          = 'SAPLV43A'.
    WHEN tbed.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV45T?1'.
      ELSE.
        include_report_name = 'RV45T?1'.
      ENDIF.
      include_form_name   = 'FORM BEDINGUNG_PRUEFEN_?2 '.
      sel_rahmen          = 'SAPLV45T'.

*   Datentransporte
    WHEN adat.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV45C?1'.
      ELSE.
        include_report_name = 'RV45C?1'.
      ENDIF.
      include_form_name   = 'FORM DATEN_KOPIEREN_?2.'.
      sel_rahmen          = 'SAPFV45C'.
    WHEN ldat.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV50C?1'.
      ELSE.
        include_report_name = 'RV50C?1'.
      ENDIF.
      include_form_name   = 'FORM DATEN_KOPIEREN_?2.'.
      sel_rahmen          = 'SAPFV50C'.
    WHEN fdat.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV60C?1'.
      ELSE.
        include_report_name = 'RV60C?1'.
      ENDIF.
      include_form_name   = 'FORM DATEN_KOPIEREN_?2.'.
      sel_rahmen          = 'SAPFV60C'.
    WHEN casc.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV44A?1'.
      ELSE.
        include_report_name = 'RV44A?1'.
      ENDIF.
      include_form_name   = 'FORM DATEN_KOPIEREN_?2.'.
      sel_rahmen          = 'SAPLV43A'.
    WHEN tdat.
      IF xi_grpno < user_grpno_first2.
        include_report_name = 'LV45TE?1'.
      ELSE.
        include_report_name = 'RV45TE?1'.
      ENDIF.
      include_form_name   = 'FORM DATEN_KOPIEREN_?2.'.
      sel_rahmen          = 'SAPLV45T'.
    WHEN vsel.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV51A?1'.
      ELSE.
        include_report_name = 'RV51A?1'.
      ENDIF.
      include_form_name   = 'FORM DATEN_KOPIEREN_?2.'.
      sel_rahmen          = 'SAPLV51H'.
    WHEN trau.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV56C?1'.
      ELSE.
        include_report_name = 'RV56C?1'.
      ENDIF.
      include_form_name   = 'FORM DATEN_KOPIEREN_?2 '.
      sel_rahmen          = 'SAPFV56C'.
*   Textnamen
    WHEN tnam.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV70T?1'.
      ELSE.
        include_report_name = 'RV70T?1'.
      ENDIF.
      include_form_name   = 'FORM TEXTNAME_?2 '.
      sel_rahmen          = 'SAPLV70T'.
    WHEN txnm.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV46T?1'.
      ELSE.
        include_report_name = 'RV46T?1'.
      ENDIF.
      include_form_name   = 'FORM TEXTNAME_COPY_?2 '.
      sel_rahmen          = 'SAPLV45T'.

*   Bedingungen
    WHEN pbed.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV61A?1'.
      ELSE.
        include_report_name = 'RV61A?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV61A'.
    WHEN vkmp.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LVKMP?1'.
      ELSE.
        include_report_name = 'RVKMP?1'.
      ENDIF.
      include_form_name   = 'FORM BEDINGUNG_PRUEFEN_?2.'.
      sel_rahmen          = 'SAPLVKMP'.
    WHEN risk.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LRISK?1'.
      ELSE.
        include_report_name = 'RRISK?1'.
      ENDIF.
      include_form_name   = 'FORM ABSICHERUNG_PRUEFEN_?2.'.
      sel_rahmen          = 'SAPLVKMP'.
* requirements free good
    WHEN pbna.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV62N?1'.
      ELSE.
        include_report_name = 'RV62N?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV61N'.
* requirements campaign determination
    WHEN cmpd.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV623?1'.
      ELSE.
        include_report_name = 'RV623?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV613'.
* requirements bonus buy
    WHEN bbyr.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FBBYN?1'.
      ELSE.
        include_report_name = 'RBBYN?1'.
      ENDIF.
      include_form_name   = 'FORM BBYREQ_?2.'.
      sel_rahmen          = 'SAPLV61N'.

*-- Bedingung Handelskalkulation (THV)
    WHEN pbwv.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LWVK1?1'.
      ELSE.
        include_report_name = 'RWVK1?1'.
      ENDIF.
      include_form_name   = 'FORM WVBED_?2.'.
      sel_rahmen          = 'SAPLWVK1'.
    WHEN pofo.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV61M?1'.
      ELSE.
        include_report_name = 'RV61M?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV61M'.
    WHEN pack.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV61P?1'.
      ELSE.
        include_report_name = 'RV61P?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV61P'.
    WHEN pbef.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV61D?1'.
      ELSE.
        include_report_name = 'RV61D?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV61D'.
    WHEN pben.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV61B?1'.
      ELSE.
        include_report_name = 'RV61B?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV61B'.
    WHEN pbek.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV61C?1'.
      ELSE.
        include_report_name = 'RV61C?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV61C'.
    WHEN pbel.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV61G?1'.
      ELSE.
        include_report_name = 'RV61G?1'.
      ENDIF.
      include_form_name   = 'FORM KOBED_?2.'.
      sel_rahmen          = 'SAPLV61G'.
    WHEN pbes.
      include_report_name = space.
      include_form_name   = space.

*   Chargen
    WHEN chbe.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'L080M?1'.
      ELSE.
        include_report_name = 'R080M?1'.
      ENDIF.
      include_form_name   = 'FORM BED_SUCH_STRATEGIE_?2.'.
      sel_rahmen          = 'SAPL080M'.
    WHEN chrg.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV01F?1'.
      ELSE.
        include_report_name = 'RV01F?1'.
      ENDIF.
      include_form_name   = 'FORM CHMVS_?2.'.
      sel_rahmen          = 'SAPLV01F'.
    WHEN chmv.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LMDBF?1'.
      ELSE.
        include_report_name = 'RMDBF?1'.
      ENDIF.
      include_form_name   = 'FORM BFMVS_?2.'.
      sel_rahmen          = 'SAPLMDBF'.

*   Ausfuhrbedingungen
    WHEN exko.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV52E?1'.
      ELSE.
        include_report_name = 'RV52E?1'.
      ENDIF.
      include_form_name   = 'FORM AUSFUHR_BED_PRUEFEN_?2 '.
      sel_rahmen          = 'SAPLV52E'.

*   Folgefunktionen
    WHEN fofu.
      IF xi_grpno < user_grpno_first3.
        include_report_name = 'LV07A?1'.
      ELSE.
        include_report_name = 'RV07A?1'.
      ENDIF.
      include_form_name   = 'FORM BEDINGUNG_PRUEFEN_?2.'.
      sel_rahmen          = 'SAPLV07A'.

*   Formeln
    WHEN pfrs.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV62A?1'.
      ELSE.
        include_report_name = 'RV62A?1'.
      ENDIF.
      include_form_name   = 'FORM FRM_STAFFELBAS_?2.'.
      sel_rahmen          = 'SAPLV61A'.
    WHEN pfra.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV63A?1'.
      ELSE.
        include_report_name = 'RV63A?1'.
      ENDIF.
      include_form_name   = 'FORM FRM_KOND_BASIS_?2.'.
      sel_rahmen          = 'SAPLV61A'.
    WHEN pfrm.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV64A?1'.
      ELSE.
        include_report_name = 'RV64A?1'.
      ENDIF.
      include_form_name   = 'FORM FRM_KONDI_WERT_?2.'.
      sel_rahmen          = 'SAPLV61A'.
    WHEN prun.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV13A?1'.
      ELSE.
        include_report_name = 'RV13Z?1'.
      ENDIF.
      include_form_name   = 'FORM FRM_RUNDUNG_?2.'.
      sel_rahmen          = 'SAPMV13A'.
    WHEN pstk.
      IF xi_grpno < user_grpno_first2.
        include_report_name = 'FV65A?1'.
      ELSE.
        include_report_name = 'RV65A?1'.
      ENDIF.
      include_form_name   = 'FORM FRM_GRUPPENKEY_?2.'.
      sel_rahmen          = 'SAPLV61A'.
* Naturalrabatt (WD)
    WHEN pnat.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'LV61N?1'.
      ELSE.
        include_report_name = 'RV61N?1'.
      ENDIF.
      include_form_name   = 'FORM FRM_RECHENR_?2.'.
      sel_rahmen          = 'SAPLV61N'.

*   Reporting
    WHEN lst1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'RV77S?1'.
        sel_rahmen          = 'SAPRV77S'.
      ELSE.
        include_report_name = 'RV77U?1'.
        sel_rahmen          = 'SAPRV77U'.
      ENDIF.
      include_form_name   = 'FORM LST1_?2.'.

*   WIS
    WHEN mca1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCA1?1'.
      ELSE.
        include_report_name = 'FMCA1?1'.
      ENDIF.
      include_form_name   = 'FORM MCA1_?2.'.
      sel_rahmen          = 'SAPFMCAF'.
    WHEN mca2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCA2?1'.
      ELSE.
        include_report_name = 'FMCA2?1'.
      ENDIF.
      include_form_name   = 'FORM MCA2_?2.'.
      sel_rahmen          = 'SAPFMCAF'.

*   VIS
    WHEN mcv1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCV1?1'.
      ELSE.
        include_report_name = 'FMCV1?1'.
      ENDIF.
      include_form_name   = 'FORM MCV1_?2.'.
      sel_rahmen          = 'SAPFMCVF'.
    WHEN mcv2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCV2?1'.
      ELSE.
        include_report_name = 'FMCV2?1'.
      ENDIF.
      include_form_name   = 'FORM MCV2_?2.'.
      sel_rahmen          = 'SAPFMCVF'.
*   TIS
    WHEN mct1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCT1?1'.
      ELSE.
        include_report_name = 'FMCT1?1'.
      ENDIF.
      include_form_name   = 'FORM MCT1_?2.'.
      sel_rahmen          = 'SAPFMCTF'.
    WHEN mct2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCT2?1'.
      ELSE.
        include_report_name = 'FMCT2?1'.
      ENDIF.
      include_form_name   = 'FORM MCT2_?2.'.
      sel_rahmen          = 'SAPFMCTF'.
*   Einkauf
    WHEN mce1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCE1?1'.
      ELSE.
        include_report_name = 'FMCE1?1'.
      ENDIF.
      include_form_name   = 'FORM MCE1_?2.'.
      sel_rahmen          = 'SAPFMCEF'.
    WHEN mce2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCE2?1'.
      ELSE.
        include_report_name = 'FMCE2?1'.
      ENDIF.
      include_form_name   = 'FORM MCE2_?2.'.
      sel_rahmen          = 'SAPFMCEF'.
    WHEN mcf1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCF1?1'.
      ELSE.
        include_report_name = 'FMCF1?1'.
      ENDIF.
      include_form_name   = 'FORM MCF1_?2.'.
      sel_rahmen          = 'SAPFMCFF'.
    WHEN mcf2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCF2?1'.
      ELSE.
        include_report_name = 'FMCF2?1'.
      ENDIF.
      include_form_name   = 'FORM MCF2_?2.'.
      sel_rahmen          = 'SAPFMCFF'.
    WHEN mcb1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCB1?1'.
      ELSE.
        include_report_name = 'FMCB1?1'.
      ENDIF.
      include_form_name   = 'FORM MCB1_?2.'.
      sel_rahmen          = 'SAPFMCBF'.
    WHEN mcb2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCB2?1'.
      ELSE.
        include_report_name = 'FMCB2?1'.
      ENDIF.
      include_form_name   = 'FORM MCB2_?2.'.
      sel_rahmen          = 'SAPFMCBF'.
    WHEN mcw1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCW1?1'.
      ELSE.
        include_report_name = 'FMCW1?1'.
      ENDIF.
      include_form_name   = 'FORM MCW1_?2.'.
      sel_rahmen          = 'SAPFMCWF'.
    WHEN mcw2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCW2?1'.
      ELSE.
        include_report_name = 'FMCW2?1'.
      ENDIF.
      include_form_name   = 'FORM MCW2_?2.'.
      sel_rahmen          = 'SAPFMCWF'.
    WHEN mcl1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCL1?1'.
      ELSE.
        include_report_name = 'FMCL1?1'.
      ENDIF.
      include_form_name   = 'FORM MCL1_?2.'.
      sel_rahmen          = 'SAPFMCLF'.
    WHEN mcl2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCL2?1'.
      ELSE.
        include_report_name = 'FMCL2?1'.
      ENDIF.
      include_form_name   = 'FORM MCL2_?2.'.
      sel_rahmen          = 'SAPFMCLF'.
    WHEN mcz1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCZ1?1'.
      ELSE.
        include_report_name = 'FMCZ1?1'.
      ENDIF.
      include_form_name   = 'FORM MCZ1_?2.'.
      sel_rahmen          = 'SAPFMCZF'.
    WHEN mcz2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCZ2?1'.
      ELSE.
        include_report_name = 'FMCZ2?1'.
      ENDIF.
      include_form_name   = 'FORM MCZ2_?2.'.
      sel_rahmen          = 'SAPFMCZF'.
*   QM
    WHEN mcq1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCQ1?1'.
      ELSE.
        include_report_name = 'FMCQ1?1'.
      ENDIF.
      include_form_name   = 'FORM MCQ1_?2.'.
      sel_rahmen          = 'SAPFMCQF'.
    WHEN mcq2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCQ2?1'.
      ELSE.
        include_report_name = 'FMCQ2?1'.
      ENDIF.
      include_form_name   = 'FORM MCQ2_?2.'.
      sel_rahmen          = 'SAPFMCQF'.
    WHEN mci1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCI1?1'.
      ELSE.
        include_report_name = 'FMCI1?1'.
      ENDIF.
      include_form_name   = 'FORM MCI1_?2.'.
      sel_rahmen          = 'SAPFMCIF'.
    WHEN mci2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCI2?1'.
      ELSE.
        include_report_name = 'FMCI2?1'.
      ENDIF.
      include_form_name   = 'FORM MCI2_?2.'.
      sel_rahmen          = 'SAPFMCIF'.

* Archivierung
    WHEN reak.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'AKSAP?1'.
      ELSE.
        include_report_name = 'AKUSR?1'.
      ENDIF.
      include_form_name   = 'FORM SD_VBAK_?2 '.
      sel_rahmen          = 'S3VBAKWR'.
    WHEN rerk.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'RKSAP?1'.
      ELSE.
        include_report_name = 'RKUSR?1'.
      ENDIF.
      include_form_name   = 'FORM SD_VBRK_?2 '.
      sel_rahmen          = 'S3VBRKWR'.
    WHEN relk.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'DKSAP?1'.
      ELSE.
        include_report_name = 'DKUSR?1'.
      ENDIF.
      include_form_name   = 'FORM SD_LIKP_?2 '.
      sel_rahmen          = 'S3LIKPWR'.

    WHEN reka.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'KASAP?1'.
      ELSE.
        include_report_name = 'KAUSR?1'.
      ENDIF.
      include_form_name   = 'FORM SD_VBKA_?2 '.
      sel_rahmen          = 'SDVBKAWR'.
*Inbound Validation routines
    WHEN spev.
      IF xi_grpno < user_grpno_first1.
        include_report_name = '/SPE/VAL?1'.
      ELSE.
        include_report_name = '/SPE/VAL?1'.
      ENDIF.
      include_form_name   = 'FORM VAL_ROUT_?2. '.
      sel_rahmen = '/SPE/VAL'.

* Autorisierung von Zahlungskarten
    WHEN vcau.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'DVCAU?1'.
      ELSE.
        include_report_name = 'RVCAU?1'.
      ENDIF.
      include_form_name   = 'FORM REQUIREMENT_CHECK_?2.'.
      sel_rahmen          = 'SAPLV21F'.
* Transport
    WHEN vfcl.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FV57A?1'.
      ELSE.
        include_report_name = 'RV57A?1'.
      ENDIF.
      include_form_name   = 'FORM SD_VFCL_?2 '.
      sel_rahmen          = 'SAPLV57A'.

* IS-U (Utility Information System
    WHEN mcu1.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCU1?1'.
      ELSE.
        include_report_name = 'FMCU1?1'.
      ENDIF.
      include_form_name   = 'FORM MCU1_?2.'.
      sel_rahmen          = 'SAPFMCUF'.
    WHEN mcu2.
      IF xi_grpno < user_grpno_first1.
        include_report_name = 'FMCU2?1'.
      ELSE.
        include_report_name = 'FMCU2?1'.
      ENDIF.
      include_form_name   = 'FORM MCU2_?2.'.
      sel_rahmen          = 'SAPFMCUF'.

* begin IS2ERP
    WHEN jcv1.                                                    " IS-M
      IF xi_grpno < user_grpno_first1.                            " IS-M
        include_report_name = 'FJCV1?1'.                          " IS-M
      ELSE.                                                       " IS-M
        include_report_name = 'FJCV1?1'.                          " IS-M
      ENDIF.                                                      " IS-M
      include_form_name   = 'FORM JCV1_?2.'.                      " IS-M
      sel_rahmen          = 'SAPFJCVF'.                           " IS-M
    WHEN jcv2.                                                    " IS-M
      IF xi_grpno < user_grpno_first1.                            " IS-M
        include_report_name = 'FJCV2?1'.                          " IS-M
      ELSE.                                                       " IS-M
        include_report_name = 'FJCV2?1'.                          " IS-M
      ENDIF.                                                      " IS-M
      include_form_name   = 'FORM JCV2_?2.'.                      " IS-M
      sel_rahmen          = 'SAPFJCVF'.                           " IS-M

* CEM Preislistenfindung
    WHEN j_3gj.                                            "CEM
      IF xi_grpno < user_grpno_first1.                     "CEM
        include_report_name = 'LJ3GJ?1'.                   "CEM
      ELSE.                                                "CEM
        include_report_name = 'RJ3GJ?1'.                   "CEM
      ENDIF.                                               "CEM
      include_form_name   = 'FORM KOBED_?2.'.              "CEM
      sel_rahmen          = 'SAPLJ3GJ'.                    "CEM
* end IS2ERP

    WHEN OTHERS.
      include_report_name = space.

  ENDCASE.
* Sonderfaelle
  IF xi_grpze = tdat.
    SHIFT xi_grpno LEFT.
  ENDIF.

* Namensvergabe
  REPLACE '?1' WITH xi_grpno INTO include_report_name.
  REPLACE '?2' WITH xi_grpno INTO include_form_name.

  xi_report_name = include_report_name.


  rahmen_id   = '$$'.
  rahmen_id+2 = sy-uname.

ENDFORM.                    "XD0200_INCLUDE_NAMEN_SETZEN
