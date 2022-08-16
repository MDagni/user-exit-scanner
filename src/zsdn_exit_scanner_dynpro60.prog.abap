*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_EXIT_SCANNER_DYNPRO
*&--------------------------------------------------------------------*

* FUNCTION CODES FOR TABSTRIP 'ALV_TAB'
CONSTANTS: BEGIN OF c_alv_tab,
             tab1  LIKE sy-ucomm VALUE  'USREXIT',
             tab2  LIKE sy-ucomm VALUE  'VOFM',
             tab3  LIKE sy-ucomm VALUE  'SUBST',
             tab4  LIKE sy-ucomm VALUE  'VALID',
             tab5  LIKE sy-ucomm VALUE  'CUSTEX',
             tab6  LIKE sy-ucomm VALUE  'FIELDEX',
             tab7  LIKE sy-ucomm VALUE  'BTE',   "
             tab8  LIKE sy-ucomm VALUE  'BADI',  "
             tab9  LIKE sy-ucomm VALUE  'APPEND',"
             tab10 LIKE sy-ucomm VALUE  'CI_INCL',
             tab11 LIKE sy-ucomm VALUE  'SCREXIT',
             tab12 LIKE sy-ucomm VALUE  'MENUEX' ,
             tab13 LIKE sy-ucomm VALUE  'MODWRD' ,
             tab14 LIKE sy-ucomm VALUE  'HOOKIMPL' ,
             tab15 LIKE sy-ucomm VALUE  'FUGRENH' ,
             tab16 LIKE sy-ucomm VALUE  'CLASENH' ,
             tab17 LIKE sy-ucomm VALUE  'BADIIMPL' ,
           END OF c_alv_tab.
* DATA FOR TABSTRIP 'ALV_TAB'
CONTROLS:  alv_tab TYPE TABSTRIP.                           "#EC NEEDED
DATA:      BEGIN OF g_alv_tab,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'ZSDN_EXIT_SCANNER60',
             pressed_tab LIKE sy-ucomm VALUE c_alv_tab-tab1,
           END OF g_alv_tab.

* OUTPUT MODULE FOR TABSTRIP 'ALV_TAB': SETS ACTIVE TAB
MODULE alv_tab_active_tab_set OUTPUT.
  IF ok_code IS INITIAL.
    CASE c_marked.
