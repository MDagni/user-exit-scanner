*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include ZSDN_EXIT_SCANNER_TOP
*&---------------------------------------------------------------------*
REPORT   zsdn_exit_scanner.

INCLUDE <icons>.

TABLES: sscrfields,
        modsap,
        rseumod.
TABLES: t001q, t001d.

TABLES: tfrm,                                               "#EC NEEDED
        tfrmt,                                              "#EC NEEDED
        tadir.

CONSTANTS:   charx(1)  TYPE c VALUE 'X'.
DATA:
        act_grpze            TYPE tfrm-grpze,               "#EC NEEDED
        act_grpno            TYPE tfrm-grpno,               "#EC NEEDED
        act_grpno_copy       TYPE tfrm-grpno.               "#EC NEEDED

DATA:   act_report_name      TYPE sy-repid,
        include_report_name       TYPE progname,
        include_form_name         TYPE formname.


TYPES: BEGIN OF d0200_ty,
        grpze TYPE tfrm-grpze,
        grpno TYPE tfrm-grpno,
        aktiv TYPE tfrm-aktiv,
        kappl TYPE tfrm-kappl,
        gndat TYPE tfrm-gndat,
        gnzei TYPE tfrm-gnzei,
        bezei TYPE tfrmt-bezei,
        rep(8)   TYPE c,
        form(30) TYPE c,
       END OF d0200_ty.

DATA: xd0200 TYPE TABLE OF d0200_ty,
      ld0200 TYPE d0200_ty.

DATA: usr_grpno  TYPE tfrm-grpno.                           "#EC NEEDED

TYPES: BEGIN OF aerepty,
         lines(200) TYPE c,
       END OF aerepty.
DATA: ae_report TYPE TABLE OF aerepty.                      "#EC NEEDED
*---*
DATA:   BEGIN OF include_report.                            "#EC NEEDED
DATA:     lines TYPE rsmaxline.
DATA:   END OF include_report.

DATA:   user_grpno_first     TYPE tfrm-grpno,
        user_grpno_first1    TYPE tfrm-grpno VALUE 600,
        user_grpno_first2    TYPE tfrm-grpno VALUE 50,
        user_grpno_first3    TYPE tfrm-grpno VALUE 900.
CONSTANTS: user_grpno_last1  TYPE tfrm-grpno VALUE 999,     "#EC NEEDED
           user_grpno_last2  TYPE tfrm-grpno VALUE 99.      "#EC NEEDED

* Makro
DEFINE fill_range.
  &1-sign = &2.
  &1-option = &3.
  &1-low = &4.
  &1-high = &5.
  append &1.
  clear &1.
END-OF-DEFINITION.

CONSTANTS: c_marked   VALUE 'X',
*           c_light    VALUE ' ',  "should be ' ' for enable ALV output
           c_hook(15)             TYPE c VALUE 'HOOK_IMPL',
           c_fugr(15)             TYPE c VALUE 'FUGRENH',
           c_clas(15)             TYPE c VALUE 'CLASENH',
           c_nbadi(15)            TYPE c VALUE 'BADI_IMPL',
           c_userexit(15)         TYPE c VALUE 'USEREXIT',      "AOL
           c_vofm(15)             TYPE c VALUE 'VOFM',          "AOL
           c_valid(15)            TYPE c VALUE 'VALIDATION',    "AOL
           c_subst(15)            TYPE c VALUE 'SUBSTITUTION',  "AOL
           c_screxit(15)          TYPE c VALUE 'SCREEN_EXIT',   "AOL
           c_menuex(15)           TYPE c VALUE 'MENU_EXIT',     "AOL
           c_modwrd(15)           TYPE c VALUE 'MODWRD',        "AOL
           c_append(15)           TYPE c VALUE 'APPEND',
           c_ci_incl(15)          TYPE c VALUE 'CI_INCLUDE',
           c_custex(15)           TYPE c VALUE 'CUSTOMER EXIT',
           c_fieldex(15)          TYPE c VALUE 'FIELD EXIT',
           c_badi(15)             TYPE c VALUE 'BADI',
           c_bte_pro(15)          TYPE c VALUE 'BTE_PROCESS',
           c_bte_pas(15)          TYPE c VALUE 'BTE_P&S',
           c_r3tr(4)              TYPE c VALUE 'R3TR',
           c_tabl(4)              TYPE c VALUE 'TABL',
           c_prog(4)              TYPE c VALUE 'PROG'.        "#EC NEEDED
