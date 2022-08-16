*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_BADI_IMPL_SCAN60 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_BADIIMPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_badiimpl .

  IF tenhheader[] IS INITIAL.
    SELECT * FROM enhheader INTO TABLE tenhheader
       WHERE ( enhname       LIKE 'Z%' OR
               enhname       LIKE 'Y%'     )
       AND   version       = 'A' ORDER BY enhname version.
  ENDIF.

  LOOP AT tenhheader INTO lenhheader WHERE enhtooltype = 'BADI_IMPL'.
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

    PERFORM get_badi_impl USING lenhheader.           "ToDo

  ENDLOOP.


  LOOP AT enhtab_badi INTO lenh_badi.
    gs_list-object_type = c_nbadi.
    gs_list-imp_name    = lenh_badi-enhname  .
    gs_list-text        = lenh_badi-impl_shorttext.
    gs_list-used_in     = lenh_badi-impl_class.
    gs_list-name        = lenh_badi-spot_name.
    gs_list-cnam        = lenh_badi-loguser.
    gs_list-cdat        = lenh_badi-logdate.
    gs_list-unam        = lenh_badi-activate_user.
    gs_list-udat        = lenh_badi-activate_date.
    APPEND gs_list TO gt_list.
  ENDLOOP.

*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_nbadi.
    gs_list-imp_name   = 'NO BADI ENHANCEMENTs FOUND'.
    gs_list-text       = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.


ENDFORM.                    " SEARCH_BADIIMPL
*&---------------------------------------------------------------------*
*&      Form  GET_BADI_IMPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_badi_impl  USING    lenhheader TYPE enhheader.

  DATA:   badienh TYPE REF TO cl_enh_tool_badi_impl,
          impls TYPE enh_badi_impl_data_it,
          impl TYPE enh_badi_impl_data,
          lenhancement TYPE REF TO if_enh_tool,
          lenh_err TYPE REF TO cx_enh_root,
          max TYPE enhlogid,
          lenhlog TYPE enhlog.
*--------------------------------------------------------------------*

  TRY.
      lenhancement = cl_enh_factory=>get_enhancement( enhancement_id = lenhheader-enhname ).
      badienh ?= lenhancement.
      impls = badienh->get_implementations( 'A' ).

    CATCH cx_enh_root INTO lenh_err.
      MESSAGE lenh_err TYPE 'I'.
      RETURN.
  ENDTRY.

  SELECT MAX( logid ) FROM enhlog INTO max WHERE enhname = lenhheader-enhname.
  SELECT  * FROM enhlog INTO lenhlog UP TO 1 ROWS  WHERE enhname = lenhheader-enhname
                                                   AND   version = 'A'
                                                   AND   logid = max.
  ENDSELECT.

  LOOP AT impls INTO impl WHERE mig_badi_impl = lenhheader-enhname.
    MOVE-CORRESPONDING lenhheader TO lenh_badi.             "#EC ENHOK
    MOVE-CORRESPONDING lenhlog    TO lenh_badi.             "#EC ENHOK

    lenh_badi-spot_name      = impl-spot_name.
    lenh_badi-badi_name      = impl-badi_name.
    lenh_badi-impl_name      = impl-impl_name.
    lenh_badi-impl_class     = impl-impl_class.
    lenh_badi-impl_shorttext = impl-impl_shorttext.

    APPEND lenh_badi TO enhtab_badi.
    CLEAR lenh_badi.
  ENDLOOP.

ENDFORM.                    " GET_BADI_IMPL