***AOL
      WHEN userexit.
        g_alv_tab-pressed_tab = 'USREXIT'.
      WHEN vofm.
        g_alv_tab-pressed_tab = 'VOFM'.
      WHEN valid.
        g_alv_tab-pressed_tab = 'VALID'.
      WHEN subst.
        g_alv_tab-pressed_tab = 'SUBST'.
      WHEN custexit.
        g_alv_tab-pressed_tab = 'CUSTEX'.
      WHEN fieldext.
        g_alv_tab-pressed_tab = 'FIELDEX'.
      WHEN bte.
        g_alv_tab-pressed_tab = 'BTE'.
      WHEN badi.
        g_alv_tab-pressed_tab = 'BADI'.
      WHEN screxit.
        g_alv_tab-pressed_tab = 'SCREXIT'.
      WHEN modcua.
        g_alv_tab-pressed_tab = 'MENUEX'.
      WHEN append.
        g_alv_tab-pressed_tab = 'APPEND'.
      WHEN ci_incl.
        g_alv_tab-pressed_tab = 'CI_INCL'.
      WHEN modwrd.
        g_alv_tab-pressed_tab = 'MODWRD'.
      WHEN hookimpl.
        g_alv_tab-pressed_tab = 'HOOKIMPL'.
      WHEN fugrimpl.
        g_alv_tab-pressed_tab = 'FUGRENH'.
      WHEN clasimpl.
        g_alv_tab-pressed_tab = 'CLASENH'.
      WHEN badiimpl.
        g_alv_tab-pressed_tab = 'BADIIMPL'.
    ENDCASE.
  ENDIF.

  alv_tab-activetab = g_alv_tab-pressed_tab.
  CASE g_alv_tab-pressed_tab.
    WHEN c_alv_tab-tab1.             "Userexit
      g_alv_tab-subscreen = '0108'.
    WHEN c_alv_tab-tab2.             "Vofm
      g_alv_tab-subscreen = '0109'.
    WHEN c_alv_tab-tab3.             "Substitutions
      g_alv_tab-subscreen = '0110'.
    WHEN c_alv_tab-tab4.             "Validations
      g_alv_tab-subscreen = '0111'.
    WHEN c_alv_tab-tab5.             "Customer Exit
      g_alv_tab-subscreen = '0106'.
    WHEN c_alv_tab-tab6.             "Field Exit
      g_alv_tab-subscreen = '0107'.
    WHEN c_alv_tab-tab7.             "BTE
      g_alv_tab-subscreen = '0104'.
    WHEN c_alv_tab-tab8.             "BAdI
      g_alv_tab-subscreen = '0102'.
    WHEN c_alv_tab-tab9.             "Append
      g_alv_tab-subscreen = '0101'.
    WHEN c_alv_tab-tab10.            "CI Include
      g_alv_tab-subscreen = '0105'.
    WHEN c_alv_tab-tab11.            "Screen Exit
      g_alv_tab-subscreen = '0112'.
    WHEN c_alv_tab-tab12.            "Menu Exit
      g_alv_tab-subscreen = '0113'.
    WHEN c_alv_tab-tab13.            "Changed KeyWords
      g_alv_tab-subscreen = '0114'.
    WHEN c_alv_tab-tab14.            "Source Code Plug-In
      g_alv_tab-subscreen = '0115'.
    WHEN c_alv_tab-tab15.            "Function Enhancements
      g_alv_tab-subscreen = '0116'.
    WHEN c_alv_tab-tab16.            "Class Enhancements
      g_alv_tab-subscreen = '0117'.
    WHEN c_alv_tab-tab17.            "BAdI Enhancements
      g_alv_tab-subscreen = '0118'.
    WHEN OTHERS.
*      DO NOTHING
  ENDCASE.
ENDMODULE.                    "alv_tab_active_tab_set OUTPUT

* INPUT MODULE FOR TABSTRIP 'ALV_TAB': GETS ACTIVE TAB
MODULE alv_tab_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_alv_tab-tab1.                              "Userexit
      g_alv_tab-pressed_tab = c_alv_tab-tab1.
    WHEN c_alv_tab-tab2.                              "Vofm
      g_alv_tab-pressed_tab = c_alv_tab-tab2.
    WHEN c_alv_tab-tab3.                              "Substitutions
      g_alv_tab-pressed_tab = c_alv_tab-tab3.
    WHEN c_alv_tab-tab4.                              "Validations
      g_alv_tab-pressed_tab = c_alv_tab-tab4.
    WHEN c_alv_tab-tab5.                              "Customer Exit
      g_alv_tab-pressed_tab = c_alv_tab-tab5.
    WHEN c_alv_tab-tab6.                              "Field Exit
      g_alv_tab-pressed_tab = c_alv_tab-tab6  .
    WHEN c_alv_tab-tab7.                              "BTE
      g_alv_tab-pressed_tab = c_alv_tab-tab7.
    WHEN c_alv_tab-tab8.                              "BAdI
      g_alv_tab-pressed_tab = c_alv_tab-tab8.
    WHEN c_alv_tab-tab9.                              "Append
      g_alv_tab-pressed_tab = c_alv_tab-tab9.
    WHEN c_alv_tab-tab10.                             "CI Include
      g_alv_tab-pressed_tab = c_alv_tab-tab10.
    WHEN c_alv_tab-tab11.                             "Screen Exit
      g_alv_tab-pressed_tab = c_alv_tab-tab11.
    WHEN c_alv_tab-tab12.                             "Menu Exit
      g_alv_tab-pressed_tab = c_alv_tab-tab12.
    WHEN c_alv_tab-tab13.                             "Changed Keywords
      g_alv_tab-pressed_tab = c_alv_tab-tab13.
    WHEN c_alv_tab-tab14.                             "Source Code PlugIn
      g_alv_tab-pressed_tab = c_alv_tab-tab14.
    WHEN c_alv_tab-tab15.                             "Function Enhancements
      g_alv_tab-pressed_tab = c_alv_tab-tab15.
    WHEN c_alv_tab-tab16.                             "Function Enhancements
      g_alv_tab-pressed_tab = c_alv_tab-tab16.
    WHEN c_alv_tab-tab17.                             "Function Enhancements
      g_alv_tab-pressed_tab = c_alv_tab-tab17.

    WHEN OTHERS.