CONSTANTS: c_std_implmnt(3) VALUE 'KUN'.
CONSTANTS: icon_led_yellow type char4 value '@5D@'.

CONSTANTS:

        abed(4)           VALUE 'ABED',
        lbed(4)           VALUE 'LBED',
        fbed(4)           VALUE 'FBED',
        casb(4)           VALUE 'CASB',
        tbed(4)           VALUE 'TBED',
        adat(4)           VALUE 'ADAT',
        ldat(4)           VALUE 'LDAT',
        fdat(4)           VALUE 'FDAT',
        casc(4)           VALUE 'CASC',
        tdat(4)           VALUE 'TDAT',
        vsel(4)           VALUE 'VSEL',
        trau(4)           VALUE 'TRAU',
        tnam(4)           VALUE 'TNAM',
        txnm(4)           VALUE 'TXNM',
        pbed(4)           VALUE 'PBED',
        pbef(4)           VALUE 'PBEF',
        pben(4)           VALUE 'PBEN',
        pbek(4)           VALUE 'PBEK',
        pbel(4)           VALUE 'PBEL',
        pbes(4)           VALUE 'PBES',
        vkmp(4)           VALUE 'VKMP',
        risk(4)           VALUE 'RISK',
        vcau(4)           VALUE 'VCAU',
        pofo(4)           VALUE 'POFO',               "Bed Porfolio
        pack(4)           VALUE 'PACK',               "Bed PackInst
        pfrs(4)           VALUE 'PFRS',
        pfra(4)           VALUE 'PFRA',
        pfrm(4)           VALUE 'PFRM',
        prun(4)           VALUE 'PRUN',
        pstk(4)           VALUE 'PSTK',
        pbna(4)           VALUE 'PBNA',
        pnat(4)           VALUE 'PNAT',
        cmpd(4)           VALUE 'CMPD',
        bbyr(4)           VALUE 'BBYR',
        pbwv(4)           VALUE 'PBWV',
        chbe(4)           VALUE 'CHBE',
        chrg(4)           VALUE 'CHRG',
        chmv(4)           VALUE 'CHMV',
        exko(4)           VALUE 'EXKO',
        fofu(4)           VALUE 'FOFU',
        lst1(4)           VALUE 'LST1',
        mca1(4)           VALUE 'MCA1',
        mca2(4)           VALUE 'MCA2',
        mcv1(4)           VALUE 'MCV1',
        mcv2(4)           VALUE 'MCV2',
        mce1(4)           VALUE 'MCE1',
        mce2(4)           VALUE 'MCE2',
        mcf1(4)           VALUE 'MCF1',
        mcf2(4)           VALUE 'MCF2',
        mcb1(4)           VALUE 'MCB1',
        mcb2(4)           VALUE 'MCB2',
        mct1(4)           VALUE 'MCT1',
        mct2(4)           VALUE 'MCT2',
        mcw1(4)           VALUE 'MCW1',
        mcw2(4)           VALUE 'MCW2',
        mcl1(4)           VALUE 'MCL1',
        mcl2(4)           VALUE 'MCL2',
        mcq1(4)           VALUE 'MCQ1',
        mcq2(4)           VALUE 'MCQ2',
        mci1(4)           VALUE 'MCI1',
        mci2(4)           VALUE 'MCI2',
        mcz1(4)           VALUE 'MCZ1',
        mcz2(4)           VALUE 'MCZ2',
        mcu1(4)           VALUE 'MCU1',
        mcu2(4)           VALUE 'MCU2',
        reak(4)           VALUE 'REAK',
        rerk(4)           VALUE 'RERK',
        relk(4)           VALUE 'RELK',
        reka(4)           VALUE 'REKA',
        spev(4)           VALUE 'SPEV',
        oirq(4)           VALUE 'OIRQ',                     "#EC NEEDED
        oica(4)           VALUE 'OICA',                     "#EC NEEDED
        vfcl(4)           VALUE 'VFCL'.

