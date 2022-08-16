*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDN_EXIT_SCANNER_FORMS .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  JOIN_TEXTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM join_textp  USING    program                           "#EC *
                 CHANGING text.                             "#EC *

  DATA texttab TYPE TABLE OF textpool WITH HEADER LINE.

  READ TEXTPOOL program INTO texttab. " language sy-langu.
  CHECK sy-subrc EQ 0.
  READ TABLE texttab WITH KEY id = 'R'.
  CHECK sy-subrc EQ 0.
  MOVE texttab-entry TO text.

ENDFORM.                    " JOIN_TEXTP
*&---------------------------------------------------------------------*
*&      Form  SAPGUI_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sapgui_progress_indicator USING    p_text .            "#EC *

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = p_text.

ENDFORM.                               " SAPGUI_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*&      Form  get_formpool
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM get_formpool  USING    exitsubst                       "#EC *
                            value(p_0301)
                   CHANGING formpool.                       "#EC *
  CLEAR formpool.
  CALL FUNCTION 'G_BOOL_CHECK_EXIT'
    EXPORTING
      exitname  = exitsubst
      usage_typ = p_0301
    IMPORTING
      poolname  = formpool
    EXCEPTIONS
      OTHERS    = 0.
ENDFORM.                    " get_formpool
*&---------------------------------------------------------------------*
*&      Form  get_exit_title
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_exit_title  USING    exit_name                     "#EC *
                              value(p_0315)
                     CHANGING ltxt.                         "#EC *

  CLEAR ltxt.
  CALL FUNCTION 'G_BOOL_CHECK_EXIT'
    EXPORTING
      exitname          = exit_name
      usage_typ         = p_0315
    IMPORTING
      exit_title        = ltxt
    EXCEPTIONS
      invalid_exitname  = 0
      non_existing_pool = 0
      synt_err_in_pool  = 0
      non_existing_exit = 0
      OTHERS            = 0.

