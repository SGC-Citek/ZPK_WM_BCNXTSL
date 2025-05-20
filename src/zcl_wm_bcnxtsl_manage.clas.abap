CLASS zcl_wm_bcnxtsl_manage DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: gt_data    TYPE TABLE OF zi_wm_bcnxtsl_custom.

    CLASS-METHODS:
      get_instance
        RETURNING
          VALUE(ro_instance) TYPE REF TO zcl_wm_bcnxtsl_manage,

      get_data
        IMPORTING io_request TYPE REF TO if_rap_query_request
        EXPORTING et_data    LIKE gt_data.
  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-DATA: instance TYPE REF TO zcl_wm_bcnxtsl_manage,
                gt_price TYPE TABLE OF zmd_fi_fmlt_price=>tys_yy_1_i_fmlt_price_type.
    CLASS-METHODS:
      get_price IMPORTING iv_date            TYPE dats
                          iv_year            TYPE gjahr
                          it_matnr           TYPE table
                RETURNING VALUE(lt_response) TYPE zmd_fi_fmlt_price=>tyt_yy_1_i_fmlt_price_type.

ENDCLASS.



CLASS ZCL_WM_BCNXTSL_MANAGE IMPLEMENTATION.


  METHOD get_data.
    DATA: lv_start_date   TYPE vdm_v_start_date,
          lv_end_date     TYPE vdm_v_end_date,
          p_period        TYPE fins_fiscalperiod,
          lv_period_type  TYPE nsdm_period_type VALUE 'Y',
*          lv_fiscal_year  TYPE fis_gjahr_no_conv,
          lr_fiscal_year  TYPE RANGE OF fis_gjahr_no_conv,
          lr_bukrs        TYPE RANGE OF bukrs,
          lr_werks        TYPE RANGE OF werks_d,
          lr_sobkz        TYPE RANGE OF sobkz,
          lr_matnr        TYPE RANGE OF matnr,
          lr_charg        TYPE RANGE OF charg_d,
          lr_mtart        TYPE RANGE OF mtart,
          lr_matkl        TYPE RANGE OF matkl,
          lr_storage      TYPE RANGE OF lgort_d_edi_ext,
          lr_z_grd        TYPE RANGE OF zi_wm_bcnxtsl_custom-z_grd,

          lv_check_author TYPE abap_boolean.

    " get filter by parameter -----------------------
    DATA(lt_parameter) = io_request->get_parameters( ).
    IF lt_parameter IS NOT INITIAL.
      LOOP AT lt_parameter REFERENCE INTO DATA(ls_parameter).
        CASE ls_parameter->parameter_name.
          WHEN 'P_PERIOD'.
            p_period        = ls_parameter->value .
