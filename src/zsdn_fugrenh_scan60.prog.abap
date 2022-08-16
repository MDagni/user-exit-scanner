*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_FUGRENH_SCAN60 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_FUGRIMPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_fugrimpl .

  IF tenhheader[] IS INITIAL.
    SELECT * FROM enhheader INTO TABLE tenhheader
       WHERE ( enhname       LIKE 'Z%' OR
               enhname       LIKE 'Y%'     )
       AND   version       = 'A' ORDER BY enhname version.
  ENDIF.

  LOOP AT tenhheader INTO lenhheader WHERE enhtooltype = 'FUGRENH'.
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

    PERFORM get_fugrenh   USING lenhheader.

  ENDLOOP.

  LOOP AT enhtab_fugr INTO lenh_fugr.
     gs_list-object_type = c_fugr.
     gs_list-imp_name    = lenh_fugr-enhname  .
     gs_list-name        = lenh_fugr-funcname.
     gs_list-used_in     = lenh_fugr-parameter.
     gs_list-cust_inc    = lenh_fugr-typefield.
     gs_list-text2       = lenh_fugr-structure .   """""""""
     gs_list-projekt     = lenh_fugr-defaultval.
     gs_list-mod         = lenh_fugr-enhtooltype.
     gs_list-cnam        = lenh_fugr-loguser.
     gs_list-cdat        = lenh_fugr-logdate.
     gs_list-unam        = lenh_fugr-activate_user.
     gs_list-udat        = lenh_fugr-activate_date.
     gs_list-text3       = lenh_fugr-stext.
     gs_list-text        = lenh_fugr-text.
    APPEND gs_list TO gt_list.
  ENDLOOP.

*  if nothing is found to create a minimum fieldcatalog
  IF gt_list IS INITIAL.
    CLEAR gs_list.
    gs_list-object_type = c_fugr.
    gs_list-imp_name   = 'NO FUGR ENHANCEMENTs FOUND'.
    gs_list-text       = 'with selected criteria'.
    APPEND gs_list TO gt_list.
  ENDIF.

  PERFORM output USING gt_list.
  REFRESH gt_list.

ENDFORM.                    " SEARCH_FUGRIMPL
*&---------------------------------------------------------------------*
*&      Form  GET_FUGRENH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LENHHEADER  text
*----------------------------------------------------------------------*
FORM get_fugrenh  USING   lenhheader TYPE enhheader.


  TYPES: BEGIN OF l_linet,
          programname TYPE progname,
          enhname TYPE enhname,
        END OF l_linet.
  TYPES: BEGIN OF l_linet1,
          fugr TYPE rs38l-area,
          enhname TYPE enhname,
        END OF l_linet1.
  DATA: "hook_enhancement TYPE REF TO cl_enh_tool_hook_impl,
        enhancement TYPE REF TO if_enh_tool,
        enh_err TYPE REF TO cx_enh_root.
  DATA: "l_enhname TYPE enhname,
        lenhlog TYPE enhlog,
        fugr_enhancement TYPE REF TO cl_enh_tool_fugr,
        enh_data TYPE enhfugrdata.
"  DATA  it_enhafunc TYPE enhfugrfuncdata_tab.
"  DATA  l_enhafunc TYPE enhfugrfuncdata.
  DATA: lpara TYPE rsfbpara,
        lfugr_name TYPE rs38l-area,
                max TYPE enhlogid.

  DATA lline TYPE l_linet.
  DATA tframeprog TYPE TABLE OF l_linet.
"  DATA lprogname TYPE progname.
  DATA lfugr TYPE l_linet1.
  DATA tfugr TYPE TABLE OF l_linet1.
  DATA lenhafunc TYPE enhfugrfuncdata.
"  DATA tfupararef_enha TYPE TABLE OF fupararef_enha.
"  DATA lfupararef_enha TYPE fupararef_enha.
"  DATA lfupa TYPE fupararef.
*--------------------------------------------------------------------*

* Get Fugr name
  SELECT programname enhincinx~enhname INTO TABLE tframeprog FROM enhincinx
         INNER JOIN enhheader ON enhincinx~enhname = enhheader~enhname
                                   WHERE        enhincinx~enhname =   lenhheader-enhname
                                   AND          enhheader~enhtooltype = 'FUGRENH'.

  SORT tframeprog BY programname enhname.
  DELETE ADJACENT DUPLICATES FROM tframeprog.

  LOOP AT tframeprog INTO lline.
    CLEAR lfugr.
    lfugr-enhname = lline-enhname.
    CALL FUNCTION 'FUNCTION_INCLUDE_CONCATENATE'
      CHANGING
        program                  = lline-programname
        complete_area            = lfugr-fugr
      EXCEPTIONS
        not_enough_input         = 1
        no_function_pool         = 2
        delimiter_wrong_position = 3
        OTHERS                   = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      APPEND lfugr TO tfugr.
    ENDIF.
  ENDLOOP.

  SELECT MAX( logid ) FROM enhlog INTO max WHERE enhname = lenhheader-enhname.
  SELECT  * FROM enhlog INTO lenhlog up to 1 ROWS  WHERE enhname = lenhheader-enhname
                                                   AND   version = 'A'
                                                   AND   logid = max.
  ENDSELECT.

  LOOP AT tfugr INTO lfugr.
    TRY.
        enhancement = cl_enh_factory=>get_enhancement( enhancement_id = lenhheader-enhname ).

      CATCH cx_enh_root INTO enh_err.
        MESSAGE enh_err TYPE 'I'.
        RETURN.
    ENDTRY.

    fugr_enhancement ?= enhancement.

    lfugr_name = lfugr-fugr.

    CLEAR enh_err.
    CLEAR enh_data.
    TRY.
        fugr_enhancement->get_all_data_for_fugr(
          EXPORTING
            version   = 'A'
            fugr_name = lfugr_name
          IMPORTING
            enha_data = enh_data ).

      CATCH cx_enh_not_found INTO enh_err.
        IF enh_err IS BOUND.
* No Enhancement data found (?!!) ...
          CONTINUE.
        ENDIF.
    ENDTRY.

    LOOP AT enh_data-enh_fubas INTO lenhafunc.
"      REFRESH tfupararef_enha.
      CLEAR lpara.
      LOOP AT lenhafunc-enhimport_visual INTO lpara.
        lenh_fugr-funcname = lenhafunc-fuba.
        MOVE-CORRESPONDING lpara TO lenh_fugr.
        MOVE-CORRESPONDING lenhheader TO lenh_fugr.
        MOVE-CORRESPONDING lenhlog TO lenh_fugr.
        lenh_fugr-text = otr_text-text.
        APPEND lenh_fugr TO enhtab_fugr.
        CLEAR lenh_fugr.
      ENDLOOP.

      CLEAR lpara.
      LOOP AT lenhafunc-enhexport_visual INTO lpara.
        lenh_fugr-funcname = lenhafunc-fuba.
        MOVE-CORRESPONDING lpara TO lenh_fugr.
        MOVE-CORRESPONDING lenhheader TO lenh_fugr.
        MOVE-CORRESPONDING lenhlog TO lenh_fugr.
        lenh_fugr-text = otr_text-text.
        APPEND lenh_fugr TO enhtab_fugr.
        CLEAR lenh_fugr.
      ENDLOOP.

      CLEAR lpara.
      LOOP AT lenhafunc-enhchange_visual INTO lpara.
        lenh_fugr-funcname = lenhafunc-fuba.
        MOVE-CORRESPONDING lpara TO lenh_fugr.
        MOVE-CORRESPONDING lenhheader TO lenh_fugr.
        MOVE-CORRESPONDING lenhlog TO lenh_fugr.
        lenh_fugr-text = otr_text-text.
        APPEND lenh_fugr TO enhtab_fugr.
        CLEAR lenh_fugr.
      ENDLOOP.

      CLEAR lpara.
      LOOP AT lenhafunc-enhtables_visual INTO lpara.
        lenh_fugr-funcname = lenhafunc-fuba.
        MOVE-CORRESPONDING lpara TO lenh_fugr.
        MOVE-CORRESPONDING lenhheader TO lenh_fugr.
        MOVE-CORRESPONDING lenhlog TO lenh_fugr.
        lenh_fugr-text = otr_text-text.
        APPEND lenh_fugr TO enhtab_fugr.
        CLEAR lenh_fugr.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " GET_FUGRENH
