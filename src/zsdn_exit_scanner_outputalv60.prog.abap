*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_EXIT_SCANNER_OUTPUT_ALV
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM output_alv                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FIELD                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM field TABLES lt_fieldcat1 STRUCTURE lvc_s_fcat
            USING fie tab typ reftab refnam key emp row col len noo sum sel. "#EC *

  DATA: afield TYPE lvc_s_fcat.

  afield-fieldname     = fie.
  afield-reptext       = sel.
  afield-tabname       = tab.
  afield-key           = key.
  afield-key_sel       = key.
  afield-ref_table     = reftab.
  afield-ref_field    = refnam.
  afield-sp_group      = 'A'.
  afield-row_pos       = row.
  afield-emphasize     = emp.
  afield-no_out        = noo.
  afield-col_pos       = col.
  afield-no_sum        = sum.
  afield-outputlen     = len.
  afield-datatype      = typ.

  IF typ = 'IC'.    "Internal Use; Icon Format
    afield-icon = abap_true.
    CLEAR afield-datatype.
  ENDIF.


  APPEND afield TO lt_fieldcat1.

ENDFORM.                    " FIELD

*&---------------------------------------------------------------------*
*&      Form  output_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GT_LIST    text
*----------------------------------------------------------------------*
FORM output_alv USING gt_list LIKE gt_list.

  DATA:    lt_fieldcat                      TYPE TABLE OF lvc_s_fcat,
           ls_fieldcat                      TYPE          lvc_s_fcat.

  READ TABLE gt_list INTO gs_list INDEX 1.

  CASE gs_list-object_type.

    WHEN c_userexit.

      gt_list_userexit = gt_list.
      count_userexit = g_counter.

      PERFORM field  TABLES lt_fieldcat