*          WHEN 'P_FISCALYEAR'.
*            lv_fiscal_year  = ls_parameter->value.
          WHEN 'P_STARTDATE'.
            lv_start_date  = ls_parameter->value.
          WHEN 'P_ENDDATE'.
            lv_end_date  = ls_parameter->value.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    " get filter by parameter -----------------------

    " get range by filter ---------------------------
    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
    ENDTRY.
    IF lt_filter_cond IS NOT INITIAL.
      LOOP AT lt_filter_cond REFERENCE INTO DATA(ls_filter_cond).
        CASE ls_filter_cond->name.
          WHEN 'COMPANYCODE'.
            lr_bukrs = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'PLANT'.
            lr_werks = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'INVENTORYSPECIALSTOCKTYPE'.
            lr_sobkz = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'MATERIAL'.
            lr_matnr = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'BATCH'.
            lr_charg = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'PRODUCTTYPE'.
            lr_mtart = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'PRODUCTGROUP'.
            lr_matkl = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'STORAGELOCATION'.
            lr_storage = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'Z_GRD'.
            lr_z_grd = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN 'FISCALYEAR'.
            lr_fiscal_year = CORRESPONDING #( ls_filter_cond->range ) .
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    " get range by filter ---------------------------

    " get previous date
    SELECT SINGLE prevcalendardate
      FROM zi_calendardate_prev
      WHERE calendardate = @lv_start_date
      INTO @DATA(lv_prev_start_date).
    SELECT SINGLE prevcalendardate
      FROM zi_calendardate_prev
      WHERE calendardate = @lv_end_date
      INTO @DATA(lv_prev_end_date).

    "Check phần quyền được xem
    AUTHORITY-CHECK OBJECT 'ZAO_BCXTSL'
                        ID 'ACTVT'      FIELD '03'
                        ID 'ZAF_BCXTSL' FIELD 'X'.
    IF sy-subrc <> 0.
      lv_check_author = abap_false.
    ELSE.
      lv_check_author = abap_true.
    ENDIF.


    SELECT
           zmain~material,
           zmain~companycode,
           zmain~plant,
           zmain~inventoryspecialstocktype,
           zmain~sddocument,
           zmain~sddocumentitem,
           zmain~storagelocation,
           zmain~matlwrhsstkqtyinmatlbaseunit AS closingstock,
           zmain~materialbaseunit,
           zmain~batch,
           i_plant~plantname,
           i_companycode~companycodename,
           mara~\_text[ language = 'E' ]-productname,
           mara~producttype,
           mara~\_producttypename_2[ language = 'E' ]-producttypename   AS materialtypename,
           mara~productgroup,
           mara~\_productgrouptext_2[ language = 'E' ]-productgroupname AS productgroupname,
           mara~\_baseunitofmeasure-siunitcnvrsnratenumerator,
           mara~baseunit,
           t001l~storagelocationname,
           z_nx_ctt~quantity,
           z_nx~totalreceiptqty AS totalreceiptqtyctt,
           z_nx~totalissueqty   AS totalissueqtyctt,
           openingstock~matlwrhsstkqtyinmatlbaseunit AS openingstock,
           supplierprofile~supplierfullname,
           z_grd~charcfromdate AS z_grd,
           z_nsx~charcfromdate AS z_nsx,
           z_hsd~charcfromdate AS z_hsd,
           z_dsx~charcvalue    AS z_dsx,
           z_ncc~charcvalue    AS z_ncc,
           z_ghichu~charcvalue AS z_ghichu,
           z_lot~charcvalue    AS solot,
           z_csx~charcvalue    AS z_csx,
           z_hsqd~z_hsqd       AS z_hsqd,
           z_vun~charcvalue    AS zvun,
           z_shd~charcvalue    AS sohopdong,
           _cvt~charcvalue     AS vitri,
           _nsx~charcfromdate  AS ngaysanxuat,
            _hsd~charcfromdate AS hansudung,
           i_batch~supplier,
           @lv_prev_start_date      AS startdate,
           @lv_end_date             AS enddate,
           mara~yy1_chungnhan_prd,
           cn~description    AS yy1_chungnhan_prd_text,
           mara~yy1_dongsanpham_prd,
           dsp~description   AS yy1_dongsanpham_prd_text,
           mara~yy1_giaviphugia_prd,
           gvpg~description  AS yy1_giaviphugia_prd_text,
           mara~yy1_kichcohinhdangsize_prd,
           size~description  AS yy1_kichcosize_prd_text,
           mara~yy1_loaihinhsanxuat_prd,
           lhsp~description  AS yy1_loaihinhsanxuat_prd_text,
           mara~yy1_loaitpthuhoi_prd,
           ltpth~description AS yy1_loaitpthuhoi_prd_text,
           mara~yy1_quycachdonggoi_prd,
           qcdg~description  AS yy1_quycachdonggoi_prd_text,
           _ngsp~charcvalue  AS nguongocsanpham,
           _soldtoparty~customername1        AS soldtopartyname,
           marm~quantitynumerator,
           marm~quantitydenominator,
           marm~alternativeunit

    FROM zi_wm_bcnxtsl_key( p_startdate       = @lv_end_date,
                            p_enddate         = @lv_end_date,
                            p_periodtype      = @lv_period_type ) AS zmain
    LEFT JOIN zi_wm_bcnxtsl_key( p_startdate       = @lv_prev_start_date,
                                 p_enddate         = @lv_prev_start_date,
                                 p_periodtype      = @lv_period_type ) AS openingstock
                                ON openingstock~plant                     = zmain~plant
                               AND openingstock~material                  = zmain~material
                               AND openingstock~batch                     = zmain~batch
                               AND openingstock~sddocument                = zmain~sddocument
                               AND openingstock~sddocumentitem            = zmain~sddocumentitem
                               AND openingstock~inventoryspecialstocktype = zmain~inventoryspecialstocktype
                               AND openingstock~storagelocation           = zmain~storagelocation
    LEFT JOIN i_plant ON zmain~plant = i_plant~plant
    LEFT JOIN i_productunitsofmeasure AS marm
                                      ON marm~product         = zmain~material
                                     AND marm~alternativeunit = 'Z1'
    LEFT JOIN i_companycode ON zmain~companycode = i_companycode~companycode
    LEFT JOIN i_salesdocumentpartner AS vbpa
                                     ON ltrim( vbpa~salesdocument ,'0' ) = ltrim( zmain~sddocument ,'0' )
                                    AND vbpa~partnerfunction     = 'AG'
    LEFT JOIN zcore_i_profile_customer AS _soldtoparty ON _soldtoparty~customer        = vbpa~customer
    LEFT JOIN i_product AS mara
                        ON mara~product = zmain~material
    LEFT JOIN i_storagelocation AS t001l
                                ON t001l~storagelocation = zmain~storagelocation
    LEFT JOIN i_batch
           ON i_batch~plant    = zmain~plant
          AND i_batch~material = zmain~material
          AND i_batch~batch    = zmain~batch
    LEFT JOIN zcore_i_profile_supplier AS supplierprofile
                                       ON supplierprofile~supplier = i_batch~supplier
    LEFT JOIN i_customfieldcodelisttext AS cn
                                        ON cn~customfieldid = 'YY1_CHUNGNHAN'
                                       AND cn~code          = mara~yy1_chungnhan_prd
    LEFT JOIN i_customfieldcodelisttext AS dsp
                                        ON dsp~customfieldid = 'YY1_DONGSANPHAM'
                                       AND dsp~code          = mara~yy1_dongsanpham_prd
    LEFT JOIN i_customfieldcodelisttext AS gvpg
                             ON gvpg~customfieldid = 'YY1_GIAVIPHUGIA'
                            AND gvpg~code          = mara~yy1_giaviphugia_prd
    LEFT JOIN i_customfieldcodelisttext AS size
                             ON size~customfieldid  = 'YY1_KICHCOHINHDANGSIZE'
                            AND size~code           = mara~yy1_kichcohinhdangsize_prd
    LEFT JOIN i_customfieldcodelisttext AS lhsp
                             ON lhsp~customfieldid = 'YY1_LOAIHINHSANXUAT'
                            AND lhsp~code          = mara~yy1_loaihinhsanxuat_prd
    LEFT JOIN i_customfieldcodelisttext AS ltpth
                             ON ltpth~customfieldid  = 'YY1_LOAITPTHUHOI'
                            AND ltpth~code           = mara~yy1_loaitpthuhoi_prd
    LEFT JOIN i_customfieldcodelisttext AS qcdg
                             ON qcdg~customfieldid = 'YY1_QUYCACHDONGGOI'
                            AND qcdg~code          = mara~yy1_quycachdonggoi_prd
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_grd
                                   ON z_grd~material = zmain~material
                                  AND z_grd~batch    = zmain~batch
                                  AND z_grd~plant    = zmain~plant
                                  AND z_grd~characteristic = 'Z_GRD'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_nsx
                                   ON z_nsx~material = zmain~material
                                  AND z_nsx~batch    = zmain~batch
                                  AND z_nsx~plant    = zmain~plant
                                  AND z_nsx~characteristic = 'Z_NSX'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_vun
                                   ON z_vun~material = zmain~material
                                  AND z_vun~batch    = zmain~batch
                                  AND z_vun~plant    = zmain~plant
                                  AND z_vun~characteristic = 'Z_VUN'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_hsd
                                   ON z_hsd~material = zmain~material
                                  AND z_hsd~batch    = zmain~batch
                                  AND z_hsd~plant    = zmain~plant
                                  AND z_hsd~characteristic = 'Z_HSD'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_dsx
                                   ON z_dsx~material = zmain~material
                                  AND z_dsx~batch    = zmain~batch
                                  AND z_dsx~plant    = zmain~plant
                                  AND z_dsx~characteristic = 'Z_DSX'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_ncc
                                   ON z_ncc~material = zmain~material
                                  AND z_ncc~batch    = zmain~batch
                                  AND z_ncc~plant    = zmain~plant
                                  AND z_ncc~characteristic = 'Z_NCC'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_lot
                                   ON z_lot~material = zmain~material
                                  AND z_lot~batch    = zmain~batch
                                  AND z_lot~plant    = zmain~plant
                                  AND z_lot~characteristic = 'Z_LOT'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_ghichu
                                   ON z_ghichu~material = zmain~material
                                  AND z_ghichu~batch    = zmain~batch
                                  AND z_ghichu~plant    = zmain~plant
                                  AND z_ghichu~characteristic = 'Z_GHICHU'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_shd
                                   ON z_shd~material = zmain~material
                                  AND z_shd~batch    = zmain~batch
                                  AND z_shd~plant    = zmain~plant
                                  AND z_shd~characteristic = 'Z_SHD'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_csx
                                   ON z_csx~material = zmain~material
                                  AND z_csx~batch    = zmain~batch
                                  AND z_csx~plant    = zmain~plant
                                  AND z_csx~characteristic = 'Z_CSX'
    LEFT JOIN zi_wm_bcnxtslgt_char AS z_hsqd
                                   ON z_hsqd~material = zmain~material
                                  AND z_hsqd~batch    = zmain~batch
                                  AND z_hsqd~plant    = zmain~plant
                                  AND z_hsqd~characteristic = 'Z_HSQD'
     LEFT JOIN zi_wm_bcnxtslgt_char AS _nsx
                                   ON _nsx~material = zmain~material
                                  AND _nsx~batch    = zmain~batch
                                  AND _nsx~plant    = zmain~plant
                                  AND _nsx~characteristic = 'Z_NSX'
     LEFT JOIN zi_wm_bcnxtslgt_char AS _hsd
                                   ON _hsd~material = zmain~material
                                  AND _hsd~batch    = zmain~batch
                                  AND _hsd~plant    = zmain~plant
                                  AND _hsd~characteristic = 'Z_HSD'
    LEFT JOIN zi_wm_bcnxtslgt_char  AS _cvt  ON _cvt~material       = zmain~material
                                            AND _cvt~plant          = zmain~plant
                                            AND _cvt~batch          = zmain~batch
                                            AND _cvt~characteristic = 'Z_VTGC'
    LEFT JOIN zi_wm_bcnxtslgt_char  AS _ngsp  ON _ngsp~material       = zmain~material
                                             AND _ngsp~plant          = zmain~plant
                                             AND _ngsp~batch          = zmain~batch
                                             AND _ngsp~characteristic = 'Z_NGSP'
    LEFT JOIN zi_wm_bcnxtsl_nx_ctt( p_startdate = @lv_start_date,
                                    p_enddate   = @lv_end_date ) AS z_nx_ctt
                             ON z_nx_ctt~plant                        = zmain~plant
                            AND z_nx_ctt~material                     = zmain~material
                            AND z_nx_ctt~batch                        = zmain~batch
                            AND z_nx_ctt~sddocument                   = zmain~sddocument
                            AND z_nx_ctt~sddocumentitem               = zmain~sddocumentitem
                            AND z_nx_ctt~issuingorreceivingstorageloc = zmain~storagelocation
                            AND z_nx_ctt~inventoryspecialstocktype    = zmain~inventoryspecialstocktype
    LEFT JOIN zi_wm_bcnxtsl_nx( p_startdate = @lv_start_date,
                                p_enddate   = @lv_end_date ) AS z_nx
                                                             ON z_nx~plant              = zmain~plant
                                                            AND z_nx~storagelocation    = zmain~storagelocation
                                                            AND z_nx~batch              = zmain~batch
                                                            AND z_nx~sddocument         = zmain~sddocument
                                                            AND z_nx~sddocumentitem     = zmain~sddocumentitem
                                                            AND z_nx~material           = zmain~material
                                                            AND z_nx~inventoryspecialstocktype = zmain~inventoryspecialstocktype
    WHERE zmain~companycode               IN @lr_bukrs
      AND zmain~plant                     IN @lr_werks
      AND zmain~inventoryspecialstocktype IN @lr_sobkz
      AND zmain~material                  IN @lr_matnr
      AND zmain~batch                     IN @lr_charg
      AND mara~producttype                IN @lr_mtart
      AND mara~productgroup               IN @lr_matkl
      AND zmain~storagelocation           IN @lr_storage
      AND z_grd~charcfromdate             IN @lr_z_grd
    INTO TABLE @DATA(lt_data).
    IF sy-subrc = 0.
