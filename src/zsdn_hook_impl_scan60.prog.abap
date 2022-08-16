*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_HOOK_IMPL_SCAN60 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_HOOKIMPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_hookimpl .

  IF tenhheader[] IS INITIAL.
    SELECT * FROM enhheader INTO TABLE tenhheader
       WHERE ( enhname       LIKE 'Z%' OR
               enhname       LIKE 'Y%'     )
       AND   version       = 'A' ORDER BY enhname version.
  ENDIF.

  LOOP AT tenhheader INTO lenhheader WHERE enhtooltype = 'HOOK_IMPL'.
    IF NOT lenhheader-shorttext_id  IS INITIAL.
      CLEAR: llangu, otr_context, otr_key, otr_text.
      otr_key-concept = lenhheader-shorttext_id .

      DO 2 TIMES.
        IF sy-index = 1.
          llangu = sy-langu.
        ELSE.
          llangu = 'E'.
        ENDIF.

        CALL FUNCTION 'SOTR_READ_TEXT_WITH_KEY'
          EXPORTING
            langu            = llangu
            context          = otr_context
            sotr_key         = otr_key
          IMPORTING
            entry            = otr_text
          EXCEPTIONS
            no_entry_found   = 0
            language_missing = 0
            OTHERS           = 0.
        IF otr_text-text IS NOT INITIAL.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.

    PERFORM get_hook_impl USING lenhheader.

  ENDLOOP.


  LOOP AT enhtab_hook INTO lenh_hook.

    gs_list-object_type = c_hook.
    gs_list-used_in     = lenh_hook-programname.
    gs_list-projekt     = lenh_hook-extid.
*    gs_list-object_type = lenh_hook-method.
    gs_list-mod         = lenh_hook-enhtooltype.
    gs_list-imp_name    = lenh_hook-enhname  .
    gs_list-name        = lenh_hook-spotname.
    gs_list-cust_inc    = lenh_hook-overwrite .
    gs_list-cnam        = lenh_hook-loguser.
    gs_list-cdat        = lenh_hook-logdate.
    gs_list-unam        = lenh_hook-activate_user.
    gs_list-udat        = lenh_hook-activate_date.
    gs_list-text        = lenh_hook-text.
    gs_list-text2       = lenh_hook-enhmode.
    gs_list-text3       = lenh_hook-full_name.
    APPEND gs_list TO gt_list.

  ENDLOOP.


*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_hook.
    gs_list-name   = 'NO SOURCE CODE PLUG_IN FOUND'.
    gs_list-used_in    = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.


ENDFORM.                    " SEARCH_HOOKIMPL
*&---------------------------------------------------------------------*
*&      Form  GET_HOOK_IMPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LENHHEADER  text
*----------------------------------------------------------------------*
FORM get_hook_impl  USING lenhheader TYPE enhheader.

  DATA: lhook_enhancement TYPE REF TO cl_enh_tool_hook_impl,
        lenhancement TYPE REF TO if_enh_tool,
"        lenhname TYPE enhname,
"        lobjects TYPE enhobjsearch_it,
"        lsearch TYPE enhobjsearch,
"        lsearch_tab TYPE enhobjsearch_it,
        lenh_err TYPE REF TO cx_enh_root,
"        lenh_include TYPE progname,
"        lextension TYPE enhincludeextension,
"        lsource TYPE rswsourcet,
"        lsourceline TYPE string,
        lenhlog TYPE enhlog.

  DATA: timpls       TYPE enh_hook_impl_it,
        limpls       TYPE enh_hook_impl,
        "lenh_store   TYPE REF TO cl_enh_store,
        max TYPE enhlogid.
  DATA: lmain_type TYPE trobjtype,
        lmain_name TYPE eu_aname.

*--------------------------------------------------------------------*


  TRY.
      lenhancement = cl_enh_factory=>get_enhancement(
                                  enhancement_id = lenhheader-enhname ).

    CATCH cx_enh_root INTO lenh_err.
      MESSAGE lenh_err TYPE 'I'.
      RETURN.
  ENDTRY.

  lhook_enhancement ?= lenhancement.
  timpls = lhook_enhancement->get_hook_impls( ).     "Active implementations

  CALL METHOD lhook_enhancement->get_original_object
    EXPORTING
      version   = 'A'
    IMPORTING
      main_type = lmain_type
      main_name = lmain_name.


  SELECT MAX( logid ) FROM enhlog INTO max WHERE enhname = lenhheader-enhname.
  SELECT  * FROM enhlog INTO lenhlog up to 1 ROWS  WHERE enhname = lenhheader-enhname
                                                   AND   version = 'A'
                                                   AND   logid = max.
  ENDSELECT.

  LOOP AT timpls INTO limpls.
    MOVE-CORRESPONDING limpls TO lenh_hook.
    MOVE-CORRESPONDING lenhheader TO lenh_hook.
    MOVE-CORRESPONDING lenhlog TO lenh_hook.
    lenh_hook-main_type = lmain_type.
    lenh_hook-main_name = lmain_name.
    lenh_hook-hook_impl = lhook_enhancement.
    lenh_hook-text = otr_text-text.
    APPEND lenh_hook TO enhtab_hook. CLEAR lenh_hook .
  ENDLOOP.

ENDFORM.                    " GET_HOOK_IMPL