CONSTANTS:
       j_3gj(4)          VALUE 'J3GJ'.                         "CEM
CONSTANTS:
       jcv1(4)           VALUE 'JCV1',                         " IS-M
       jcv2(4)           VALUE 'JCV2'.

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*---------------------------------------------------------------------*
* prepared for implement what should happen if a line is clicked      *
*---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.

    METHODS handle_append_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_badi_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_bte_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_ci_incl_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_custex_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_fieldex_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_userexit_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_vofm_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_valid_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_subst_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_screxit_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_menuex_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_modwrd_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_hook_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_fugr_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_clas_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .

    METHODS handle_nbadi_view
     FOR EVENT before_user_command
     OF cl_gui_alv_grid IMPORTING e_ucomm .


*this methods all are handling double click on the alv-control
*and get the index of clicked line of the intern table (e_row)

    METHODS handle_append
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.

    METHODS handle_badi
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.

    METHODS handle_bte
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row e_column.

    METHODS handle_ci_incl
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.

    METHODS handle_custex
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.

    METHODS handle_fieldex
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.

    METHODS handle_userexit
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_vofm
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_valid
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_subst
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_screxit
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_menuex
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_modwrd
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_hook
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_fugr
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_clas
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.
    METHODS handle_nbadi
     FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row.

  PRIVATE SECTION.

ENDCLASS.                    "lcl_event_receiver DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver  IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*

CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_append_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_append_view.
    ENDIF.
  ENDMETHOD.                    "handle_append_view

  METHOD handle_badi_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_badi_view.
    ENDIF.
  ENDMETHOD.                    "handle_badi_view

  METHOD handle_bte_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_bte_view.
    ENDIF.
  ENDMETHOD.                    "handle_bte_view

  METHOD handle_ci_incl_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_ci_incl_view.
    ENDIF.
  ENDMETHOD.                    "handle_ci_incl_view

  METHOD handle_custex_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_custex_view.
    ENDIF.
  ENDMETHOD.                    "handle_custex_view

  METHOD handle_fieldex_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_fieldex_view.
    ENDIF.
  ENDMETHOD.                    "handle_fieldex_view
***AOL
  METHOD handle_vofm_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_vofm_view.
    ENDIF.
  ENDMETHOD.                    "handle_vofm_view

  METHOD handle_userexit_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_userexit_view.
    ENDIF.
  ENDMETHOD.                    "handle_userexit_view

  METHOD handle_valid_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_valid_view.
    ENDIF.
  ENDMETHOD.                    "handle_valid_view

  METHOD handle_subst_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_subst_view.
    ENDIF.
  ENDMETHOD.                    "handle_SUBST_view

  METHOD handle_screxit_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_screxit_view.
    ENDIF.
  ENDMETHOD.                    "handle_SCREXIT_view

  METHOD handle_menuex_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_menuex_view.
    ENDIF.
  ENDMETHOD.                    "handle_MENUEX_view

  METHOD handle_modwrd_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_modwrd_view.
    ENDIF.
  ENDMETHOD.                    "handle_MODWRD_view

  METHOD handle_hook_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_hook_view.
    ENDIF.
  ENDMETHOD.                    "handle_HOOK_view

  METHOD handle_fugr_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_fugr_view.
    ENDIF.
  ENDMETHOD.                    "handle_FUGR_view

  METHOD handle_clas_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_clas_view.
    ENDIF.
  ENDMETHOD.                    "handle_CLAS_view

  METHOD handle_nbadi_view.
    IF e_ucomm = '&DETAIL'.
      PERFORM handle_nbadi_view.
    ENDIF.
  ENDMETHOD.                    "handle_NBADI_view

