@EndUserText.label: 'Báo cáo nhập xuất tồn số lượng'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_WM_BCNXTSL'
@UI: {
    headerInfo: {
        typeName: 'Báo cáo nhập xuất tồn số lượng',
        typeNamePlural: 'Báo cáo nhập xuất tồn số lượng'
    }
}
define custom entity ZI_WM_BCNXTSL_CUSTOM
  with parameters
    // tham số 11
    @EndUserText.label       : 'From Date'
    P_StartDate : vdm_v_start_date,
    // tham số 12
    @EndUserText.label       : 'To Date'
    P_EndDate   : vdm_v_end_date
  // tham số 13
  //    @Consumption.valueHelpDefinition      : [ {
  //    entity                   :{
  //    name                     :'ZI_WM_NSDM_PERIOD_TYPE',
  //    element                  :'value_low' }
  //    }]
  //    @EndUserText.label       : 'Period Type'
  //    P_PeriodType : nsdm_period_type,
  // tham số 14
  //    @EndUserText.label       : 'Fiscal Year'
  //    P_FiscalYear : fis_gjahr_no_conv
{
      // tham số 1
      @Consumption                 : {
      valueHelpDefinition          : [ {
      entity                       :{
      name                         :'I_CompanyCodeStdVH',
      element                      :'CompanyCode' }
      }],
      filter                       :{ mandatory:true } }
      @UI.selectionField           : [ { position: 10 } ]
      @UI.lineItem                 : [ { position: 10 } ]
      @EndUserText.label           : 'Company Code'
  key CompanyCode                  : bukrs;
      // tham số 3
      @Consumption                 : {
      valueHelpDefinition          : [ {
      entity                       :{
      name                         :'I_PlantStdVH',
      element                      :'Plant' }
      }],
      filter                       :{ mandatory:true } }
      @UI.selectionField           : [ { position: 30 } ]
      @UI.lineItem                 : [ { position: 20 } ]
      @EndUserText.label           : 'Plant'
  key Plant                        : werks_d;
      //      // tham số 4
      //      @UI.selectionField       : [ { position: 40 } ]
      //      @UI.lineItem             : [ { position: 30 } ]
      //      @EndUserText.label       : 'Storage Location'
      //  key StorageLocation,
      // tham số 10
      @Consumption.valueHelpDefinition      : [ {
      entity                       :{
      name                         :'I_InventorySpecialStockType',
      element                      :'InventorySpecialStockType' }
      }]
      @UI.selectionField           : [ { position: 100 } ]
      @UI.lineItem                 : [ { position: 40 } ]
      @EndUserText.label           : 'Special Indicator'
  key InventorySpecialStockType    : sobkz;
      // tham số 2
      @Consumption.valueHelpDefinition      : [ {
      entity                       :{
      name                         :'I_ProductStdVH',
      element                      :'Product' }
      }]
      @UI.selectionField           : [ { position: 20 } ]
      @UI.lineItem                 : [ { position: 50 } ]
      @EndUserText.label           : 'Material Number'
  key Material                     : matnr;
      // tham số 7
      @Consumption.valueHelpDefinition      : [ {
      entity                       :{
      name                         :'I_BatchStdVH',
      element                      :'Batch' },
      additionalBinding            : [
      {element                     : 'Material', localElement: 'Material', usage: #FILTER_AND_RESULT},
      {element                     : 'Plant', localElement: 'Plant', usage: #FILTER_AND_RESULT}
      ]
      }]
      @UI.selectionField           : [ { position: 70 } ]
      @UI.lineItem                 : [ { position: 60 } ]
      @EndUserText.label           : 'Batch'
  key Batch                        : charg_d;
      @UI.lineItem                 : [ { position: 61 } ]
      @EndUserText.label           : 'Sales Order'
  key SDDocument                   : zde_vbeln_va;
      @UI.lineItem                 : [ { position: 62 } ]
      @EndUserText.label           : 'Sales Order Item'
  key SDDocumentItem               : zde_posnr_va;
      @UI                          : {
      selectionField               : [{ position: 45 }],
      lineItem                     : [{ position: 24 , importance: #MEDIUM } ] }
      @Consumption.valueHelpDefinition:[ { entity: { name: 'I_StorageLocationStdVH', element: 'StorageLocation' } } ]
      @EndUserText.label           : 'Storage location'
  key StorageLocation              : lgort_d_edi_ext;
      @UI                          : {
      lineItem                     : [{ position: 25 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Storage Location Name'
      StorageLocationName          : abap.char(16);
      @UI.lineItem                 : [ { position: 11 } ]
      @EndUserText.label           : 'Company Code Name'
      CompanyCodeName              : abap.char(200);
      @UI.lineItem                 : [ { position: 21 } ]
      @EndUserText.label           : 'Plant Name'
      PlantName                    : abap.char(200);
      @UI.lineItem                 : [ { position: 51 } ]
      @EndUserText.label           : 'Material Description'
      ProductName                  : maktx;
      @UI.lineItem                 : [ { position: 100 } ]
      @EndUserText.label           : 'Start Date'
      StartDate                    : vdm_v_start_date;
      @UI.lineItem                 : [ { position: 110 } ]
      @EndUserText.label           : 'End Date'
      EndDate                      : vdm_v_end_date;
      @UI.lineItem                 : [ { position: 120 } ]
      @EndUserText.label           : 'Base Unit'
      MaterialBaseUnit             : meins;
      @UI.lineItem                 : [ { position: 130 } ]
      @EndUserText.label           : 'Currency'
      CompanyCodeCurrency          : waers;
      @Aggregation.default         : #SUM
      @UI.lineItem                 : [ { position: 140 } ]
      //      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      @EndUserText.label           : 'Opening Stock'
      OpeningStock                 : abap.dec( 31, 2 );
      @Aggregation.default         : #SUM
      //      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      @UI.lineItem                 : [ { position: 150 } ]
      @EndUserText.label           : 'Total Receipt Quantities'
      TotalReceiptQty              : abap.dec( 31, 2 );
      @Aggregation.default         : #SUM
      //      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      @UI.lineItem                 : [ { position: 160 } ]
      @EndUserText.label           : 'Total Issue Quantities'
      TotalIssueQty                : abap.dec( 31, 2 );
      @Aggregation.default         : #SUM
      //      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      @UI.lineItem                 : [ { position: 170 } ]
      @EndUserText.label           : 'Closing Stock'
      ClosingStock                 : abap.dec( 31, 2 );
      // tham số 5
      @Consumption.valueHelpDefinition      : [ {
      entity                       :{
      name                         :'I_ProductType_2',
      element                      :'ProductType' }
      }]
      @UI.selectionField           : [ { position: 50 } ]
      @UI.lineItem                 : [ { position: 180 } ]
      @EndUserText.label           : 'Material Type'
      ProductType                  : mtart;
      @UI.lineItem                 : [ { position: 190 } ]
      MaterialTypeName             : abap.char(25);
      // tham số 6
      @Consumption.valueHelpDefinition      : [ {
      entity                       :{
      name                         :'I_ProductGroup_2',
      element                      :'ProductGroup' }
      }]
      @UI.selectionField           : [ { position: 60 } ]
      @UI.lineItem                 : [ { position: 200 } ]
      @EndUserText.label           : 'Material Group'
      ProductGroup                 : matkl;
      @UI.lineItem                 : [ { position: 210 } ]
      @EndUserText.label           : 'Material Group Text'
      ProductGroupName             : abap.char(20);
      @UI.lineItem                 : [ { position: 220 } ]
      @EndUserText.label           : 'Supplier'
      Supplier                     : lifnr;
      @UI.lineItem                 : [ { position: 230 } ]
      @EndUserText.label           : 'Supplier Name'
      SupplierFullName             : abap.char(200);
      @UI                          : {
      lineItem                     : [{ position: 440 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Số hợp đồng'
      SoHopDong                    : abap.char(70);
      @UI.lineItem                 : [ { position: 240 } ]
      @EndUserText.label           : 'Ngày nhập kho'
      Z_GRD                        : abap.dats;
      @UI.lineItem                 : [ { position: 270 } ]
      @EndUserText.label           : 'Đơn vị sản xuất'
      Z_DSX                        : abap.char(70);
      @UI.lineItem                 : [ { position: 280 } ]
      @EndUserText.label           : 'Nhà cung cấp'
      Z_NCC                        : abap.char(70);
      @UI.lineItem                 : [ { position: 290 } ]
      @EndUserText.label           : 'Ghi chú'
      Z_GHICHU                     : abap.char(70);
      @UI.lineItem                 : [ { position: 300 } ]
      @EndUserText.label           : 'Số lot'
      SoLot                        : abap.char(70);
      @UI.lineItem                 : [ { position: 310 } ]
      @EndUserText.label           : 'Ca sản xuất'
      Z_CSX                        : abap.char(70);
      @UI.lineItem                 : [ { position: 320 } ]
      @EndUserText.label           : 'KG/Thùng'
      Z_HSQD                       : abap.dec( 23, 3 );
      @UI                          : {
      lineItem                     : [{ position: 330 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Loại vụn'
      ZVun                         : abap.char(70);
      @UI                          : {
      lineItem                     : [{ position:330 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Khách hàng gửi gia công'
      ViTri                        : abap.char(70);
      @UI.lineItem                 : [ { position: 321 } ]
      @EndUserText.label           : 'ĐVT THU'
      THUUnit                      : meins;
      @Aggregation.default         : #SUM
      @Semantics.quantity.unitOfMeasure: 'THUUnit'
      @UI.lineItem                 : [ { position: 322 } ]
      @EndUserText.label           : 'Tồn đầu kỳ THU'
      THUOpening                   : abap.dec( 13, 2 );
      @Aggregation.default         : #SUM
      @Semantics.quantity.unitOfMeasure: 'THUUnit'
      @UI.lineItem                 : [ { position: 323 } ]
      @EndUserText.label           : 'Tổng nhập THU'
      THUTotalReceiptQty           : abap.dec( 13,2 );
      @Semantics.quantity.unitOfMeasure: 'THUUnit'
      @Aggregation.default         : #SUM
      @UI.lineItem                 : [ { position: 324 } ]
      @EndUserText.label           : 'Tổng xuất THU'
      THUTotalIssueQty             : abap.dec( 13, 2 );
      @Aggregation.default         : #SUM
      @Semantics.quantity.unitOfMeasure: 'THUUnit'
      @UI.lineItem                 : [ { position: 325 } ]
      @EndUserText.label           : 'Tồn cuối kỳ THU'
      THUClosing                   : abap.dec( 13, 2 );
      @ObjectModel.text.element    : [ 'YY1_CHUNGNHAN_PRD_TEXT' ]
      @UI                          : {
      lineItem                     : [{ position: 330 } ] }
      //      @Consumption.valueHelpDefinition:[ { entity: { name: 'i_customfieldcodelisttext', element: 'Code' }, additionalBinding: [{
      //                                           element: 'CustomFieldID', localConstant: 'YY1_CHUNGNHAN', usage: #FILTER }] } ]
      @EndUserText.label           : 'Chứng nhận'
      YY1_CHUNGNHAN_PRD            : abap.char(30);
      @Consumption.filter.hidden   : true
      @UI.hidden                   : true
      YY1_CHUNGNHAN_PRD_TEXT       : abap.char(60);

      @ObjectModel.text.element    : [ 'YY1_DONGSANPHAM_PRD_TEXT' ]
      @UI                          : {
      lineItem                     : [{ position: 340 } ] }
      @EndUserText.label           : 'Dòng sản phẩm'
      YY1_DONGSANPHAM_PRD          : abap.char(30);
      @Consumption.filter.hidden   : true
      @UI.hidden                   : true
      YY1_DONGSANPHAM_PRD_TEXT     : abap.char(60);

      @ObjectModel.text.element    : [ 'YY1_GIAVIPHUGIA_PRD_TEXT' ]
      @UI                          : {
      lineItem                     : [{ position: 350 }] }
      @EndUserText.label           : 'Gia vị/ phụ gia'
      YY1_GIAVIPHUGIA_PRD          : abap.char(30);
      @Consumption.filter.hidden   : true
      @UI.hidden                   : true
      YY1_GIAVIPHUGIA_PRD_TEXT     : abap.char(60);
      @ObjectModel.text.element    : [ 'YY1_KICHCOSIZE_PRD_TEXT' ]
      @UI                          : {
      lineItem                     : [{ position: 360 } ] }
      @EndUserText.label           : 'Kích cỡ/ Hình dáng/ Size'
      YY1_KICHCOHINHDANGSIZE_PRD   : abap.char(30);
      @Consumption.filter.hidden   : true
      @UI.hidden                   : true
      YY1_KICHCOSIZE_PRD_TEXT      : abap.char(60);
      @ObjectModel.text.element    : [ 'YY1_LOAIHINHSANXUAT_PRD_TEXT' ]
      @UI                          : {
      lineItem                     : [{ position: 370 } ] }
      @EndUserText.label           : 'Loại hình sản xuất'
      YY1_LOAIHINHSANXUAT_PRD      : abap.char(30);
      @Consumption.filter.hidden   : true
      @UI.hidden                   : true
      YY1_LOAIHINHSANXUAT_PRD_TEXT : abap.char(60);
      @ObjectModel.text.element    : [ 'YY1_LOAITPTHUHOI_PRD_TEXT' ]
      @UI                          : {
      lineItem                     : [{ position: 380 }  ] }
      @EndUserText.label           : 'Loại TP thu hồi'
      YY1_LOAITPTHUHOI_PRD         : abap.char(30);
      @Consumption.filter.hidden   : true
      @UI.hidden                   : true
      YY1_LOAITPTHUHOI_PRD_TEXT    : abap.char(60);
      @Consumption.filter.hidden   : true
      @ObjectModel.text.element    : [ 'YY1_QUYCACHDONGGOI_PRD_TEXT' ]
      @UI                          : {
      lineItem                     : [{ position: 390 } ] }
      @EndUserText.label           : 'Quy cách đóng gói'
      YY1_QUYCACHDONGGOI_PRD       : abap.char(30);
      @UI.hidden                   : true
      @Consumption.filter.hidden   : true
      YY1_QUYCACHDONGGOI_PRD_TEXT  : abap.char(60);
      @UI                          : {
      lineItem                     : [{ position: 390 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Ngày sản xuất'
      NgaySanXuat                  : abap.dats(8);
      @UI                          : {
      lineItem                     : [{ position: 400 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Hạn sử dụng'
      HanSuDung                    : abap.dats(8);
      @UI                          : {
      lineItem                     : [{ position: 410 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Nguồn gốc sản phẩm'
      NguonGocSanPham              : abap.char(70);
      @UI                          : {
       lineItem                    : [{ position: 390 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Khách hàng'
      SoldToPartyName              : abap.char(100);
      @Aggregation.default         : #SUM
      @UI                          : {
      lineItem                     : [{ position: 420 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Opening Price'
      @Consumption.filter.hidden   : true
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      OpeningPrice                 : abap.curr( 23, 2 );
      @UI.hidden                   : true
      @Consumption.filter.hidden   : true
      @EndUserText.label           : 'Total Receipt Values'
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      TotalReceiptPrice            : abap.curr( 23, 2 );
      @UI.hidden                   : true
      @Consumption.filter.hidden   : true
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      TotalIssuePrice              : abap.curr( 23, 2 );
      @Aggregation.default         : #SUM
      @UI                          : {
      lineItem                     : [{ position: 430 , importance: #MEDIUM } ] }
      @EndUserText.label           : 'Closing Price'
      @Consumption.filter.hidden   : true
      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
      ClosingPrice                 : abap.curr( 23, 2 );

}