*                    field       table     typ    rftab   rfnam    key emp row  col  len  noo sum desr
              USING: 'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '01' '30' ' ' ' ' 'Routine Name',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '02' '15' ' ' ' ' 'Include Name',
                     'PACK_NAME' 'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '04' '15' ' ' ' ' 'Dev.Class',
                     'TEXT'      'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '03' '50' ' ' ' ' 'Description Text',
                     'CNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '06' '12' ' ' ' ' 'Created By',
                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '07' '10' ' ' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '08' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '09' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_userexit = lt_fieldcat.

    WHEN c_vofm.

      gt_list_vofm = gt_list.
      count_vofm = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam    key emp row  col  len  noo sum desr
              USING: 'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '01' '30' ' ' ' ' 'Routine Name',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '02' '15' ' ' ' ' 'Include Name',
                     'PACK_NAME' 'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '04' '10' ' ' ' ' 'Dev.Class',
                     'TEXT'      'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '03' '50' ' ' ' ' 'Description Text',
                     'CNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '06' '12' ' ' ' ' 'Created By',
                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '07' '10' ' ' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '08' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '09' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_vofm = lt_fieldcat.

    WHEN c_valid.

      gt_list_valid = gt_list.
      count_valid = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam    key emp row  col  len  noo sum desr
              USING: 'MOD'       'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '01' '15' ' ' ' ' 'Valid.Name',
                     'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '02' '30' ' ' ' ' 'Text',
                     'CUST_INC'  'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '03' '04' ' ' ' ' 'Step',
                     'TEXT2'     'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '04' '50' ' ' ' ' 'StepText',
                     'IMP_NAME'  'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '05' '04' ' ' ' ' 'Exit',
                     'TEXT3'     'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '06' '30' ' ' ' ' 'Exit Text',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '07' '30' ' ' ' ' 'Formpool',
                     'CNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '08' '12' ' ' ' ' 'Created By',
                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '09' '10' ' ' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '10' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '11' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_valid = lt_fieldcat.

    WHEN c_subst.

      gt_list_subst = gt_list.
      count_subst = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam    key emp row  col  len  noo sum desr
              USING: 'MOD'       'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '01' '15' ' ' ' ' 'Subst.Name',
                     'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '02' '30' ' ' ' ' 'Text',
                     'CUST_INC'  'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '03' '04' ' ' ' ' 'Step',
                     'TEXT2'     'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '04' '50' ' ' ' ' 'StepText',
                     'IMP_NAME'  'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '05' '04' ' ' ' ' 'Exit',
                     'TEXT3'     'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '06' '30' ' ' ' ' 'Exit Text',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '07' '30' ' ' ' ' 'Formpool',
                     'CNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '08' '12' ' ' ' ' 'Created By',
                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '09' '10' ' ' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '10' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '11' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_subst = lt_fieldcat.

    WHEN c_screxit.

      gt_list_screxit = gt_list.
      count_screxit   = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam  key emp    row  col  len  noo sum desr
              USING: 'USED_IN'   'GT_LIST' ' '    ' '     ' '    'X' ' '    '01' '01' '30' ' ' ' ' 'Calling Screen',
                     'NAME'      'GT_LIST' ' '    ' '     ' '    'X' ' '    '01' '02' '10' ' ' ' ' 'Dynpro Nr.',
                     'PACK_NAME' 'GT_LIST' ' '    ' '     ' '    'X' ' '    '01' '03' '08' ' ' ' ' 'Area',
                     'IMP_NAME'  'GT_LIST' ' '    ' '     ' '    'X' 'C110' '01' '04' '30' ' ' ' ' 'Called Screen',
                     'CUST_INC'  'GT_LIST' ' '    ' '     ' '    'X' 'C110' '01' '05' '10' ' ' ' ' 'Dynpro Nr.',
                     'PROJEKT'   'GT_LIST' 'CHAR' ' '     ' '    ' ' ' '    '01' '06' '15' ' ' ' ' 'Project',
                     'MOD'       'GT_LIST' 'CHAR' ' '     ' '    ' ' ' '    '01' '07' '10' ' ' ' ' 'Modification',
                     'CNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' '    '01' '08' '12' ' ' ' ' 'Created By',
                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' '    '01' '09' '10' ' ' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' '    '01' '10' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' '    '01' '11' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_screxit = lt_fieldcat.

    WHEN c_menuex.

      gt_list_menuex = gt_list.
      count_menuex   = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam  key emp row  col  len  noo sum desr
              USING: 'CUST_INC'  'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '01' '30' ' ' ' ' 'Code',
                     'IMP_NAME'  'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '02' '30' ' ' ' ' 'Program',
                     'PROJEKT'   'GT_LIST' 'CHAR' ' '     ' '    ' ' ' ' '01' '03' '15' ' ' ' ' 'Project',
                     'MOD'       'GT_LIST' 'CHAR' ' '     ' '    ' ' ' ' '01' '04' '10' ' ' ' ' 'Modification',
                     'CNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '05' '12' ' ' ' ' 'Created By',
                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' ' '01' '09' '10' ' ' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '10' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' ' '01' '11' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_menuex = lt_fieldcat.


    WHEN c_modwrd.

      gt_list_modwrd = gt_list.
      count_modwrd   = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam   key emp row  col  len  noo sum desr
              USING: 'LANGU'     'GT_LIST' ' '    'SYST'  'LANGU' 'X' ' ' '01' '01' '11' ' ' ' ' 'Maint.Lang.',
                     'PROJEKT'   'GT_LIST' 'CHAR' ' '     ' '     'X' ' ' '01' '02' '04' ' ' ' ' 'Rel.',
                     'NAME'      'GT_LIST' ' '    ' '     ' '     'X' ' ' '01' '03' '30' ' ' ' ' 'Data Element',
                     'MOD'       'GT_LIST' 'CHAR' ' '     ' '     ' ' ' ' '01' '04' '10' ' ' ' ' 'Lables',
                     'TEXT2'     'GT_LIST' 'CHAR' ' '     ' '     ' ' ' ' '01' '05' '60' ' ' ' ' 'Original Sap',
                     'TEXT3'     'GT_LIST' ' '    ' '     ' '     ' ' ' ' '01' '06' '30' ' ' ' ' 'Changed by Customer'.

      gt_fieldcat_modwrd = lt_fieldcat.

    WHEN c_hook.

      gt_list_hookimpl = gt_list.
      count_hookimpl   = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam  key emp row  col  len  noo sum desr
              USING:
                     'IMP_NAME'  'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '01' '30' ' ' ' ' 'Ehnancement Impl.',
                     'TEXT'      'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '02' '30' ' ' ' ' 'Description',
                     'NAME'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '03' '15' ' ' ' ' 'Spot name',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '04' '15' ' ' ' ' 'Program Name',
                     'TEXT2'     'GT_LIST' 'CHAR' ' '     ' '    ' ' ' ' '01' '07' '15' ' ' ' ' 'Enh.Implementation Type',
                     'TEXT3'     'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '08' '30' ' ' ' ' 'Enhancement Implementation Point/Section',