*every single method calls the jump_to_code_* form and uses the index
*(e_row)
  METHOD handle_append.
    PERFORM jump_to_code_append USING e_row.
  ENDMETHOD.                    "handle_append

  METHOD handle_badi.
    PERFORM jump_to_code_badi USING e_row.
  ENDMETHOD.                    "handle_badi


  METHOD handle_bte.
    PERFORM jump_to_code_bte USING e_row e_column.
  ENDMETHOD.                    "handle_bte

  METHOD handle_ci_incl.
    PERFORM jump_to_code_ci_incl USING e_row.
  ENDMETHOD.                    "handle_ci_incl

  METHOD handle_custex.
    PERFORM jump_to_code_custex USING e_row.
  ENDMETHOD.                    "handle_custex

  METHOD handle_fieldex.
    PERFORM jump_to_code_fieldex USING e_row.
  ENDMETHOD.                    "handle_fieldex

***AOL
  METHOD handle_userexit.
    PERFORM jump_to_code_userexit USING e_row.
  ENDMETHOD.                    "handle_userexit

  METHOD handle_vofm.
    PERFORM jump_to_code_vofm USING e_row.
  ENDMETHOD.                    "handle_vofm

  METHOD handle_valid.
    PERFORM jump_to_code_valid USING e_row.
  ENDMETHOD.                    "handle_valid

  METHOD handle_subst.
    PERFORM jump_to_code_subst USING e_row.
  ENDMETHOD.                    "handle_subst

  METHOD handle_screxit.
    PERFORM jump_to_code_screxit USING e_row.
  ENDMETHOD.                    "handle_SCREXIT

  METHOD handle_menuex.
    PERFORM jump_to_cua_menuex USING e_row.
  ENDMETHOD.                    "handle_MENUEX

  METHOD handle_modwrd.
    PERFORM jump_to_modwrd USING e_row.
  ENDMETHOD.                    "handle_modwrd

  METHOD handle_hook.
    PERFORM jump_to_hook    USING e_row.
  ENDMETHOD.                    "handle_hook

  METHOD handle_fugr.
    PERFORM jump_to_fugrenh    USING e_row.
  ENDMETHOD.                    "handle_fugr

  METHOD handle_clas.
    PERFORM jump_to_clasenh   USING e_row.
  ENDMETHOD.                    "handle_clas

  METHOD handle_nbadi.
    PERFORM jump_to_badiimpl    USING e_row.
  ENDMETHOD.                    "handle_nbadi

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION


TYPES: BEGIN OF gt_list_type,
   name(30)        TYPE c,
   used_in(30)     TYPE c,
   mod(10)         TYPE c,
   imp_name(30)    TYPE c,
   pack_name(30)   TYPE c,
   projekt(15)     TYPE c,
   cust_inc(15)    TYPE c,
   object_type(15) TYPE c,
   text(50)        TYPE c,
   text2(60)       TYPE c,
   text3(64)       TYPE c,
   cnam            TYPE trdir-cnam,
   cdat            TYPE trdir-cdat,
   unam            TYPE trdir-unam,
   udat            TYPE trdir-udat,
   langu           TYPE sy-langu,
   attributes      type CHAR4,
   parameters      type CHAR4,
   Pre_meth        type CHAR4,
   post_meth       type CHAR4,
   overwr_meth     type CHAR4,
   enh_meth        type CHAR4,
   enh_evt         type CHAR4,
   enh_intf        type CHAR4,
END OF gt_list_type,

BEGIN OF gs_table_type, "used in CI_INCLUDE and APPEND search
   tabname          TYPE dd02l-tabname,
   sqltab           TYPE dd02l-sqltab,
   devclass         TYPE tadir-devclass,
   ddtext            TYPE dd02t-ddtext,
 END OF gs_table_type.

TYPES: BEGIN OF modty,
       modact TYPE modact,
       modattr TYPE modattr,
       END OF modty.

TYPES: BEGIN OF smodsty,
        name TYPE modsap-name,
        member TYPE modsap-member,
        typ TYPE modsap-typ,
      END OF  smodsty.

TYPES: BEGIN OF modsapty,
        name TYPE modsap-name,
        devclass     TYPE modsapa-devclass,
       END OF modsapty.