*      DATA lr_range_sloc TYPE RANGE OF lgort_d_edi_ext.
*      lr_range_sloc =  VALUE #( FOR ls_data_range IN lt_data (  sign = 'I' option = 'EQ' low = ls_data_range-storagelocation  ) ).
*      SORT lr_range_sloc.
*      DELETE ADJACENT DUPLICATES FROM lr_range_sloc COMPARING ALL FIELDS.
*
*      "Đơn giá
*      DATA: lt_range_matnr TYPE RANGE OF matnr.
*
*      lt_range_matnr = VALUE #( FOR ls_data_range IN lt_data ( sign = 'I' option = 'EQ' low = ls_data_range-material ) ).
*      SORT lt_range_matnr.
*      DELETE ADJACENT DUPLICATES FROM lt_range_matnr COMPARING ALL FIELDS.

*      get_price( EXPORTING iv_date  = lv_prev_start_date
*                           iv_year  = lv_fiscal_year
*                           it_matnr = lt_range_matnr ).


      SELECT fmlt_price~valuationarea,
             fmlt_price~material,
             fmlt_price~inventoryspecialstocktype,
             fmlt_price~salesorder,
             fmlt_price~salesorderitem,
             fmlt_price~currency,
             fmlt_price~inventoryprice
      FROM i_inventorypricebykeydate( p_calendardate = @lv_prev_start_date )
        AS fmlt_price
      INNER JOIN @lt_data AS data
        ON fmlt_price~valuationarea  = data~plant
       AND fmlt_price~material       = data~material
       AND fmlt_price~inventoryspecialstocktype = data~inventoryspecialstocktype
       AND fmlt_price~salesorder      = data~sddocument
       AND fmlt_price~salesorderitem  = data~sddocumentitem
      WHERE fmlt_price~currencyrole  = '10'
        AND fmlt_price~ledger        = '0L'
        AND fmlt_price~fiscalyear    in @lr_fiscal_year
      INTO TABLE @DATA(lt_price).
      IF sy-subrc = 0.
        SORT lt_price BY valuationarea material inventoryspecialstocktype salesorder salesorderitem.
        DELETE ADJACENT DUPLICATES FROM lt_price COMPARING ALL FIELDS.
      ENDIF.


