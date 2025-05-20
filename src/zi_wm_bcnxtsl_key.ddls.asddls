@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Báo cáo xuất nhập tồn số lượng'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_WM_BCNXTSL_KEY
  with parameters
    P_StartDate  : vdm_v_start_date,
    P_EndDate    : vdm_v_end_date,
    P_PeriodType : nsdm_period_type
//    P_FiscalYear : fis_gjahr_no_conv
  as select from I_MaterialStockTimeSeries
                 ( P_StartDate  : $parameters.P_StartDate,
                   P_EndDate    : $parameters.P_EndDate,
                   P_PeriodType : $parameters.P_PeriodType   )
//    inner join   I_CalendarDate as CalendarDateStart on  CalendarDateStart.CalendarDate = $parameters.P_StartDate
//                                                     and CalendarDateStart.CalendarYear = $parameters.P_FiscalYear
//    inner join   I_CalendarDate as CalendarDateEnd   on  CalendarDateEnd.CalendarDate = $parameters.P_EndDate
//                                                     and CalendarDateEnd.CalendarYear = $parameters.P_FiscalYear
{
  key I_MaterialStockTimeSeries.CompanyCode,
  key I_MaterialStockTimeSeries.Plant,
  key I_MaterialStockTimeSeries.StorageLocation,
  key I_MaterialStockTimeSeries.InventorySpecialStockType,
  key I_MaterialStockTimeSeries.Material,
  key I_MaterialStockTimeSeries.Batch,
  key I_MaterialStockTimeSeries.SDDocument,
  key I_MaterialStockTimeSeries.SDDocumentItem,
      I_MaterialStockTimeSeries.MaterialBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum( I_MaterialStockTimeSeries.MatlWrhsStkQtyInMatlBaseUnit ) as MatlWrhsStkQtyInMatlBaseUnit
}
where
  I_MaterialStockTimeSeries.Material is not initial
group by
  I_MaterialStockTimeSeries.CompanyCode,
  I_MaterialStockTimeSeries.Plant,
  I_MaterialStockTimeSeries.StorageLocation,
  I_MaterialStockTimeSeries.InventorySpecialStockType,
  I_MaterialStockTimeSeries.Material,
  I_MaterialStockTimeSeries.Batch,
  I_MaterialStockTimeSeries.SDDocument,
  I_MaterialStockTimeSeries.SDDocumentItem,
  I_MaterialStockTimeSeries.MaterialBaseUnit