TYPES: BEGIN OF hookenhty,
        enhname       TYPE enhheader-enhname,
        type          TYPE enhheader-type,
        enhtooltype   TYPE enhheader-enhtooltype,
        state         TYPE enhheader-state,
        spotname      TYPE enh_hook_impl-spotname,
        programname   TYPE enh_hook_impl-programname,
        extid         TYPE enh_hook_impl-extid,
        id            TYPE enh_hook_impl-id,
        overwrite     TYPE enh_hook_impl-overwrite,
        method        TYPE enh_hook_impl-method,
        enhmode       TYPE enh_hook_impl-enhmode,
        full_name     TYPE enh_hook_impl-full_name,
        source        TYPE enh_hook_impl-source,
        text          TYPE sotr_text-text,
        loguser       TYPE enhlog-loguser,
        logdate       TYPE enhlog-logdate,
        activate_user TYPE enhlog-activate_user,
        activate_date TYPE enhlog-activate_date,
        main_type TYPE trobjtype,
        main_name TYPE eu_aname,
        hook_impl TYPE REF TO cl_enh_tool_hook_impl,
       END OF hookenhty.
TYPES: BEGIN OF fugrenhty,
        enhname TYPE enhheader-enhname,
        type TYPE enhheader-type,
        enhtooltype TYPE enhheader-enhtooltype,
        state TYPE enhheader-state,
        funcname TYPE enhfugrfuncdata-fuba,
        parameter TYPE rsfbpara-parameter,
        typefield TYPE rsfbpara-typefield,
        structure TYPE rsfbpara-structure,
        defaultval TYPE rsfbpara-defaultval,
        stext TYPE rsfbpara-stext,
        text TYPE sotr_text-text,
        loguser TYPE enhlog-loguser,
        logdate TYPE enhlog-logdate,
        activate_user TYPE enhlog-activate_user,
        activate_date TYPE enhlog-activate_date,
       END OF fugrenhty.

TYPES: BEGIN OF badienhty,
        enhname TYPE enhheader-enhname,
        type TYPE enhheader-type,
        enhtooltype TYPE enhheader-enhtooltype,
        state TYPE enhheader-state,
        spot_name TYPE enh_badi_impl_data-spot_name,
        badi_name TYPE enh_badi_impl_data-badi_name,
        impl_name TYPE enh_badi_impl_data-impl_name,
        impl_class TYPE enh_badi_impl_data-impl_class,
        active TYPE enh_badi_impl_data-active,
        impl_shorttext TYPE ENHSHORTTEXT255,
        mig_badi_impl TYPE enh_badi_impl_data,
        text TYPE sotr_text-text,
        loguser TYPE enhlog-loguser,
        logdate TYPE enhlog-logdate,
        activate_user TYPE enhlog-activate_user,
        activate_date TYPE enhlog-activate_date,
END OF badienhty.
TYPES: BEGIN OF clasenhty,
        enhname TYPE enhheader-enhname,
        type TYPE enhheader-type,
        enhtooltype TYPE enhheader-enhtooltype,
        state TYPE enhheader-state,
        text TYPE sotr_text-text,
        loguser TYPE enhlog-loguser,
        logdate TYPE enhlog-logdate,
        activate_user TYPE enhlog-activate_user,
        activate_date TYPE enhlog-activate_date,
        clsname       type seoclskey-clsname,
        attributes    TYPE char4,
        parameters    TYPE char4,
        pre_meth      TYPE char4,
        post_meth     TYPE char4,
        overwr_meth   TYPE char4,
        enh_meth      TYPE char4,
        enh_evt       TYPE char4,
        enh_intf      TYPE char4,
END OF clasenhty.

DATA: enhtab_hook TYPE TABLE OF hookenhty,
      lenh_hook   TYPE hookenhty.
DATA: enhtab_fugr TYPE TABLE OF fugrenhty,
      lenh_fugr   TYPE fugrenhty.
DATA: enhtab_badi TYPE TABLE OF badienhty,
      lenh_badi   TYPE badienhty.
DATA: enhtab_clas TYPE TABLE OF clasenhty,
      lenh_clas   TYPE clasenhty.