*                    'MOD'       'GT_LIST' 'CHAR' ' '     ' '    ' ' ' ' '01' '09' '10' 'X' ' ' 'Enhancem.Technique',
*                    'CNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '05' '12' 'X' ' ' 'Created By',
*                    'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' ' '01' '09' '10' 'X' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '10' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' ' '01' '11' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_hookimpl = lt_fieldcat.

    WHEN c_fugr.

      gt_list_fugrenh = gt_list.
      count_fugrenh   = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam  key emp row  col  len  noo sum desr
              USING:
                     'IMP_NAME'  'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '01' '30' ' ' ' ' 'Ehnancement Impl.',
                     'TEXT'      'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '02' '30' ' ' ' ' 'Description',
                     'NAME'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '03' '30' ' ' ' ' 'Function Name',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '04' '20' ' ' ' ' 'Parameter',
                     'CUST_INC'  'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '05' '10' ' ' ' ' 'Type',
                     'TEXT2'     'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '06' '15' ' ' ' ' 'Structure',
                     'PROJEKT'   'GT_LIST' 'CHAR' ' '     ' '    ' ' ' ' '01' '07' '10' ' ' ' ' 'Default',
                     'TEXT3'     'GT_LIST' 'CHAR' ' '     ' '    ' ' ' ' '01' '08' '30' ' ' ' ' 'Short text',
*                    'MOD'       'GT_LIST' 'CHAR' ' '     ' '    ' ' ' ' '01' '09' '10' 'X' ' ' 'Enhancem.Technique',
*                    'CNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '05' '12' 'X' ' ' 'Created By',
*                    'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' ' '01' '09' '10' 'X' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '10' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' ' '01' '11' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_fugrenh = lt_fieldcat.

    WHEN c_clas.

      gt_list_clasenh = gt_list.
      count_clasenh   = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field        table     typ   rftab   rfnam  key emp row  col  len  noo sum desr
              USING:
                    'IMP_NAME'    'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '01' '30' ' ' ' ' 'Ehnancement Impl.',
                    'TEXT'        'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '02' '30' ' ' ' ' 'Description',
                    'NAME'        'GT_LIST' 'CHAR' ' '     ' '    'X' ' ' '01' '03' '30' ' ' ' ' 'Class Name',
                    'ATTRIBUTES'  'GT_LIST' 'IC'   ' '     ' '    ' ' ' ' '01' '04' '10' ' ' ' ' 'Attributes',
                    'PARAMETERS'  'GT_LIST' 'IC'   ' '     ' '    ' ' ' ' '01' '05' '10' ' ' ' ' 'Parameters',
                    'PRE_METH'    'GT_LIST' 'IC'   ' '     ' '    ' ' ' ' '01' '06' '10' ' ' ' ' 'Pre Meth.',
                    'POST_METH'   'GT_LIST' 'IC'   ' '     ' '    ' ' ' ' '01' '07' '10' ' ' ' ' 'Post Meth.',
                    'OVERWR_METH' 'GT_LIST' 'IC'   ' '     ' '    ' ' ' ' '01' '08' '15' ' ' ' ' 'Overwrite Meth.',
                    'ENH_METH'    'GT_LIST' 'IC'   ' '     ' '    ' ' ' ' '01' '09' '10' ' ' ' ' 'New Meth.',
                    'ENH_EVT'     'GT_LIST' 'IC'   ' '     ' '    ' ' ' ' '01' '10' '10' ' ' ' ' 'New Events.',
                    'ENH_INTF'    'GT_LIST' 'IC'   ' '     ' '    ' ' ' ' '01' '11' '10' ' ' ' ' 'New Interf.',
*                    'MOD'       'GT_LIST' 'CHAR'  ' '     ' '    ' ' ' ' '01' '09' '10' 'X' ' ' 'Enhancem.Technique',
*                    'CNAM'      'GT_LIST' ' '     ' '     ' '    ' ' ' ' '01' '05' '12' 'X' ' ' 'Created By',
*                    'CDAT'      'GT_LIST' ' '     'TRDIR' 'CDAT' ' ' ' ' '01' '09' '10' 'X' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '     ' '     ' '    ' ' ' ' '01' '12' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '     'TRDIR' 'CDAT' ' ' ' ' '01' '13' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_clasenh = lt_fieldcat.

    WHEN c_nbadi.

      gt_list_badiimpl = gt_list.
      count_badiimpl   = g_counter.

      PERFORM field  TABLES lt_fieldcat