*      DO NOTHING
  ENDCASE.
ENDMODULE.                    "alv_tab_active_tab_get INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR 'TITLE_100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
*    do nothing
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  modify_screen_100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_100 OUTPUT.

  LOOP AT SCREEN.

    CASE screen-name.
      WHEN 'ALV_TAB_TAB1'.
        IF userexit NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN  'ALV_TAB_TAB2' .
        IF vofm NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB3' .
        IF valid NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN  'ALV_TAB_TAB4' .
        IF subst NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB5' .
        IF custexit NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'ALV_TAB_TAB6' .
        IF fieldext NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB7'.
        IF bte NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB8'.
        IF badi NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB9'.
        IF append NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB10'.
        IF ci_incl NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB11'.
        IF screxit NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB12'.
        IF modcua NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB13'.
        IF modwrd NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB14'.
        IF hookimpl NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB15'.
        IF fugrimpl NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB16'.
        IF clasimpl NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN   'ALV_TAB_TAB17'.
        IF badiimpl NE c_marked.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDMODULE.                 " modify_screen_100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  create_ALVs  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_alvs OUTPUT.

  IF append = c_marked.   "c_marked = 'X'
    IF custum_container_append IS INITIAL.
      CREATE OBJECT custum_container_append
        EXPORTING
          container_name = 'CONT_APPEND'.
      CREATE OBJECT grid_gt_list_append
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_append.
      CALL METHOD grid_gt_list_append->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_append
          it_fieldcatalog      = gt_fieldcat_append.
      CREATE OBJECT event_receiver_gt_list_append.

      SET HANDLER event_receiver_gt_list_append->handle_append FOR
                  grid_gt_list_append.
      SET HANDLER event_receiver_gt_list_append->handle_append_view FOR
                  grid_gt_list_append.

    ELSE.
      CALL METHOD grid_gt_list_append->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF badi = c_marked.
    IF custum_container_badi IS INITIAL.
      CREATE OBJECT custum_container_badi
        EXPORTING
          container_name = 'CONT_BADI'.
      CREATE OBJECT grid_gt_list_badi
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_badi.
      CALL METHOD grid_gt_list_badi->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_badi
          it_fieldcatalog      = gt_fieldcat_badi.
      CREATE OBJECT event_receiver_gt_list_badi.

      SET HANDLER event_receiver_gt_list_badi->handle_badi FOR
                  grid_gt_list_badi.

      SET HANDLER event_receiver_gt_list_badi->handle_badi_view FOR
                  grid_gt_list_badi.

    ELSE.
      CALL METHOD grid_gt_list_badi->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF bte = c_marked .
    IF custum_container_bte IS INITIAL.
      CREATE OBJECT custum_container_bte
        EXPORTING
          container_name = 'CONT_BTE'.
      CREATE OBJECT grid_gt_list_bte
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_bte.
      CALL METHOD grid_gt_list_bte->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_bte
          it_fieldcatalog      = gt_fieldcat_bte.
      CREATE OBJECT event_receiver_gt_list_bte.

      SET HANDLER event_receiver_gt_list_bte->handle_bte FOR
                  grid_gt_list_bte.
      SET HANDLER event_receiver_gt_list_bte->handle_bte_view FOR
      grid_gt_list_bte.
    ELSE.
      CALL METHOD grid_gt_list_bte->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF ci_incl = c_marked .
    IF custum_container_ci_incl IS INITIAL.
      CREATE OBJECT custum_container_ci_incl
        EXPORTING
          container_name = 'CONT_CI_INCL'.
      CREATE OBJECT grid_gt_list_ci_incl
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_ci_incl.
      CALL METHOD
        grid_gt_list_ci_incl->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_ci_incl
          it_fieldcatalog      = gt_fieldcat_ci_incl.
      CREATE OBJECT event_receiver_gt_list_ci_incl.

      SET HANDLER event_receiver_gt_list_ci_incl->handle_ci_incl FOR
                  grid_gt_list_ci_incl.
      SET HANDLER event_receiver_gt_list_ci_incl->handle_ci_incl_view FOR
                  grid_gt_list_ci_incl.
    ELSE.
      CALL METHOD grid_gt_list_ci_incl->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF custexit = c_marked .
    IF custum_container_custex IS INITIAL.
      CREATE OBJECT custum_container_custex
        EXPORTING
          container_name = 'CONT_CUSTEX'.
      CREATE OBJECT grid_gt_list_custex
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_custex.
      CALL METHOD grid_gt_list_custex->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_custex
          it_fieldcatalog      = gt_fieldcat_custex.
      CREATE OBJECT event_receiver_gt_list_custex.

      SET HANDLER event_receiver_gt_list_custex->handle_custex FOR
                  grid_gt_list_custex.
      SET HANDLER event_receiver_gt_list_custex->handle_custex_view FOR
                  grid_gt_list_custex.
    ELSE.
      CALL METHOD grid_gt_list_custex->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF  fieldext = c_marked.
    IF custum_container_fieldex IS INITIAL.
      CREATE OBJECT custum_container_fieldex
        EXPORTING
          container_name = 'CONT_FIELDEX'.
      CREATE OBJECT grid_gt_list_fieldex
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_fieldex.
      CALL METHOD grid_gt_list_fieldex->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_fieldex
          it_fieldcatalog      = gt_fieldcat_fieldex.
      CREATE OBJECT event_receiver_gt_list_fieldex.

      SET HANDLER event_receiver_gt_list_fieldex->handle_fieldex FOR
                  grid_gt_list_fieldex.
      SET HANDLER event_receiver_gt_list_fieldex->handle_fieldex_view FOR
      grid_gt_list_fieldex.
    ELSE.
      CALL METHOD grid_gt_list_fieldex->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