DATA: otr_context TYPE sotr_cntxt,
      otr_text    TYPE sotr_text,
      otr_key     TYPE sotr_key,
      llangu      TYPE sy-langu.
DATA : tenhheader     TYPE TABLE OF enhheader,
      lenhheader     TYPE enhheader.

DATA: gt_list           TYPE TABLE OF gt_list_type,
      gs_list           TYPE          gt_list_type,
      gt_list_bte       TYPE TABLE OF gt_list_type,
      gt_list_badi      TYPE TABLE OF gt_list_type,
      gt_list_custex    TYPE TABLE OF gt_list_type,
      gt_list_fieldex   TYPE TABLE OF gt_list_type,
      gt_list_userexit  TYPE TABLE OF gt_list_type,
      gt_list_hookimpl  TYPE TABLE OF gt_list_type,
      gt_list_fugrenh   TYPE TABLE OF gt_list_type,
      gt_list_clasenh   TYPE TABLE OF gt_list_type,
      gt_list_badiimpl  TYPE TABLE OF gt_list_type,
      gt_list_vofm      TYPE TABLE OF gt_list_type,
      gt_list_subst     TYPE TABLE OF gt_list_type,
      gt_list_valid     TYPE TABLE OF gt_list_type,
      gt_list_screxit   TYPE TABLE OF gt_list_type,
      gt_list_menuex    TYPE TABLE OF gt_list_type,
      gt_list_modwrd    TYPE TABLE OF gt_list_type,
      gt_list_ci_incl   TYPE TABLE OF gt_list_type,
      gt_list_append    TYPE TABLE OF gt_list_type,

*counter Variables to sum up the number of modifications
     g_counter      TYPE i,
     count_append   TYPE i,
     count_badi     TYPE i,
     count_bte      TYPE i,
     count_ci_incl  TYPE i,
     count_custex   TYPE i,
     count_fieldex  TYPE i,
     count_userexit TYPE i,
     count_vofm     TYPE i,
     count_valid    TYPE i,
     count_subst    TYPE i,
     count_screxit  TYPE i,
     count_modwrd   TYPE i,
     count_hookimpl TYPE i,
     count_fugrenh  TYPE i,
     count_clasenh  TYPE i,
     count_badiimpl TYPE i,
     count_menuex   TYPE i.

DATA: smods TYPE SORTED TABLE OF smodsty WITH UNIQUE KEY name member,
      lsmods TYPE smodsty.

DATA: modif     TYPE TABLE OF modty,
      wamodif   TYPE modty.

DATA:  xxmodsap TYPE SORTED TABLE OF modsapty WITH UNIQUE KEY name,
       lxmodsap TYPE modsapty.


*fieldcat tables
DATA:  gt_fieldcat_append               TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_badi                 TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_bte                  TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_ci_incl              TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_custex               TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_fieldex              TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_userexit             TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_hookimpl             TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_fugrenh              TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_clasenh              TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_badiimpl             TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_vofm                 TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_valid                TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_subst                TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_screxit              TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_menuex               TYPE TABLE OF lvc_s_fcat,
       gt_fieldcat_modwrd               TYPE TABLE OF lvc_s_fcat,

*event receivers
     event_receiver_gt_list_append    TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_badi      TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_bte       TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_ci_incl   TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_custex    TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_fieldex   TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_usrexit   TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_hookimp   TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_clasenh   TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_fugrenh   TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_badiimp   TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_vofm      TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_valid     TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_subst     TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_screxit   TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_menuex    TYPE REF TO lcl_event_receiver,
     event_receiver_gt_list_modwrd    TYPE REF TO lcl_event_receiver,

*grids (ALV-Grid-Controls)
     grid_gt_list_append             TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_badi               TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_bte                TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_ci_incl            TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_custex             TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_fieldex            TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_userexit           TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_vofm               TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_valid              TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_subst              TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_hookimpl           TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_fugrenh            TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_clasenh            TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_badiimpl           TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_screxit            TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_modwrd             TYPE REF TO cl_gui_alv_grid,
     grid_gt_list_menuex             TYPE REF TO cl_gui_alv_grid.