*------------------  field        table   typ   rftab   rfnam  key emp row  col  len  noo sum desr
              USING:
                    'IMP_NAME'  'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '01' '30' ' ' ' ' 'Ehnancement Impl.',
                    'TEXT'      'GT_LIST' ' '    ' '     ' '    'X' ' ' '01' '02' '30' ' ' ' ' 'Description',
                    'USED_IN'   'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '03' '30' ' ' ' ' 'Impl.Class',
                    'NAME'      'GT_LIST' 'CHAR' ' '     ' '    'X' ' ' '01' '04' '30' ' ' ' ' 'Spot Name',
                    'CNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '05' '12' 'X' ' ' 'Created By',
                    'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' ' '01' '06' '10' 'X' ' ' 'Created On',
                    'UNAM'      'GT_LIST' ' '    ' '     ' '    ' ' ' ' '01' '07' '12' ' ' ' ' 'Changed By',
                    'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT' ' ' ' ' '01' '08' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_badiimpl = lt_fieldcat.

    WHEN c_append.

      gt_list_append = gt_list.
      count_append = g_counter.

      PERFORM field  TABLES lt_fieldcat
*                    field       table     typ    rftab   rfnam    key emp row  col  len  noo sum desr
              USING: 'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '01' '30' ' ' ' ' 'Append Name',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '02' '30' ' ' ' ' 'Used in Table',
                     'PACK_NAME' 'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '03' '30' ' ' ' ' 'Dev.Class',
                     'TEXT'      'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '04' '50' ' ' ' ' 'Description Text'.
*                    'CNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '06' '12' ' ' ' ' 'Created By',
*                    'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '07' '10' ' ' ' ' 'Created On',
*                    'UNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '08' '12' ' ' ' ' 'Changed By',
*                    'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '09' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_append = lt_fieldcat.

    WHEN c_ci_incl.

      gt_list_ci_incl = gt_list.
      count_ci_incl = g_counter.

      PERFORM field  TABLES lt_fieldcat
*                    field       table     typ    rftab   rfnam    key emp row  col  len  noo sum desr
              USING: 'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '01' '30' ' ' ' ' 'CI_Include Name',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '02' '30' ' ' ' ' 'Used in Table',
                     'PACK_NAME' 'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '03' '30' ' ' ' ' 'Dev.Class',
                     'TEXT'      'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '04' '50' ' ' ' ' 'Description Text'.
*                     'CNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '06' '12' ' ' ' ' 'Created By',
*                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '07' '10' ' ' ' ' 'Created On',
*                     'UNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '08' '12' ' ' ' ' 'Changed By',
*                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '09' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_ci_incl = lt_fieldcat.

    WHEN c_custex.

      count_custex = g_counter.
      gt_list_custex = gt_list.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam    key emp row  col  len  noo sum desr
              USING: 'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '01' '30' ' ' ' ' 'Exit Name',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '02' '30' ' ' ' ' 'Dev.Class',
                     'MOD'       'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '03' '10' ' ' ' ' 'Modification',
                     'PROJEKT'   'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '04' '15' ' ' ' ' 'Project',
                     'CUST_INC'  'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '05' '15' ' ' ' ' 'Customer Include',
                     'TEXT'      'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '06' '50' ' ' ' ' 'Description Text'.
*                     'CNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '08' '12' ' ' ' ' 'Created By',
*                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '09' '10' ' ' ' ' 'Created On',
*                     'UNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '10' '12' ' ' ' ' 'Changed By',
*                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' ' '01' '11' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_custex = lt_fieldcat.

    WHEN  c_badi.

      count_badi = g_counter.
      gt_list_badi = gt_list.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam    key emp    row  col  len  noo sum desr
              USING: 'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' '    '01' '01' '30' ' ' ' ' 'Definition Name',
                     'IMP_NAME'  'GT_LIST' ' '    ' '     ' '      ' ' 'C110' '01' '02' '30' ' ' ' ' 'Implement. Name',
                     'PACK_NAME' 'GT_LIST' ' '    ' '     ' '      ' ' ' '    '01' '03' '30' ' ' ' ' 'Dev.Class',
                     'TEXT'      'GT_LIST' 'CHAR' ' '     ' '      ' ' ' '    '01' '04' '50' ' ' ' ' 'Description Text',
                     'CNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' '    '01' '05' '12' ' ' ' ' 'Created By',
                     'CDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' '    '01' '06' '10' ' ' ' ' 'Created On',
                     'UNAM'      'GT_LIST' ' '    ' '     ' '      ' ' ' '    '01' '07' '12' ' ' ' ' 'Changed By',
                     'UDAT'      'GT_LIST' ' '    'TRDIR' 'CDAT'   ' ' ' '    '01' '08' '10' ' ' ' ' 'Changed On'.

      gt_fieldcat_badi = lt_fieldcat.


    WHEN c_fieldex.

      count_fieldex = g_counter.
      gt_list_fieldex = gt_list.

      PERFORM field  TABLES lt_fieldcat