*      ""GET so luong matdoc
      DATA: lt_matdoc_reserse LIKE lt_data.
      lt_matdoc_reserse =  VALUE #( FOR ls_matdoc_reserse IN lt_data ( plant           = ls_matdoc_reserse-plant
                                                                       material        = ls_matdoc_reserse-material
                                                                       batch           = ls_matdoc_reserse-batch
                                                                       sddocument      = ls_matdoc_reserse-sddocument
                                                                       sddocumentitem  = ls_matdoc_reserse-sddocumentitem
                                                                       storagelocation = ls_matdoc_reserse-storagelocation
                                                                       inventoryspecialstocktype = ls_matdoc_reserse-inventoryspecialstocktype ) ).
      SORT lt_matdoc_reserse.
      DELETE ADJACENT DUPLICATES FROM lt_matdoc_reserse COMPARING ALL FIELDS.

      SELECT matdoc~plant,
             matdoc~material,
             matdoc~batch,
             matdoc~salesorder,
             matdoc~salesorderitem,
             matdoc~storagelocation,
             matdoc~inventoryspecialstocktype,
             SUM( matdoc~quantityinbaseunit ) AS quantity
      FROM i_materialdocumentitem_2 AS matdoc
      INNER JOIN @lt_matdoc_reserse AS lt_matdoc
                                    ON lt_matdoc~plant = matdoc~plant
                                   AND lt_matdoc~material = matdoc~material
                                   AND lt_matdoc~batch    = matdoc~batch
                                   AND lt_matdoc~sddocument = matdoc~salesorder
                                   AND lt_matdoc~sddocumentitem = matdoc~salesorderitem
                                   AND lt_matdoc~storagelocation = matdoc~storagelocation
                                   AND lt_matdoc~inventoryspecialstocktype = matdoc~inventoryspecialstocktype

      WHERE matdoc~postingdate                  >= @lv_start_date
        AND matdoc~postingdate                  <= @lv_end_date
        AND EXISTS ( SELECT * FROM i_materialdocumentitem_2 AS b
                                                         WHERE b~reversedmaterialdocument     = matdoc~materialdocument
                                                           AND b~reversedmaterialdocumentitem = matdoc~materialdocumentitem
                                                           AND b~reversedmaterialdocumentyear = matdoc~materialdocumentyear )
      GROUP BY matdoc~plant,matdoc~material,matdoc~batch,matdoc~salesorder,matdoc~salesorderitem,matdoc~storagelocation,matdoc~inventoryspecialstocktype
      ORDER BY matdoc~plant,matdoc~material,matdoc~batch,matdoc~salesorder,matdoc~salesorderitem,matdoc~storagelocation,matdoc~inventoryspecialstocktype
     INTO TABLE  @DATA(lt_quantity).


      DATA:ls_return LIKE LINE OF et_data.
      LOOP AT lt_data REFERENCE INTO DATA(ls_data).
        CLEAR: ls_return.