***AOL
  IF  userexit = c_marked.
    IF custum_container_userexit IS INITIAL.
      CREATE OBJECT custum_container_userexit
        EXPORTING
          container_name = 'CONT_USEREXIT'.
      CREATE OBJECT grid_gt_list_userexit
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_userexit.
      CALL METHOD grid_gt_list_userexit->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_userexit
          it_fieldcatalog      = gt_fieldcat_userexit.
      CREATE OBJECT event_receiver_gt_list_usrexit.

      SET HANDLER event_receiver_gt_list_usrexit->handle_userexit FOR
                  grid_gt_list_userexit.
      SET HANDLER event_receiver_gt_list_usrexit->handle_userexit_view FOR
      grid_gt_list_userexit.
    ELSE.
      CALL METHOD grid_gt_list_userexit->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF  vofm = c_marked.
    IF custum_container_vofm IS INITIAL.
      CREATE OBJECT custum_container_vofm
        EXPORTING
          container_name = 'CONT_VOFM'.
      CREATE OBJECT grid_gt_list_vofm
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_vofm.
      CALL METHOD grid_gt_list_vofm->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_vofm
          it_fieldcatalog      = gt_fieldcat_vofm.
      CREATE OBJECT event_receiver_gt_list_vofm.

      SET HANDLER event_receiver_gt_list_vofm->handle_vofm FOR
                  grid_gt_list_vofm.
      SET HANDLER event_receiver_gt_list_vofm->handle_vofm_view FOR
                  grid_gt_list_vofm.
    ELSE.
      CALL METHOD grid_gt_list_vofm->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF  subst = c_marked.
    IF custum_container_subst IS INITIAL.
      CREATE OBJECT custum_container_subst
        EXPORTING
          container_name = 'CONT_SUBST'.
      CREATE OBJECT grid_gt_list_subst
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_subst.
      CALL METHOD grid_gt_list_subst->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_subst
          it_fieldcatalog      = gt_fieldcat_subst.
      CREATE OBJECT event_receiver_gt_list_subst.

      SET HANDLER event_receiver_gt_list_subst->handle_subst FOR
                  grid_gt_list_subst.
      SET HANDLER event_receiver_gt_list_subst->handle_subst_view FOR
                  grid_gt_list_subst.
    ELSE.
      CALL METHOD grid_gt_list_subst->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF  valid = c_marked.
    IF custum_container_valid IS INITIAL.
      CREATE OBJECT custum_container_valid
        EXPORTING
          container_name = 'CONT_VALID'.
      CREATE OBJECT grid_gt_list_valid
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_valid.
      CALL METHOD grid_gt_list_valid->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_valid
          it_fieldcatalog      = gt_fieldcat_valid.
      CREATE OBJECT event_receiver_gt_list_valid.

      SET HANDLER event_receiver_gt_list_valid->handle_valid FOR
                  grid_gt_list_valid.
      SET HANDLER event_receiver_gt_list_valid->handle_valid_view FOR
                  grid_gt_list_valid.
    ELSE.
      CALL METHOD grid_gt_list_valid->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF  screxit = c_marked.
    IF custum_container_screxit IS INITIAL.
      CREATE OBJECT custum_container_screxit
        EXPORTING
          container_name = 'CONT_SCREXIT'.
      CREATE OBJECT grid_gt_list_screxit
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_screxit.
      CALL METHOD grid_gt_list_screxit->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_screxit
          it_fieldcatalog      = gt_fieldcat_screxit.
      CREATE OBJECT event_receiver_gt_list_screxit.

      SET HANDLER event_receiver_gt_list_screxit->handle_screxit FOR
                  grid_gt_list_screxit.
      SET HANDLER event_receiver_gt_list_screxit->handle_screxit_view FOR
                  grid_gt_list_screxit.
    ELSE.
      CALL METHOD grid_gt_list_screxit->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF  modcua = c_marked.
    IF custum_container_menuex IS INITIAL.
      CREATE OBJECT custum_container_menuex
        EXPORTING
          container_name = 'CONT_MENUEX'.
      CREATE OBJECT grid_gt_list_menuex
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_menuex.
      CALL METHOD grid_gt_list_menuex->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_menuex
          it_fieldcatalog      = gt_fieldcat_menuex.
      CREATE OBJECT event_receiver_gt_list_menuex.

      SET HANDLER event_receiver_gt_list_menuex->handle_menuex FOR
                  grid_gt_list_menuex.
      SET HANDLER event_receiver_gt_list_menuex->handle_menuex_view FOR
                  grid_gt_list_menuex.
    ELSE.
      CALL METHOD grid_gt_list_menuex->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF  modwrd = c_marked.
    IF custum_container_modwrd IS INITIAL.
      CREATE OBJECT custum_container_modwrd
        EXPORTING
          container_name = 'CONT_MODWRD'.
      CREATE OBJECT grid_gt_list_modwrd
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_modwrd.
      CALL METHOD grid_gt_list_modwrd->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_modwrd
          it_fieldcatalog      = gt_fieldcat_modwrd.
      CREATE OBJECT event_receiver_gt_list_modwrd.

      SET HANDLER event_receiver_gt_list_modwrd->handle_modwrd FOR
                  grid_gt_list_modwrd.
      SET HANDLER event_receiver_gt_list_modwrd->handle_modwrd_view FOR
                  grid_gt_list_modwrd.
    ELSE.
      CALL METHOD grid_gt_list_modwrd->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF hookimpl = c_marked.   "c_marked = 'X'
    IF custum_container_hookimpl IS INITIAL.
      CREATE OBJECT custum_container_hookimpl
        EXPORTING
          container_name = 'CONT_HOOKIMPL'.
      CREATE OBJECT grid_gt_list_hookimpl
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_hookimpl.
      CALL METHOD grid_gt_list_hookimpl->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_hookimpl
          it_fieldcatalog      = gt_fieldcat_hookimpl.
      CREATE OBJECT event_receiver_gt_list_hookimp.

      SET HANDLER event_receiver_gt_list_hookimp->handle_hook FOR
                  grid_gt_list_hookimpl.
      SET HANDLER event_receiver_gt_list_hookimp->handle_hook_view FOR
                  grid_gt_list_hookimpl.

    ELSE.
      CALL METHOD grid_gt_list_hookimpl->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF fugrimpl = c_marked.   "c_marked = 'X'
    IF custum_container_fugrenh IS INITIAL.
      CREATE OBJECT custum_container_fugrenh
        EXPORTING
          container_name = 'CONT_FUGRENH'.
      CREATE OBJECT grid_gt_list_fugrenh
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_fugrenh.
      CALL METHOD grid_gt_list_fugrenh->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_fugrenh
          it_fieldcatalog      = gt_fieldcat_fugrenh.
      CREATE OBJECT event_receiver_gt_list_fugrenh.

      SET HANDLER event_receiver_gt_list_fugrenh->handle_fugr FOR
                  grid_gt_list_fugrenh.
      SET HANDLER event_receiver_gt_list_fugrenh->handle_fugr_view FOR
                  grid_gt_list_fugrenh.

    ELSE.
      CALL METHOD grid_gt_list_fugrenh->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF clasimpl = c_marked.   "c_marked = 'X'
    IF custum_container_clasenh IS INITIAL.
      CREATE OBJECT custum_container_clasenh
        EXPORTING
          container_name = 'CONT_CLASENH'.
      CREATE OBJECT grid_gt_list_clasenh
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_clasenh.
      CALL METHOD grid_gt_list_clasenh->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_clasenh
          it_fieldcatalog      = gt_fieldcat_clasenh.
      CREATE OBJECT event_receiver_gt_list_clasenh.

      SET HANDLER event_receiver_gt_list_clasenh->handle_clas FOR
                  grid_gt_list_clasenh.
      SET HANDLER event_receiver_gt_list_clasenh->handle_clas_view FOR
                  grid_gt_list_clasenh.

    ELSE.
      CALL METHOD grid_gt_list_clasenh->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

  IF badiimpl = c_marked.
    IF custum_container_badiimpl IS INITIAL.
      CREATE OBJECT custum_container_badiimpl
        EXPORTING
          container_name = 'CONT_BADIIMPL'.
      CREATE OBJECT grid_gt_list_badiimpl
        EXPORTING
          i_appl_events = 'X'
          i_parent      = custum_container_badiimpl.
      CALL METHOD grid_gt_list_badiimpl->set_table_for_first_display
        EXPORTING
          it_toolbar_excluding = gt_excl_button
        CHANGING
          it_outtab            = gt_list_badiimpl
          it_fieldcatalog      = gt_fieldcat_badiimpl.
      CREATE OBJECT event_receiver_gt_list_badiimp.

      SET HANDLER event_receiver_gt_list_badiimp->handle_nbadi FOR
                  grid_gt_list_badiimpl.

      SET HANDLER event_receiver_gt_list_badiimp->handle_nbadi_view FOR
                  grid_gt_list_badiimpl.

    ELSE.
      CALL METHOD grid_gt_list_badiimpl->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " create_ALVs  OUTPUT