*------------------  field       table     typ    rftab   rfnam    key emp row  col  len  noo sum desr
              USING: 'NAME'      'GT_LIST' 'CHAR' ' '     ' '      'X' ' ' '01' '01' '30' ' ' ' ' 'on Data Element',
                     'USED_IN'   'GT_LIST' ' '    ' '     ' '      ' ' ' ' '01' '02' '30' ' ' ' ' 'Used in Program',
                     'MOD'       'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '03' '15' ' ' ' ' 'Dynpro Nr.',
                     'IMP_NAME'  'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '04' '30' ' ' ' ' 'Dev. Class',
                     'TEXT'      'GT_LIST' 'CHAR' ' '     ' '      ' ' ' ' '01' '05' '30' ' ' ' ' 'Description Text'.

      gt_fieldcat_fieldex = lt_fieldcat.

    WHEN c_bte_pas OR c_bte_pro.

      count_bte = g_counter.
      gt_list_bte = gt_list.

      PERFORM field  TABLES lt_fieldcat
*------------------  field         table     typ    rftab   rfnam    key emp    row  col  len  noo sum desr
              USING: 'OBJECT_TYPE' 'GT_LIST' 'CHAR' ' '     ' '      'X' ' '    '01' '01' '15' ' ' ' ' 'BTE Type',
                     'NAME'        'GT_LIST' 'CHAR' ' '     ' '      ' ' ' '    '01' '05' '30' ' ' ' ' 'EVENT/PROCESS',
                     'PACK_NAME'   'GT_LIST' ' '    ' '     ' '      ' ' ' '    '01' '02' '30' ' ' ' ' 'Implement. Name',
                     'USED_IN'     'GT_LIST' 'CHAR' ' '     ' '      ' ' ' '    '01' '04' '30' ' ' ' ' 'Package Name',
                     'IMP_NAME'    'GT_LIST' 'CHAR' ' '     ' '      ' ' ' '    '01' '03' '50' ' ' ' ' 'Open FI/Outbound Call Name',
                     'TEXT'        'GT_LIST' 'CHAR' ' '     ' '      ' ' ' '    '01' '06' '30' ' ' ' ' 'Description Text'.

      gt_fieldcat_bte = lt_fieldcat.


    WHEN OTHERS.
      CLEAR ls_fieldcat.
      ls_fieldcat-fieldname   = 'NAME'.
      ls_fieldcat-reptext     =  'Not working'.             "#EC NOTEXT
      ls_fieldcat-row_pos     = 1.
      ls_fieldcat-col_pos     = 1.
      ls_fieldcat-outputlen   = 15.
      ls_fieldcat-datatype    = 'CHAR'.
      ls_fieldcat-tabname     = 'GT_LIST'.
      APPEND ls_fieldcat TO lt_fieldcat.

  ENDCASE.
*****end of fieldcat creation*****


  ls_excl_button = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_excl_button TO gt_excl_button.
  ls_excl_button = cl_gui_alv_grid=>mc_fc_help.
  APPEND ls_excl_button TO gt_excl_button.
  ls_excl_button = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_excl_button TO gt_excl_button.
  ls_excl_button = cl_gui_alv_grid=>mc_fc_print.
  APPEND ls_excl_button TO gt_excl_button.
  ls_excl_button = cl_gui_alv_grid=>mc_mb_sum.
  APPEND ls_excl_button TO gt_excl_button.
  ls_excl_button = cl_gui_alv_grid=>mc_mb_view.
  APPEND ls_excl_button TO gt_excl_button.
  ls_excl_button = cl_gui_alv_grid=>mc_mb_variant.
  APPEND ls_excl_button TO gt_excl_button.

  REFRESH lt_fieldcat.
ENDFORM.                    "output_alv
