*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.1  - 2010/07/26
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_EXIT_SCANNER_JUMP_TO_CODE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  jump_to_code_fuba
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_Func_from_GS_LIST  text
*----------------------------------------------------------------------*
FORM jump_to_code USING  p_func_from_gs_list                "#EC *
                         p_objtype TYPE seu_objtyp  .

  DATA: l_request TYPE REF TO cl_wb_request,
        l_object_name TYPE seu_objkey,
        l_wb_request_set         TYPE swbm_wb_request_set,
        l_operation TYPE seu_action VALUE 'DISPLAY'.

  l_object_name = p_func_from_gs_list.

* create a request for workbench start up
  CREATE OBJECT l_request
    EXPORTING
      p_object_type = p_objtype
      p_object_name = l_object_name
      p_operation   = l_operation.
  APPEND l_request TO l_wb_request_set.

*---------------------------------------------------------------------*
*       CLASS cl_wb_startup DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
  CLASS cl_wb_startup DEFINITION LOAD.
  CALL METHOD cl_wb_startup=>start
    EXPORTING
      p_wb_request_set         = l_wb_request_set
    EXCEPTIONS
      manager_not_yet_released = 1.
  IF sy-subrc = 0.
*    g_exit_due_to_wb99 = 'X'.
  ELSE.
    IF rseumod IS INITIAL.
      CALL FUNCTION 'RS_WORKBENCH_CUSTOMIZING'
        EXPORTING
          suppress_dialog = 'X'
        IMPORTING
          setting         = rseumod.
    ENDIF.

  ENDIF.

ENDFORM.                    " jump_to_code_fuba
*&---------------------------------------------------------------------*
*&      Form  jump_to_code_custex
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      --> E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_custex USING e_row.                       "#EC *
  READ TABLE gt_list_custex INTO gs_list INDEX e_row.
  IF sy-subrc = 0.

    PERFORM jump_to_code USING gs_list-name
                               'FF' ." FF for Function
  ENDIF.
ENDFORM.                    " jump_to_code_badi

*---------------------------------------------------------------------*
*       FORM jump_to_code_bte                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  E_ROW  Index of the Intern Table (displayed on ALV)
*
*---------------------------------------------------------------------*
FORM jump_to_code_bte USING e_row                           "#EC *
                            e_column.                       "#EC *

  READ TABLE gt_list_bte INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    IF e_column = 'IMP_NAME'. "If the Open FI /Ountbound is Clicked
      PERFORM jump_to_code USING gs_list-imp_name
                                  'FF'.
    ELSE.
      PERFORM jump_to_code USING gs_list-pack_name
                                   'FF'.
    ENDIF.
  ENDIF.
ENDFORM.                    " test
*&---------------------------------------------------------------------*
*&      Form  jump_to_code_badi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_badi USING    e_row.                      "#EC *

  DATA: l_badi_classname(40) TYPE c.

  READ TABLE gt_list_badi INTO gs_list INDEX e_row.
  IF sy-subrc = 0.

    CASE gs_list-imp_name(1).
      WHEN 'Z'.
        gs_list-imp_name = gs_list-imp_name+1.
        CONCATENATE 'ZCL_IM_' gs_list-imp_name '%'
        INTO l_badi_classname.
      WHEN  'Y'.
        gs_list-imp_name = gs_list-imp_name+1.
        CONCATENATE 'YCL_IM_' gs_list-imp_name '%'
        INTO l_badi_classname.
      WHEN OTHERS.
        CONCATENATE '%' gs_list-imp_name '%'
           INTO l_badi_classname.
    ENDCASE.
    SELECT obj_name FROM tadir INTO l_badi_classname UP TO 1  ROWS
                    WHERE  pgmid = c_r3tr
                    AND object = 'CLAS'
                    AND obj_name LIKE l_badi_classname.
    ENDSELECT.

    IF sy-subrc = 0.
      PERFORM jump_to_code USING l_badi_classname
                                       'OC'.   " 'OC' stands for classes
    ELSE.
* Do nothing
      CHECK 1 = 1.
    ENDIF.
  ENDIF.
ENDFORM.                    " jump_to_code_badi
*&---------------------------------------------------------------------*
*&      Form  jump_to_code_ci_incl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_ci_incl USING    e_row.                   "#EC *
  READ TABLE gt_list_ci_incl INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_code USING gs_list-name
                               'DT'.
  ENDIF.
ENDFORM.                    " jump_to_code_ci_incl
*&---------------------------------------------------------------------*
*&      Form  jump_to_code_append
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_append USING    e_row.                    "#EC *

  READ TABLE gt_list_append INTO gs_list INDEX e_row.
  IF sy-subrc = 0.

    PERFORM jump_to_code USING gs_list-name
                               'DT'.
  ENDIF.
ENDFORM.                    " jump_to_code_append
*&---------------------------------------------------------------------*
*&      Form  jump_to_code_fieldex
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_fieldex USING    e_row.                   "#EC *

  DATA: l_function_name(50) TYPE c.

  READ TABLE gt_list_fieldex INTO gs_list INDEX e_row.
  IF sy-subrc = 0.

    CONCATENATE 'FIELD_EXIT_' gs_list-name INTO l_function_name.
    PERFORM jump_to_code USING l_function_name
                                'FF'.
  ENDIF.