*        APPEND INITIAL LINE TO et_data REFERENCE INTO DATA(ls_return).
        ls_return = CORRESPONDING #( ls_data->* ).
        IF ls_data->quantity <> 0 .
          ls_data->quantity = ls_data->quantity / 2.
        ENDIF.
        READ TABLE lt_quantity INTO DATA(ls_quantity) WITH KEY           plant = ls_data->plant
                                                                      material = ls_data->material
                                                                      batch    = ls_data->batch
                                                                    salesorder = ls_data->sddocument
                                                                salesorderitem = ls_data->sddocumentitem
                                                               storagelocation = ls_data->storagelocation
                                                     inventoryspecialstocktype = ls_data->inventoryspecialstocktype BINARY SEARCH.

        ls_return-totalreceiptqty = ls_data->totalreceiptqtyctt - ls_data->quantity - ls_quantity-quantity .
        ls_return-totalissueqty   = ls_data->totalissueqtyctt  - ls_data->quantity - ls_quantity-quantity .

        READ TABLE lt_price INTO DATA(ls_price)
          WITH KEY valuationarea              = ls_return-plant
                   material                   = ls_return-material
                   inventoryspecialstocktype  = ls_return-inventoryspecialstocktype
                   salesorder                 = ls_return-sddocument
                   salesorderitem             = ls_return-sddocumentitem BINARY SEARCH.
        IF sy-subrc EQ 0.
          ls_return-companycodecurrency  = ls_price-currency.
          ls_return-openingprice         = ls_price-inventoryprice * ls_return-openingstock.
          ls_return-closingprice         = ls_price-inventoryprice * ls_return-closingstock.
        ELSE.
          ls_return-companycodecurrency = 'VND'.
        ENDIF.

        IF ls_data->z_hsqd <> 0.
          ls_return-z_hsqd = ls_data->z_hsqd.
        ELSE.
          IF ls_data->alternativeunit = 'Z1'.
            ls_return-z_hsqd = ls_data->quantitynumerator / ls_data->quantitydenominator.
          ENDIF.
        ENDIF.

        IF ls_return-z_hsqd <> 0.
          ls_return-thuopening         = ls_return-openingstock / ls_return-z_hsqd.
          ls_return-thutotalreceiptqty = ls_return-totalreceiptqty / ls_return-z_hsqd.
          ls_return-thutotalissueqty   = ls_return-totalissueqty / ls_return-z_hsqd.
          ls_return-thuclosing         = ls_return-closingstock / ls_return-z_hsqd.
        ELSE.
          ls_return-thuopening         = 0 .
          ls_return-thutotalreceiptqty = 0 .
          ls_return-thutotalissueqty   = 0 .
          ls_return-thuclosing         = 0 .
        ENDIF.
        ls_return-thuunit = 'Z1'.

        "Check phân quyền hiển thị Opening value
        IF lv_check_author EQ abap_false.
          ls_return-openingprice  = 0.
          ls_return-closingprice  = 0.
        ENDIF.

        ls_return-startdate = lv_start_date.

        CLEAR: ls_quantity.
        IF ( ls_return-openingstock + ls_return-totalreceiptqty + ls_return-totalissueqty + ls_return-closingstock ) = 0.
          CONTINUE.
        ENDIF.
        APPEND ls_return TO et_data.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD get_instance.
    IF instance IS INITIAL.
      CREATE OBJECT instance.
    ENDIF.
    ro_instance = instance.
  ENDMETHOD.


  METHOD get_price.

    DATA:
      ls_entity_key    TYPE zmd_fi_fmlt_price=>tys_yy_1_i_fmlt_price_paramete,
      lt_business_data TYPE TABLE OF zmd_fi_fmlt_price=>tys_yy_1_i_fmlt_price_type,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    TYPES:
      "! CurrencyRole
      currency_role TYPE c LENGTH 2,
      "! Ledger
      ledger        TYPE c LENGTH 2,
      "! FiscalYear
      fiscal_year   TYPE c LENGTH 4.
    DATA:
      lo_filter_factory      TYPE REF TO /iwbep/if_cp_filter_factory,
      lo_filter_node_1       TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_2       TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_3       TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_4       TYPE REF TO /iwbep/if_cp_filter_node,
      lo_filter_node_root    TYPE REF TO /iwbep/if_cp_filter_node,
      lt_range_currency_role TYPE RANGE OF currency_role,
      lt_range_ledger        TYPE RANGE OF ledger,
      lt_range_fiscal_year   TYPE RANGE OF fiscal_year.

    APPEND VALUE #( sign = 'I' option = 'EQ' low = '10' ) TO lt_range_currency_role.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '0L' ) TO lt_range_ledger.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = iv_year ) TO lt_range_fiscal_year.

    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'ZCORE_CS_SAP'
                                                     service_id     = 'Z_API_SAP_REST' ).

        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
          EXPORTING
             is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                 proxy_model_id      = 'ZMD_FI_FMLT_PRICE'
                                                 proxy_model_version = '0001' )
            io_http_client             = lo_http_client
            iv_relative_service_root   = 'sap/opu/odata/sap/YY1_I_FMLT_PRICE_CDS' ).

        ASSERT lo_http_client IS BOUND.

        ls_entity_key = VALUE #(
          p_calendar_date   = iv_date ).

        " Navigate to the resource and create a request for the read operation
        lo_request = lo_client_proxy->create_resource_for_entity_set( 'YY_1_I_FMLT_PRICE' )->navigate_with_key( ls_entity_key )->navigate_to_many( 'SET' )->create_request_for_read( ).

        " Create the filter tree
        lo_filter_factory = lo_request->create_filter_factory( ).

        lo_filter_node_1  = lo_filter_factory->create_by_range( iv_property_path     = 'CURRENCY_ROLE'
                                                                it_range             = lt_range_currency_role ).
        lo_filter_node_2  = lo_filter_factory->create_by_range( iv_property_path     = 'LEDGER'
                                                                it_range             = lt_range_ledger ).
        lo_filter_node_3  = lo_filter_factory->create_by_range( iv_property_path     = 'FISCAL_YEAR'
                                                                it_range             = lt_range_fiscal_year ).
        lo_filter_node_4  = lo_filter_factory->create_by_range( iv_property_path     = 'MATERIAL'
                                                                it_range             = it_matnr ).

        lo_filter_node_root = lo_filter_node_1->and( lo_filter_node_2 )->and( lo_filter_node_3 )->and( lo_filter_node_4 ).
        lo_request->set_filter( lo_filter_node_root ).

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = gt_price ).

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception

      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE SHORTDUMP lx_web_http_client_error.
      CATCH cx_http_dest_provider_error.
        "handle exception
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