*containers used for display the ALV control
DATA: custum_container_append       TYPE REF TO cl_gui_custom_container,
      custum_container_badi         TYPE REF TO cl_gui_custom_container,
      custum_container_bte          TYPE REF TO cl_gui_custom_container,
      custum_container_ci_incl      TYPE REF TO cl_gui_custom_container,
      custum_container_custex       TYPE REF TO cl_gui_custom_container,
      custum_container_fieldex      TYPE REF TO cl_gui_custom_container,
      custum_container_userexit      TYPE REF TO cl_gui_custom_container,
      custum_container_hookimpl      TYPE REF TO cl_gui_custom_container,
      custum_container_fugrenh       TYPE REF TO cl_gui_custom_container,
      custum_container_clasenh       TYPE REF TO cl_gui_custom_container,
      custum_container_badiimpl      TYPE REF TO cl_gui_custom_container,
      custum_container_vofm          TYPE REF TO cl_gui_custom_container,
      custum_container_valid         TYPE REF TO cl_gui_custom_container,
      custum_container_subst         TYPE REF TO cl_gui_custom_container,
      custum_container_screxit       TYPE REF TO cl_gui_custom_container,
      custum_container_modwrd        TYPE REF TO cl_gui_custom_container,
      custum_container_menuex        TYPE REF TO cl_gui_custom_container.

*data for the buttons of the ALV
DATA:  gt_excl_button      TYPE ui_functions.
DATA:  ls_excl_button      TYPE ui_func.

*Dynpro Data
DATA: ok_code TYPE sy-ucomm,
      ss_ok_code TYPE sy-ucomm.

*Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK selection WITH FRAME TITLE text-001.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK intern1 WITH FRAME TITLE text-005.
PARAMETERS: userexit AS CHECKBOX DEFAULT c_marked,
            vofm     AS CHECKBOX DEFAULT c_marked,
            subst    AS CHECKBOX DEFAULT c_marked,
            valid    AS CHECKBOX DEFAULT c_marked,
            custexit AS CHECKBOX DEFAULT c_marked,
            screxit  AS CHECKBOX DEFAULT c_marked,
            fieldext AS CHECKBOX DEFAULT c_marked,
            bte      AS CHECKBOX DEFAULT c_marked,
            badi     AS CHECKBOX DEFAULT c_marked.
SELECTION-SCREEN END   OF BLOCK intern1.
SELECTION-SCREEN BEGIN OF BLOCK intern4 WITH FRAME TITLE text-007.
PARAMETERS:   hookimpl   AS CHECKBOX DEFAULT c_marked,
              fugrimpl   AS CHECKBOX DEFAULT c_marked,
              clasimpl   AS CHECKBOX DEFAULT c_marked,
              badiimpl   AS CHECKBOX DEFAULT c_marked.
SELECTION-SCREEN END   OF BLOCK intern4.
SELECTION-SCREEN BEGIN OF BLOCK intern2 WITH FRAME TITLE text-003.
PARAMETERS:   append   TYPE flag  AS CHECKBOX ,
              ci_incl  AS CHECKBOX.
SELECTION-SCREEN END   OF BLOCK intern2.

SELECTION-SCREEN BEGIN OF BLOCK intern3 WITH FRAME TITLE text-006.
PARAMETERS: modcua AS CHECKBOX,
            modwrd AS CHECKBOX .
SELECTION-SCREEN END   OF BLOCK intern3.
SELECTION-SCREEN PUSHBUTTON /1(20)
            allbtn  USER-COMMAND sel_all
            VISIBLE LENGTH 4.                               "#EC NEEDED

SELECTION-SCREEN PUSHBUTTON 6(20)
            dallbtn USER-COMMAND dsel_all
            VISIBLE LENGTH 4.                               "#EC NEEDED
SELECTION-SCREEN END   OF BLOCK selection.

SELECT-OPTIONS: so_devcl FOR tadir-devclass NO-DISPLAY.
SELECT-OPTIONS: xsubst FOR t001q-subst NO-DISPLAY.
SELECT-OPTIONS: xvalid FOR t001d-valid NO-DISPLAY.