ENDFORM.                    " jump_to_code_fieldex
*&---------------------------------------------------------------------*
*&      Form  handle_append_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_append_view.                                    "#EC *

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_append->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_append->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_append USING l_erow.

ENDFORM.                    " handle_append_view
*&---------------------------------------------------------------------*
*&      Form  handle_badi_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_badi_view.

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_badi->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_badi->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_badi USING l_erow.
ENDFORM.                    " handle_badi_view

*&---------------------------------------------------------------------*
*&      Form  handle_bte_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_bte_view.
  DATA: l_erow TYPE i,
        l_ecol TYPE i,
        l_e_column TYPE lvc_s_col.


  CALL METHOD grid_gt_list_bte->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_bte->get_current_cell
    IMPORTING
      e_row = l_erow
      e_col = l_ecol.

  IF l_ecol = 3.
    l_e_column = 'IMP_NAME'.
  ELSE.
    l_e_column = 'NAME'.
  ENDIF.
  PERFORM jump_to_code_bte USING l_erow l_e_column.

ENDFORM.                    " handle_bte_view
*&---------------------------------------------------------------------*
*&      Form  handle_ci_incl_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_ci_incl_view.
  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_ci_incl->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_ci_incl->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_ci_incl USING l_erow.
ENDFORM.                    " handle_ci_incl_view
*&---------------------------------------------------------------------*
*&      Form  handle_custex_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_custex_view.
  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_custex->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_custex->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_custex USING l_erow.
ENDFORM.                    " handle_custex_view
*&---------------------------------------------------------------------*
*&      Form  handle_fieldex_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_fieldex_view.
  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_fieldex->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_fieldex->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_fieldex USING l_erow.
ENDFORM.                    " handle_fieldex_view
*&---------------------------------------------------------------------*
*&      Form  handle_userexit_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_userexit_view.
  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_userexit->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_userexit->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_userexit USING l_erow.
ENDFORM.                    " handle_userexit_view
*&---------------------------------------------------------------------*
*&      Form  handle_vofm_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_vofm_view.
  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_vofm->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_vofm->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_vofm USING l_erow.
ENDFORM.                    " handle_vofm_view
*&---------------------------------------------------------------------*
*&      Form  handle_subst_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_subst_view.
  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_subst->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_subst->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_subst USING l_erow.
ENDFORM.                    " handle_subst_view
*&---------------------------------------------------------------------*
*&      Form  handle_valid_view
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_valid_view.
  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_valid->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_valid->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_valid USING l_erow.
ENDFORM.                    " handle_valid_view
*&---------------------------------------------------------------------*
*&      Form  HANDLE_SCREXIT_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_screxit_view .

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_screxit->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_screxit->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_code_screxit USING l_erow.

ENDFORM.                    " HANDLE_SCREXIT_VIEW
*&---------------------------------------------------------------------*
*&      Form  HANDLE_MENUEX_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_menuex_view .

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_menuex->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_menuex->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_cua_menuex USING l_erow.

ENDFORM.                    " HANDLE_MENUEX_VIEW
*&---------------------------------------------------------------------*
*&      Form  HANDLE_MODWRD_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_modwrd_view .

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_modwrd->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_modwrd->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_modwrd USING l_erow.

ENDFORM.                    " HANDLE_MODWRD_VIEW
*&---------------------------------------------------------------------*
*&      Form  HANDLE_hook_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_hook_view .

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_hookimpl->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_hookimpl->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_hook USING l_erow.

ENDFORM.                    " HANDLE_hook_VIEW
*&---------------------------------------------------------------------*
*&      Form  HANDLE_FUGR_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_fugr_view .

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_fugrenh->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_fugrenh->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_fugrenh USING l_erow.

ENDFORM.                    " HANDLE_FUGR_VIEW
*&---------------------------------------------------------------------*
*&      Form  HANDLE_CLAS_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_clas_view .

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_clasenh->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_clasenh->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_clasenh USING l_erow.

ENDFORM.                    " HANDLE_CLAS_VIEW
*&---------------------------------------------------------------------*
*&      Form  HANDLE_NBADI_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM handle_nbadi_view .

  DATA l_erow TYPE i.

  CALL METHOD grid_gt_list_badiimpl->set_user_command
    EXPORTING
      i_ucomm = space.
  CALL METHOD grid_gt_list_badiimpl->get_current_cell
    IMPORTING
      e_row = l_erow.

  PERFORM jump_to_badiimpl USING l_erow.

ENDFORM.                    " HANDLE_NBADI_VIEW
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_CODE_USEREXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_userexit  USING    e_row.                 "#EC *

  READ TABLE gt_list_userexit INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    if gs_list-name <> gs_list-used_in.                                          "Fix 20100726+
      PERFORM jump_to_abapcode USING 'SHOW' gs_list-name  'PU' gs_list-used_in.
    else.                                                                        "Fix 20100726+
      PERFORM jump_to_abapcode USING 'SHOW' gs_list-name  'PROG' space.          "Fix 20100726+
    endif.                                                                       "Fix 20100726+
  ENDIF.

