*&---------------------------------------------------------------------*
*& Report  ZSDN_EXIT_SCANNER60
*& Author: Andrea Olivieri
*&         Techedge SpA
*& Version: 1.0  - 2009/03/30
*& Title   SDN Simple Exit Scanner ( X-it RAY EYE )
*& Supported releases: SAP ECC 6.0
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDN_EXIT_SCANNER_OUTPUT
*&---------------------------------------------------------------------*

FORM output USING lt_list LIKE gt_list.

*sort the list and get the number of entries
  SORT lt_list .
  DELETE ADJACENT DUPLICATES FROM lt_list.
  DESCRIBE TABLE lt_list LINES g_counter.

  PERFORM output_alv USING lt_list.

ENDFORM.                    "output