ENDFORM.                    " get_exit_title
**&---------------------------------------------------------------------*
**&      Form  get_enh_position
**&---------------------------------------------------------------------*
**       Copied from SAPLENH_EDT_HOOK
**----------------------------------------------------------------------*
**      -->P_L_IMPL      IMPL-Struktur
**      -->P_L_OBJ_NAME  Objektname(Hauptprogramm->/Include<-)
**      -->P_L_LINE      Zeile in der sich das Enhancement beindet
**----------------------------------------------------------------------*
*form get_enh_position  using    p_l_impl  TYPE enh_hook_impl
*                                p_include TYPE program
*                                p_l_line
*                                l_g_enhname l_g_version l_g_main_type.
*
*
*DATA : L_PROGRAM_TO_SCAN TYPE  PROGRAM,
*       L_PROGRAM_STATE   TYPE  R3STATE VALUE 'I',
*       L_HOOK            TYPE  enhname,
*       l_otype           TYPE  enhcross-otype,
*       L_CROSS           TYPE  enhcross,
*       L_SRC             TYPE rswsourcet,
*       L_MODUNIT_TO_FIND TYPE  STRING ,
*       L_MODTYPE_TO_FIND TYPE  PROGRAM VALUE 'ENHANCEMENT-POINT'.
*
*l_program_to_scan = p_l_impl-programname.
*
*CALL FUNCTION 'ENH_GET_HOOK_FROM_FULLNAME'
*  EXPORTING
*    p_fullname       = p_l_impl-full_name
*  IMPORTING
*    P_HOOK           = l_hook
*    P_INCLUDE        = l_program_to_scan
**   P_PROGRAM        =
*          .
*l_modunit_to_find = l_hook.
*
** Vorbereitung ENHCROSS Lesen
*
*IF p_l_impl-full_name CS '\EX:'.
*   l_otype = 'EX'.
*ELSE.
*   l_otype = 'EI'.
*ENDIF.
*
*SELECT SINGLE * FROM enhcross INTO L_CROSS
*     WHERE enhname = l_g_enhname
*     AND   version = l_g_version
*     AND   otype   = l_otype
*     AND   hook    = l_hook.
*
*IF sy-subrc = 0.
*   L_PROGRAM_TO_SCAN = l_cross-include.
*   l_modunit_to_find = l_cross-hook.
*ENDIF.
*
*IF    l_otype = 'EI'.
*   l_modunit_to_find = l_g_enhname.
** Achtung hier müsste eigentlich der CL_ABAP_COMPILER aufgerufen werden, da er ohnehin vom
** SWF_INSERT_ENHANCEMENTS aufgerufen wird. Siehe den Aufruf in FuBa ENH_GET_SOURCE_ENHANCED
** Eventuell sollte man hier einen ENH_SCN_FOR_CROSS_COMPILER aufrufen oder der
** den ENH_SCAN_FOR_CROSS um einen entsprechenden Parameter erweitern und dort intern
** anders verfahren.
*ENDIF.
*
*CALL FUNCTION 'ENH_SCAN_FOR_CROSS'
*  EXPORTING
*    i_program_to_scan       = l_program_to_scan
*    i_program_state         = l_program_state
*    i_modunit_to_find       = l_modunit_to_find
*    i_modtype_to_find       = l_modtype_to_find
*    i_enhanced              = 'X'
*  IMPORTING
*    E_INCLUDE               = p_include
*    E_LINE_NR               = p_l_line
**   E_HOOKTYPE              =
**   E_SOURCE_LINE           =
*          .
*
*IF  p_include = SPACE
*AND l_cross-include <> SPACE.
*  p_include = l_cross-include.
*ENDIF.
*
*IF p_include <> l_program_to_scan.
*
*   PERFORM determine_line USING p_l_line
*                                p_include
*                                l_src
*                                l_program_to_scan l_g_main_type.
*
*    CALL FUNCTION 'ENH_SCAN_FOR_CROSS'
*      EXPORTING
*        i_program_to_scan       = p_include
*        i_program_state         = l_program_state
*        i_modunit_to_find       = l_modunit_to_find
*        i_modtype_to_find       = l_modtype_to_find
*        i_enhanced              = 'S'
*        i_src                   = l_src
*      IMPORTING
*        E_INCLUDE               = p_include
*        E_LINE_NR               = p_l_line
**       E_HOOKTYPE              =
**       E_SOURCE_LINE           =
*              .
*
*
*ENDIF.
*
*endform.                    " get_enh_position
**&---------------------------------------------------------------------*
**&      Form  determine_line
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_P_L_LINE  text
**      -->P_P_INCLUDE  text
**      -->P_L_PROGRAM_TO_SCAN  text
**----------------------------------------------------------------------*
*form determine_line  using    p_p_l_line
*                              p_p_include
*                              p_l_src
*                              p_l_program_to_scan
*                              l_g_main_type.
*
*DATA : l_trkey     TYPE trkey,
*       l_obj       TYPE trobj_name,
*       l_namespace TYPE rs38l-namespace,
*       l_area      TYPE rs38l-area,
*       l_seocpdkey TYPE seocpdkey.
*
*   CASE l_g_main_type.
*      WHEN 'CLAS'.
*         CALL FUNCTION 'ENH_BUILD_OBJECT_FROM_NAME'
*            EXPORTING
*               p_name        = p_l_program_to_scan
*            IMPORTING
*               E_TYPE        = l_trkey-obj_type
*               E_NAME        = l_obj.
*
*         l_trkey-obj_name = l_obj.
*         l_trkey-sub_type = 'METH'.
*         l_trkey-sub_name = p_p_include.
*
*      WHEN 'LDBA'.
*
*         CALL FUNCTION 'ENH_BUILD_OBJECT_FROM_NAME'
*            EXPORTING
*               p_name        = p_l_program_to_scan
*            IMPORTING
*               E_TYPE        = l_trkey-obj_type
*               E_NAME        = l_obj.
*
*         l_trkey-obj_name = l_obj.
*         l_trkey-sub_type = 'REPS'.
*         l_trkey-sub_name = p_p_include.
*
*      WHEN 'PROG'.
*         SELECT SINGLE devclass INTO l_trkey-devclass FROM tadir
*             WHERE pgmid    = 'R3TR'
*             AND   object   = 'PROG'
*             AND   obj_name = p_p_include.
*         l_trkey-OBJ_TYPE = 'PROG'.
*         l_trkey-OBJ_NAME = p_l_program_to_scan.
*         l_trkey-SUB_TYPE = 'REPS'.
*         l_trkey-SUB_NAME = p_p_include.
*
*      WHEN 'FUGR'.
*
*         CALL FUNCTION 'FUNCTION_INCLUDE_SPLIT'
**          EXPORTING
**            PROGRAM                            =
**            SUPPRESS_SELECT                    = 'X'
**            COMPLETE_AREA                      = ' '
*           IMPORTING
*             NAMESPACE                          = l_namespace
**            FUNCTION_NOT_EXISTS                =
*             GROUP                              = l_area
**            FUNCNAME                           =
**            INCLUDE_NUMBER                     =
**            NO_FUNCTION_INCLUDE                =
**            NO_FUNCTION_MODULE                 =
**            SUFFIX                             =
**            RESERVED_NAME                      =
**            TOO_MANY_DELIMITERS                =
**            RESERVED_FOR_EXITS                 =
**            HIDDEN_NAME                        =
*           CHANGING
*             INCLUDE                            = p_p_include
*           EXCEPTIONS
*             INCLUDE_NOT_EXISTS                 = 1
*             GROUP_NOT_EXISTS                   = 2
*             NO_SELECTIONS                      = 3
*             NO_FUNCTION_INCLUDE                = 4
*             NO_FUNCTION_POOL                   = 5
*             DELIMITER_WRONG_POSITION           = 6
*             NO_CUSTOMER_FUNCTION_GROUP         = 7
*             NO_CUSTOMER_FUNCTION_INCLUDE       = 8
*             RESERVED_NAME_CUSTOMER             = 9
*             NAMESPACE_TOO_LONG                 = 10
*             AREA_LENGTH_ERROR                  = 11
*             OTHERS                             = 12
*                   .
*         IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*           EXIT.
*         ELSE.
*            CONCATENATE :
*               l_namespace
*               l_area
*            INTO
*               l_obj.
*         ENDIF.
*         SELECT SINGLE devclass INTO l_trkey-devclass FROM tadir
*             WHERE pgmid    = 'R3TR'
*             AND   object   = 'FUGR'
*             AND   obj_name = l_obj.
*
*         l_trkey-OBJ_TYPE = 'PROG'.
*         l_trkey-OBJ_NAME = p_l_program_to_scan.
*         l_trkey-SUB_TYPE = 'REPS'.
*         l_trkey-SUB_NAME = p_p_include.
*      WHEN 'REPS'.
*         SELECT SINGLE devclass INTO l_trkey-devclass FROM tadir
*             WHERE pgmid    = 'R3TR'
*             AND   object   = 'PROG'
*             AND   obj_name = p_p_include.
*         l_trkey-OBJ_TYPE = 'PROG'.
*         l_trkey-OBJ_NAME = p_p_include.
*         l_trkey-SUB_TYPE = 'REPS'.
*         l_trkey-SUB_NAME = p_p_include.
*
*   ENDCASE.
*
*CALL FUNCTION 'ENH_GET_SOURCE_ENHANCED'
*  EXPORTING
*    i_trkey         = l_trkey
*  IMPORTING
*    IT_SOURCE       = p_l_src.
*          .
*
*endform.                    " determine_line