ENDFORM.                    " JUMP_TO_CODE_USEREXIT
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_CODE_VOFM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_vofm  USING    e_row.                     "#EC *

  READ TABLE gt_list_vofm INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_abapcode USING 'SHOW' gs_list-name 'PU' gs_list-used_in.
  ENDIF.

ENDFORM.                    " JUMP_TO_CODE_VOFM
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_CODE_SUBST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_subst  USING    e_row.                    "#EC *

  READ TABLE gt_list_subst INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_abapcode USING 'SHOW' gs_list-imp_name  'PU' gs_list-used_in.
  ENDIF.

ENDFORM.                    " JUMP_TO_CODE_SUBST
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_CODE_VALID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_valid  USING    e_row.                    "#EC *

  READ TABLE gt_list_valid INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_abapcode USING 'SHOW' gs_list-imp_name 'PU' gs_list-used_in.
  ENDIF.

ENDFORM.                    " JUMP_TO_CODE_VALID
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_CODE_screxit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_code_screxit  USING    e_row.                  "#EC *

  READ TABLE gt_list_screxit INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_abapcode USING 'SHOW'  gs_list-cust_inc 'DYNP' gs_list-imp_name .
  ENDIF.

ENDFORM.                    " JUMP_TO_CODE_screxit
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_CUA_MENUEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_cua_menuex  USING    e_row.                    "#EC *

  READ TABLE gt_list_menuex INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_cua_text USING 'SHOM'  gs_list-imp_name  gs_list-cust_inc gs_list-projekt  .
  ENDIF.

ENDFORM.                    " JUMP_TO_CUA_MENUEX
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_ABAPCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->EXIT  text
*      -->FORMPOOL  text
*----------------------------------------------------------------------*
FORM jump_to_abapcode  USING  operation  exit objtype prog. "#EC *


  DATA: lprogram TYPE sy-repid,
        lroutine     TYPE gb922i-subster.

  lprogram = prog.
  lroutine = exit.

  CALL FUNCTION 'RS_TOOL_ACCESS'
    EXPORTING
      operation        = operation
      object_name      = lroutine
      object_type      = objtype
      enclosing_object = lprogram
    EXCEPTIONS
      OTHERS           = 0.

ENDFORM.                    " JUMP_TO_ABAPCODE
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_CUA_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM jump_to_cua_text  USING   mode list_imp_name list_cust_incl projekt. "#EC *

  DATA:   l_modname TYPE modname,
          l_code    LIKE cuatexts-code,
          l_program TYPE cuatexts-prog,
          l_standard(3) TYPE c.

  l_modname = projekt.
  l_standard = c_std_implmnt.
  l_code = list_cust_incl.
  l_program = list_imp_name.

  CALL FUNCTION 'MOD_KUN_MEMBER_CUATEXT'
    EXPORTING
      modname    = l_modname
      code       = l_code
      mode       = mode
      program    = l_program
      p_standard = l_standard
    EXCEPTIONS
      OTHERS     = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " JUMP_TO_CUA_TEXT
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_MODWRD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_EROW  text
*----------------------------------------------------------------------*
FORM jump_to_modwrd  USING    e_row.                        "#EC *

  READ TABLE gt_list_modwrd INTO gs_list INDEX e_row.
  IF sy-subrc = 0.

    SUBMIT rsmodwrd  WITH de      = gs_list-name
                     WITH rel     = gs_list-projekt
                     WITH sprache = gs_list-langu AND RETURN.
  ENDIF.

ENDFORM.                    " JUMP_TO_MODWRD
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_HOOK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_hook  USING    e_row.                          "#EC *

  READ TABLE gt_list_hookimpl INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_code USING gs_list-imp_name
                               'XH'.
  ENDIF.

ENDFORM.                    " JUMP_TO_HOOK
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_FUGRENH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_fugrenh  USING    e_row.                       "#EC *

  READ TABLE gt_list_fugrenh INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_code USING gs_list-imp_name
                               'XH'.
  ENDIF.

ENDFORM.                    " JUMP_TO_FUGRENH
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_CLASENH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_clasenh  USING    e_row.                       "#EC *

  READ TABLE gt_list_clasenh INTO gs_list INDEX e_row.
  IF sy-subrc = 0.
    PERFORM jump_to_code USING gs_list-imp_name
                               'XH'.
  ENDIF.

ENDFORM.                    " JUMP_TO_CLASENH
*&---------------------------------------------------------------------*
*&      Form  JUMP_TO_BADIIMPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->E_ROW  Index of the Intern Table (displayed on ALV)
*----------------------------------------------------------------------*
FORM jump_to_badiimpl  USING    e_row.                      "#EC *

  READ TABLE gt_list_badiimpl INTO gs_list INDEX e_row.
  IF sy-subrc = 0.

    PERFORM jump_to_code USING gs_list-imp_name
                               'XH'.

  ENDIF.

ENDFORM.                    " JUMP_TO_BADIIMPL
